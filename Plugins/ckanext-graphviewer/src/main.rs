pub mod button;
mod graph_processor;
mod parser;
mod theme;

use eframe::egui;
use env_logger;
use log::{error, info};
use std::sync::{Arc, Mutex};

use graph_processor::{Edge, Node};
use theme::Theme;

#[derive(PartialEq)]
pub enum Scene {
    Graph,
    Analytics,
}

#[derive(Clone)]
pub struct GraphSnapshot {
    pub node_positions: std::collections::HashMap<String, egui::Pos2>,
    pub visible_nodes: std::collections::HashSet<String>,
    pub expanded_nodes: std::collections::HashSet<String>,
    pub visible_edges: std::collections::HashSet<(String, String)>,
}

impl GraphSnapshot {
    pub fn new(nodes: &[Node], edges: &[Edge]) -> Self {
        let mut node_positions = std::collections::HashMap::new();
        let mut visible_nodes = std::collections::HashSet::new();
        let mut expanded_nodes = std::collections::HashSet::new();
        let mut visible_edges = std::collections::HashSet::new();

        for n in nodes {
            node_positions.insert(n.id.clone(), n.pos);
            if n.visible {
                visible_nodes.insert(n.id.clone());
            }
            if n.expanded {
                expanded_nodes.insert(n.id.clone());
            }
        }
        for e in edges {
            if e.visible {
                visible_edges.insert((nodes[e.source].id.clone(), nodes[e.target].id.clone()));
            }
        }

        Self {
            node_positions,
            visible_nodes,
            expanded_nodes,
            visible_edges,
        }
    }
}

pub enum AppState {
    Loading,
    Error(String),
    Ready {
        selected_entrypoint: String,
        nodes: Vec<Node>,
        edges: Vec<Edge>,
        raw_triples: Vec<parser::RawTriple>,
        init_snapshot: GraphSnapshot,
    },
}

struct App {
    state: Arc<Mutex<AppState>>,
    zoom: f32,
    pan: egui::Vec2,
    theme: Theme,
    selected_node: Option<usize>,
    show_menu: bool,
    pending_click_node: Option<usize>,
    pending_click_time: f64,
    is_dark_mode: bool,
    canvas_rect: Option<egui::Rect>,
    current_scene: Scene,
}

// obtain source file
#[cfg(target_arch = "wasm32")]
fn get_n3_url_from_current_path() -> Option<String> {
    let window = web_sys::window()?;
    let location = window.location();
    let pathname = location.pathname().ok()?;
    let pathname2 = pathname.strip_suffix("/graph")?;
    Some(format!("{}.n3", pathname2))
}

#[cfg(not(target_arch = "wasm32"))]
fn load_local_file(path: &str) -> Result<(Vec<Node>, Vec<Edge>, Vec<parser::RawTriple>), String> {
    match std::fs::read_to_string(path) {
        Ok(content) => {
            // extract pure data (N3 -> triples)
            let raw_triples = parser::parse_n3_file(&content);

            // format for UI (triples -> graph)
            let (ui_nodes, ui_edges) = graph_processor::build_ui_graph(raw_triples).clone();

            Ok((ui_nodes, ui_edges, raw_triples))
        }
        Err(e) => Err(format!("Failed to read file '{}': {}", path, e)),
    }
}

// A dummy version for WASM so it still compiles
#[cfg(target_arch = "wasm32")]
fn load_local_file(_path: &str) -> Result<(Vec<Node>, Vec<Edge>), String> {
    Err("Direct file access is not supported in the browser.".to_string())
}

// wasm png export
#[cfg(target_arch = "wasm32")]
fn trigger_wasm_canvas_download(rect: egui::Rect, ppp: f32, filename: &str) {
    use wasm_bindgen::JsCast;

    let window = web_sys::window().unwrap();
    let document = window.document().unwrap();

    // 1. Grab the actual web canvas that eframe is drawing to
    if let Some(main_canvas_elem) = document.get_element_by_id("the_canvas_id") {
        if let Ok(main_canvas) = main_canvas_elem.dyn_into::<web_sys::HtmlCanvasElement>() {
            // Calculate exact physical pixels
            let sx = (rect.min.x * ppp).round() as f64;
            let sy = (rect.min.y * ppp).round() as f64;
            let s_width = (rect.width() * ppp).round() as f64;
            let s_height = (rect.height() * ppp).round() as f64;

            if s_width > 0.0 && s_height > 0.0 {
                // 2. Create a hidden, temporary HTML canvas just for cropping
                if let Ok(temp_canvas_elem) = document.create_element("canvas") {
                    if let Ok(temp_canvas) =
                        temp_canvas_elem.dyn_into::<web_sys::HtmlCanvasElement>()
                    {
                        temp_canvas.set_width(s_width as u32);
                        temp_canvas.set_height(s_height as u32);

                        // 3. Draw ONLY the cropped graph onto our temp canvas
                        if let Ok(Some(ctx_obj)) = temp_canvas.get_context("2d") {
                            if let Ok(ctx) = ctx_obj.dyn_into::<web_sys::CanvasRenderingContext2d>()
                            {
                                let _ = ctx.draw_image_with_html_canvas_element_and_sw_and_sh_and_dx_and_dy_and_dw_and_dh(
                                    &main_canvas, sx, sy, s_width, s_height, 0.0, 0.0, s_width, s_height
                                );

                                // 4. Ask the browser to encode it to a base64 PNG URL and trigger a download!
                                if let Ok(data_url) = temp_canvas.to_data_url_with_type("image/png")
                                {
                                    if let Ok(a) = document.create_element("a") {
                                        a.set_attribute("href", &data_url).unwrap();
                                        a.set_attribute("download", filename).unwrap();
                                        if let Ok(html_a) = a.dyn_into::<web_sys::HtmlElement>() {
                                            html_a.click();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

impl App {
    pub fn new(cc: &eframe::CreationContext<'_>) -> Self {
        cc.egui_ctx.style_mut(|style| {
            style.interaction.tooltip_delay = 0.0;
        });

        let is_system_dark = match cc.integration_info.system_theme {
            Some(eframe::Theme::Light) => false,
            _ => true,
        };

        if is_system_dark {
            cc.egui_ctx.set_visuals(egui::Visuals::dark());
        } else {
            cc.egui_ctx.set_visuals(egui::Visuals::light());
        }

        let state = Arc::new(Mutex::new(AppState::Loading));
        let state_clone = state.clone();
        let mut app_state = state_clone.lock().unwrap();

        #[cfg(target_arch = "wasm32")]
        {
            if let Some(target_url) = get_n3_url_from_current_path() {
                let state_clone = state.clone();
                let ctx_clone = cc.egui_ctx.clone();

                let request = ehttp::Request::get(&target_url);

                ehttp::fetch(request, move |response| {
                    let mut app_state = state_clone.lock().unwrap();
                    match response {
                        Ok(res) => {
                            if let Some(text) = res.text() {
                                let raw_triples = parser::parse_n3_file(&text);

                                let (nodes, edges) =
                                    graph_processor::build_ui_graph(raw_triples.clone());

                                let init_snapshot = GraphSnapshot::new(&nodes, &edges);

                                *app_state = AppState::Ready {
                                    selected_entrypoint: "placeholder".to_string(),
                                    nodes,
                                    edges,
                                    raw_triples,
                                    init_snapshot,
                                };
                            } else {
                                *app_state = AppState::Error("failed to read text from n3".into());
                            }
                        }
                        Err(err) => *app_state = AppState::Error(format!("Network Error: {}", err)),
                    }
                    ctx_clone.request_repaint();
                });
            } else {
                *state.lock().unwrap() =
                    AppState::Error("Could not determine TTL path from URL".into());
            }
        }

        // Try to load the file on startup (Native only)
        #[cfg(not(target_arch = "wasm32"))]
        match load_local_file("src/sample.n3") {
            Ok((ui_nodes, ui_edges, raw_triples)) => {
                let init_snapshot = GraphSnapshot::new(&ui_nodes, &ui_edges);
                *app_state = AppState::Ready {
                    selected_entrypoint: "sample.n3".to_string(),
                    nodes,
                    edges,
                    raw_triples,
                    init_snapshot,
                };
            }
            Err(e) => {
                *app_state = AppState::Error(e);
            }
        }

        Self {
            state,
            zoom: 1.0,
            pan: egui::vec2(0.0, 0.0),
            theme: Theme::dark(),
            selected_node: None,
            show_menu: false,
            pending_click_node: None,
            pending_click_time: 0.0,
            is_dark_mode: true,
            canvas_rect: None,
            current_scene: Scene::Graph,
        }
    }
}

impl eframe::App for App {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        let main_app_frame = egui::Frame::central_panel(&ctx.style()).fill(self.theme.master_bg);

        egui::CentralPanel::default()
            .frame(main_app_frame)
            .show(ctx, |ui| {
                ui.horizontal(|ui| {
                    ui.visuals_mut().selection.bg_fill = self.theme.button_bg;

                    ui.selectable_value(
                        &mut self.current_scene,
                        Scene::Graph,
                        egui::RichText::new("Graph Visualization")
                            .heading()
                            .color(self.theme.text_fg),
                    );
                    ui.selectable_value(
                        &mut self.current_scene,
                        Scene::Analytics,
                        egui::RichText::new("Analytics")
                            .heading()
                            .color(self.theme.text_fg),
                    );
                });

                ui.separator();

                ui.horizontal(|ui| {
                    ui.label(egui::RichText::new("Graph Controls:").color(self.theme.text_fg));

                    ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                        let theme_string = if self.is_dark_mode {
                            "Light Mode"
                        } else {
                            "Dark Mode"
                        };

                        let theme_button = egui::Button::new(
                            egui::RichText::new(theme_string).color(self.theme.text_fg),
                        )
                        .fill(self.theme.button_bg);

                        if ui.add(theme_button).clicked() {
                            self.is_dark_mode = !self.is_dark_mode;

                            if self.is_dark_mode {
                                ctx.set_visuals(egui::Visuals::dark());
                                self.theme = Theme::dark();
                            } else {
                                ctx.set_visuals(egui::Visuals::light());
                                self.theme = Theme::light();
                            }
                        }

                        let reset_view_button = egui::Button::new(
                            egui::RichText::new("Reset View").color(self.theme.text_fg),
                        )
                        .fill(self.theme.button_bg);

                        if ui.add(reset_view_button).clicked() {
                            self.zoom = 1.0;
                            self.pan = egui::vec2(0.0, 0.0);
                            self.selected_node = None;

                            let mut state_lock = self.state.lock().unwrap();

                            if let AppState::Ready {
                                nodes,
                                edges,
                                init_snapshot,
                                ..
                            } = &mut *state_lock
                            {
                                // 1 & 2. Make everything invisible, and ONLY restore the items in the Snapshot!
                                for node in nodes.iter_mut() {
                                    if let Some(&pos) = init_snapshot.node_positions.get(&node.id) {
                                        node.pos = pos;
                                    } else {
                                        node.pos = node.original_pos;
                                    }
                                    // If it wasn't visible in the snapshot (like new API fetches), it becomes hidden!
                                    node.visible = init_snapshot.visible_nodes.contains(&node.id);
                                    node.expanded = init_snapshot.expanded_nodes.contains(&node.id);
                                }

                                for edge in edges.iter_mut() {
                                    let s_id = &nodes[edge.source].id;
                                    let t_id = &nodes[edge.target].id;

                                    edge.visible = init_snapshot
                                        .visible_edges
                                        .contains(&(s_id.clone(), t_id.clone()))
                                        || init_snapshot
                                            .visible_edges
                                            .contains(&(t_id.clone(), s_id.clone()));
                                }

                                // 3. That state becomes the new init snapshot!
                                *init_snapshot = GraphSnapshot::new(nodes, edges);
                            }
                        }

                        let export_button = egui::Button::new(
                            egui::RichText::new("Export as PNG").color(self.theme.text_fg),
                        )
                        .fill(self.theme.button_bg);

                        if ui.add(export_button).clicked() {
                            // Desktop behavior (Native)
                            #[cfg(not(target_arch = "wasm32"))]
                            ctx.send_viewport_cmd(egui::ViewportCommand::Screenshot);

                            // Browser behavior (WASM)
                            #[cfg(target_arch = "wasm32")]
                            if let Some(rect) = self.canvas_rect {
                                let ppp = ctx.pixels_per_point();
                                trigger_wasm_canvas_download(rect, ppp, "graph_export.png");
                            }
                        }
                    });
                });

                let mut state_lock = self.state.lock().unwrap();

                if let AppState::Ready {
                    selected_entrypoint,
                    nodes,
                    edges,
                    raw_triples,
                    ..
                } = &mut *state_lock
                {
                    // render analytics
                    if self.current_scene == Scene::Analytics {
                        egui::ScrollArea::vertical()
                            .auto_shrink([false, false])
                            .show(ui, |ui| {
                                ui.heading(
                                    egui::RichText::new("Graph Memory Analytics")
                                        .color(self.theme.text_fg),
                                );
                                ui.add_space(10.0);

                                let visible_nodes = nodes.iter().filter(|n| n.visible).count();
                                let total_nodes = nodes.len();
                                let visible_edges = edges.iter().filter(|e| e.visible).count();
                                let total_edges = edges.len();

                                ui.label(
                                    egui::RichText::new(format!(
                                        "Total Nodes: {} ({} currently visible)",
                                        total_nodes, visible_nodes
                                    ))
                                    .color(self.theme.text_fg),
                                );
                                ui.label(
                                    egui::RichText::new(format!(
                                        "Total Edges: {} ({} currently visible)",
                                        total_edges, visible_edges
                                    ))
                                    .color(self.theme.text_fg),
                                );
                                ui.add_space(15.0);

                                ui.heading(
                                    egui::RichText::new("Node Types Breakdown")
                                        .size(16.0)
                                        .color(self.theme.text_fg),
                                );
                                ui.add_space(5.0);

                                let mut type_counts = std::collections::HashMap::new();
                                for n in nodes.iter() {
                                    let t = if n.rdf_type.is_empty() {
                                        "Untyped Node".to_string()
                                    } else {
                                        n.rdf_type.clone()
                                    };
                                    *type_counts.entry(t).or_insert(0) += 1;
                                }

                                let mut sorted_types: Vec<(String, i32)> = type_counts
                                    .into_iter()
                                    .map(|(t, count)| {
                                        let display_name = t.split('#').last().unwrap_or(&t);
                                        let display_name = display_name.split('/').last().unwrap_or(display_name).to_string();
                                        (display_name, count)
                                    })
                                    .collect();

                                sorted_types.sort_by(|a, b| a.0.to_lowercase().cmp(&b.0.to_lowercase()));

                                egui::Grid::new("analytics_grid")
                                    .num_columns(2)
                                    .spacing([40.0, 8.0])
                                    .show(ui, |ui| {
                                        for (display_name, count) in sorted_types {
                                            ui.label(egui::RichText::new(display_name).strong().color(self.theme.text_fg));
                                            ui.label(egui::RichText::new(count.to_string()).color(self.theme.text_fg));
                                            ui.end_row();
                                        }
                                    });

                                ui.add_space(15.0);
                                ui.heading(
                                    egui::RichText::new("Raw Data")
                                        .size(16.0)
                                        .color(self.theme.text_fg),
                                );
                                ui.label(
                                    egui::RichText::new(format!(
                                        "Raw Triples Parsed: {}",
                                        raw_triples.len()
                                    ))
                                    .color(self.theme.text_fg),
                                );
                            });
                    }
                    // render graph
                    else if self.current_scene == Scene::Graph {
                        let draw_node_details = |ui: &mut egui::Ui, node: &Node| {
                            egui::Grid::new(format!("tooltip_grid_{}", node.id))
                                .num_columns(2)
                                .spacing([10.0, 4.0])
                                .show(ui, |ui| {
                                    let display_id = if node.node_type == "Attribute" {
                                        &node.label
                                    } else {
                                        &node.id
                                    };

                                    if !display_id.is_empty() {
                                        ui.strong("ID:");
                                        if display_id.len() > 60 {
                                            egui::ScrollArea::vertical()
                                                .id_source(format!("scroll_id_{}", node.id))
                                                .max_height(60.0)
                                                .min_scrolled_height(0.0)
                                                .show(ui, |ui| {
                                                    ui.label(display_id);
                                                });
                                        } else {
                                            ui.label(display_id);
                                        }
                                        ui.end_row();
                                    }

                                    let mut seen_props = std::collections::HashSet::new();

                                    for (i, (key, value)) in node.properties.iter().enumerate() {
                                        if !seen_props.insert((key.clone(), value.clone())) {
                                            continue;
                                        }

                                        let display_key = {
                                            let mut c = key.chars();
                                            match c.next() {
                                                None => String::new(),
                                                Some(f) => {
                                                    f.to_uppercase().collect::<String>()
                                                        + c.as_str()
                                                }
                                            }
                                        };

                                        ui.strong(format!("{}:", display_key));

                                        if value.len() > 60 {
                                            egui::ScrollArea::vertical()
                                                .id_source(format!("scroll_prop_{}_{}", node.id, i))
                                                .max_height(100.0)
                                                .min_scrolled_height(0.0)
                                                .show(ui, |ui| {
                                                    ui.label(value);
                                                });
                                        } else {
                                            ui.label(value);
                                        }
                                        ui.end_row();
                                    }
                                });
                        };

                        // define a frame that houses the color config for the legend
                        let legend_outline = egui::Frame::window(&ui.ctx().style())
                            .fill(self.theme.button_bg)
                            .inner_margin(3.0)
                            .rounding(5.0)
                            .stroke(egui::Stroke::new(2.0, self.theme.master_bg));

                        // render legend
                        egui::Window::new(egui::RichText::new("Legend").color(self.theme.text_fg))
                            .anchor(egui::Align2::LEFT_TOP, egui::vec2(15.0, 60.0))
                            .collapsible(true)
                            .resizable(false)
                            .frame(legend_outline)
                            .show(ui.ctx(), |ui| {
                                ui.style_mut().visuals.override_text_color =
                                    Some(self.theme.text_fg);
                                egui::Frame::none()
                                    .inner_margin(5.0)
                                    .rounding(5.0)
                                    .stroke(egui::Stroke::new(1.0, self.theme.edge_fg))
                                    .fill(self.theme.master_bg)
                                    .show(ui, |ui| {
                                        egui::Grid::new("legend_grid")
                                            .num_columns(2)
                                            .spacing([10.0, 8.0])
                                            .show(ui, |ui| {
                                                for (uri, colors) in &self.theme.node_map {
                                                    let display_name =
                                                        uri.split('#').last().unwrap_or(uri);
                                                    let display_name = display_name
                                                        .split('/')
                                                        .last()
                                                        .unwrap_or(display_name);

                                                    let (rect, _) = ui.allocate_exact_size(
                                                        egui::vec2(12.0, 12.0),
                                                        egui::Sense::hover(),
                                                    );
                                                    ui.painter().circle_filled(
                                                        rect.center(),
                                                        6.0,
                                                        colors.normal,
                                                    );

                                                    ui.label(display_name);
                                                    ui.end_row();
                                                }

                                                let (rect, _) = ui.allocate_exact_size(
                                                    egui::vec2(12.0, 12.0),
                                                    egui::Sense::hover(),
                                                );
                                                ui.painter().circle_filled(
                                                    rect.center(),
                                                    6.0,
                                                    self.theme.default_node.normal,
                                                );
                                                ui.label("Other / Unknown");
                                                ui.end_row();
                                            });
                                    });
                            });

                        let background_rect = ui.available_rect_before_wrap();
                        let area_to_fill = ui.available_rect_before_wrap();

                        self.canvas_rect = Some(area_to_fill);

                        let screen_center = area_to_fill.center().to_vec2();

                        let background_response = ui.interact(
                            background_rect,
                            ui.id().with("background"),
                            egui::Sense::click_and_drag(),
                        );
                        if background_response.dragged() {
                            self.pan += background_response.drag_delta();
                        }
                        if background_response.clicked() {
                            self.selected_node = None;
                        }

                        let scroll_y = ui.input(|i| i.smooth_scroll_delta.y);

                        let pinch_zoom = ui.input(|i| i.zoom_delta());

                        let mut zoom_multiplier = pinch_zoom;
                        if scroll_y != 0.0 {
                            zoom_multiplier *= (scroll_y * 0.005).exp();
                        }

                        if zoom_multiplier != 1.0 {
                            if let Some(pointer_pos) = ui.ctx().pointer_hover_pos() {
                                let pointer_vec = pointer_pos.to_vec2();

                                let graph_pos =
                                    (pointer_vec - screen_center - self.pan) / self.zoom;

                                self.zoom *= zoom_multiplier;
                                self.zoom = self.zoom.clamp(0.1, 5.0);

                                self.pan = pointer_vec - screen_center - graph_pos * self.zoom;
                            }
                        }

                        let to_screen = |p: egui::Pos2| -> egui::Pos2 {
                            (screen_center + self.pan + p.to_vec2() * self.zoom).to_pos2()
                        };

                        let painter = ui.painter().with_clip_rect(area_to_fill);

                        painter.rect_filled(area_to_fill, 0.0, self.theme.painter_bg);

                        // draw edges and labels
                        for edge in edges.iter() {
                            if !edge.visible {
                                continue;
                            }

                            let s = &nodes[edge.source];
                            let t = &nodes[edge.target];

                            let p1 = to_screen(s.pos);
                            let p2 = to_screen(t.pos);
                            let vector = p2 - p1;
                            let length = vector.length();

                            if length == 0.0 {
                                continue;
                            }
                            let dir = vector / length;

                            // draw edge
                            painter.line_segment(
                                [p1, p2],
                                egui::Stroke::new(1.5 * self.zoom, self.theme.edge_fg),
                            );

                            let node_radius = 15.0 * self.zoom;
                            let arrow_len = 12.0 * self.zoom;
                            let arrow_angle = 0.4;
                            let line_angle = dir.y.atan2(dir.x);

                            // draw arrowhead
                            let tip = p2 - (dir * node_radius);
                            let angle_left = line_angle - arrow_angle;
                            let p_left =
                                tip - egui::vec2(angle_left.cos(), angle_left.sin()) * arrow_len;
                            let angle_right = line_angle + arrow_angle;
                            let p_right =
                                tip - egui::vec2(angle_right.cos(), angle_right.sin()) * arrow_len;

                            painter.add(egui::Shape::convex_polygon(
                                vec![tip, p_left, p_right],
                                self.theme.edge_fg,
                                egui::Stroke::NONE,
                            ));

                            // draw arrowhead reverse
                            if edge.bidirectional {
                                let tip_rev = p1 + (dir * node_radius);
                                let dir_rev = -dir;
                                let line_angle_rev = dir_rev.y.atan2(dir_rev.x);

                                let angle_left_rev = line_angle_rev - arrow_angle;
                                let p_left_rev = tip_rev
                                    - egui::vec2(angle_left_rev.cos(), angle_left_rev.sin())
                                        * arrow_len;
                                let angle_right_rev = line_angle_rev + arrow_angle;
                                let p_right_rev = tip_rev
                                    - egui::vec2(angle_right_rev.cos(), angle_right_rev.sin())
                                        * arrow_len;

                                painter.add(egui::Shape::convex_polygon(
                                    vec![tip_rev, p_left_rev, p_right_rev],
                                    self.theme.edge_fg,
                                    egui::Stroke::NONE,
                                ));
                            }

                            // draw label
                            let center_point = p1 + (dir * length * 0.5);

                            let font_size = (10.0 * self.zoom).round();

                            if font_size > 4.0 {
                                let is_flipped = dir.x < 0.0;

                                let display_text = if !is_flipped {
                                    // target is to the right
                                    if let Some(rev) = &edge.reverse_label {
                                        format!("{} ->\n<- {}", edge.label, rev)
                                    } else if edge.bidirectional {
                                        format!("<- {} ->", edge.label)
                                    } else {
                                        format!("{} ->", edge.label)
                                    }
                                } else {
                                    // target is to the left
                                    if let Some(rev) = &edge.reverse_label {
                                        format!("<- {}\n{} ->", edge.label, rev)
                                    } else if edge.bidirectional {
                                        format!("<- {} ->", edge.label)
                                    } else {
                                        format!("<- {}", edge.label)
                                    }
                                };

                                let galley = painter.layout_no_wrap(
                                    display_text,
                                    egui::FontId::proportional(font_size),
                                    self.theme.text_fg,
                                );

                                let size = galley.size();
                                let padding = 3.0 * self.zoom;

                                let snapped_center =
                                    egui::pos2(center_point.x.round(), center_point.y.round());
                                let text_rect = egui::Rect::from_center_size(snapped_center, size);

                                // background box for label
                                painter.rect_filled(
                                    text_rect.expand(padding),
                                    2.0 * self.zoom,
                                    self.theme.painter_bg,
                                );

                                painter.galley(text_rect.min, galley, self.theme.text_fg);
                            }
                        }

                        // draw node
                        let mut clicked_to_expand = None;

                        let mut dragged_node_delta = None;

                        for (index, node) in nodes.iter().enumerate() {
                            if !node.visible {
                                continue;
                            }

                            let screen_pos = to_screen(node.pos);
                            let radius = 15.0 * self.zoom;

                            let response = ui.interact(
                                egui::Rect::from_center_size(
                                    screen_pos,
                                    egui::vec2(radius * 2.0, radius * 2.0),
                                ),
                                ui.id().with(&node.id),
                                egui::Sense::click_and_drag(),
                            );

                            let current_time = ui.input(|i| i.time);

                            // node it dragged
                            if response.dragged() {
                                let delta = response.drag_delta() / self.zoom;
                                self.selected_node = None;
                                self.pending_click_node = None;
                                dragged_node_delta = Some((index, delta));
                            }

                            // left double click / left click
                            if response.double_clicked() {
                                clicked_to_expand = Some(index);
                                self.selected_node = None;
                                self.pending_click_node = None;
                            } else if response.clicked() {
                                self.pending_click_node = Some(index);
                                self.pending_click_time = current_time;
                            }

                            // right click
                            if response.secondary_clicked() {
                                self.selected_node = Some(index);
                                self.show_menu = true;
                                self.pending_click_node = None;
                            }

                            // delay infobox till we are sure no double click happend
                            if self.pending_click_node == Some(index) {
                                if (current_time - self.pending_click_time) > 0.25 {
                                    // 250 ms
                                    if self.selected_node == Some(index) && !self.show_menu {
                                        self.selected_node = None;
                                    } else {
                                        self.selected_node = Some(index);
                                        self.show_menu = false;
                                    }
                                    self.pending_click_node = None; // Clear the timer
                                } else {
                                    ui.ctx().request_repaint();
                                }
                            }

                            let is_pinned = self.selected_node == Some(index) && !self.show_menu;

                            if is_pinned {
                                let offset = egui::vec2(20.0 * self.zoom, 20.0 * self.zoom);

                                egui::Window::new(format!("node_window_{}", node.id))
                                    .fixed_pos(screen_pos + offset)
                                    .title_bar(false)
                                    .resizable(false)
                                    .collapsible(false)
                                    .frame(egui::Frame::popup(&ctx.style()))
                                    .show(ctx, |ui| {
                                        ui.heading(&node.label);
                                        ui.separator();

                                        draw_node_details(ui, node);

                                        ui.add_space(5.0);
                                        if ui.button("Close").clicked() {
                                            self.selected_node = None;
                                        }
                                    });
                            }

                            let node_theme = self.theme.get_node_colors(&node.rdf_type);

                            let color = if response.hovered() {
                                node_theme.hovered
                            } else {
                                node_theme.normal
                            };

                            painter.circle_filled(screen_pos, radius, color);

                            let font_size = 12.0 * self.zoom;
                            if font_size > 4.0 {
                                let display_text = if node.label.len() > 50 {
                                    let pred_name = edges
                                        .iter()
                                        .find(|e| e.target == index)
                                        .map(|e| e.label.clone())
                                        .unwrap_or_else(|| "Dataset".to_string());
                                    let display_pred = {
                                        let mut c = pred_name.chars();
                                        match c.next() {
                                            None => String::new(),
                                            Some(f) => {
                                                f.to_uppercase().collect::<String>() + c.as_str()
                                            }
                                        }
                                    };

                                    format!("{} (Click to show)", display_pred)
                                } else {
                                    node.label.clone()
                                };

                                let galley = painter.layout_no_wrap(
                                    display_text.to_string(),
                                    egui::FontId::proportional(font_size),
                                    self.theme.text_fg,
                                );

                                let text_pos = screen_pos + egui::vec2(0.0, 20.0 * self.zoom);
                                let text_rect = egui::Align2::CENTER_TOP.anchor_rect(
                                    egui::Rect::from_min_size(text_pos, galley.size()),
                                );

                                painter.rect_filled(
                                    text_rect.expand(2.0 * self.zoom),
                                    2.0 * self.zoom,
                                    self.theme.painter_bg,
                                );

                                painter.galley(text_rect.min, galley, self.theme.text_fg);
                            }
                        }

                        // node menu
                        if let Some(menu_idx) = self.selected_node {
                            if self.show_menu {
                                let screen_pos = to_screen(nodes[menu_idx].pos);
                                let menu_radius = 35.0 * self.zoom;
                                let btn_radius = 12.0 * self.zoom;

                                // button 1 expand
                                let expand_pos = screen_pos + egui::vec2(-menu_radius, 0.0);
                                let expand_rect = egui::Rect::from_center_size(
                                    expand_pos,
                                    egui::vec2(btn_radius * 2.0, btn_radius * 2.0),
                                );
                                let expand_resp = ui.interact(
                                    expand_rect,
                                    ui.id().with(format!("btn_exp_{}", menu_idx)),
                                    egui::Sense::click(),
                                );

                                // Draw the blue circle and a +/- icon
                                painter.circle_filled(
                                    expand_pos,
                                    btn_radius,
                                    egui::Color32::from_rgb(70, 130, 200),
                                );
                                let icon = if nodes[menu_idx].expanded { "-" } else { "+" };
                                let galley = painter.layout_no_wrap(
                                    icon.into(),
                                    egui::FontId::proportional(16.0 * self.zoom),
                                    egui::Color32::WHITE,
                                );
                                painter.galley(
                                    expand_pos - galley.size() / 2.0,
                                    galley,
                                    egui::Color32::WHITE,
                                );

                                if expand_resp.clicked() {
                                    clicked_to_expand = Some(menu_idx);
                                    self.selected_node = None;
                                }

                                // button 2
                                let info_pos = screen_pos + egui::vec2(menu_radius, 0.0);
                                let info_rect = egui::Rect::from_center_size(
                                    info_pos,
                                    egui::vec2(btn_radius * 2.0, btn_radius * 2.0),
                                );
                                let info_resp = ui.interact(
                                    info_rect,
                                    ui.id().with(format!("btn_info_{}", menu_idx)),
                                    egui::Sense::click(),
                                );

                                // Draw the green circle and an 'i' icon
                                painter.circle_filled(
                                    info_pos,
                                    btn_radius,
                                    egui::Color32::from_rgb(100, 180, 100),
                                );
                                let galley = painter.layout_no_wrap(
                                    "i".into(),
                                    egui::FontId::proportional(14.0 * self.zoom),
                                    egui::Color32::WHITE,
                                );
                                painter.galley(
                                    info_pos - galley.size() / 2.0,
                                    galley,
                                    egui::Color32::WHITE,
                                );

                                if info_resp.clicked() {
                                    self.show_menu = false;
                                }

                                // button 3 api fetch
                                // vec containing fetchable nodes
                                let fetchable_types = vec![
                                    "http://purl.org/spar/pro/Author",
                                    "http://www.w3.org/ns/dcat#DataService",
                                    "http://www.w3.org/ns/dcat#Dataset",
                                ];

                                let current_type = nodes[menu_idx].rdf_type.clone();
                                let is_fetchable =
                                    fetchable_types.iter().any(|&t| current_type.contains(t));

                                if is_fetchable {
                                    let api_pos = screen_pos + egui::vec2(0.0, -menu_radius);
                                    let api_rect = egui::Rect::from_center_size(
                                        api_pos,
                                        egui::vec2(btn_radius * 2.0, btn_radius * 2.0),
                                    );
                                    let api_resp = ui.interact(
                                        api_rect,
                                        ui.id().with(format!("btn_api_{}", menu_idx)),
                                        egui::Sense::click(),
                                    );

                                    // TODO pull color via theme file
                                    let btn_color = if nodes[menu_idx].api_fetched {
                                        egui::Color32::from_rgb(150, 150, 150)
                                    } else {
                                        egui::Color32::from_rgb(220, 140, 50)
                                    };

                                    painter.circle_filled(api_pos, btn_radius, btn_color);
                                    let galley = painter.layout_no_wrap(
                                        "API".into(),
                                        egui::FontId::proportional(10.0 * self.zoom),
                                        egui::Color32::WHITE,
                                    );
                                    painter.galley(
                                        api_pos - galley.size() / 2.0,
                                        galley,
                                        egui::Color32::WHITE,
                                    );

                                    if api_resp.clicked() && !nodes[menu_idx].api_fetched {
                                        self.show_menu = false;
                                        self.selected_node = None;
                                        let state_clone = self.state.clone();
                                        let ctx_clone = ctx.clone();
                                        let clicked_node_id = nodes[menu_idx].id.clone();

                                        if current_type.contains("http://purl.org/spar/pro/Author")
                                        {
                                            crate::button::fetch_author_information(
                                                ctx_clone.clone(),
                                                state_clone.clone(),
                                                clicked_node_id.clone(),
                                                clicked_node_id.clone(),
                                            );
                                        }

                                        if current_type
                                            .contains("http://www.w3.org/ns/dcat#DataService")
                                            || current_type
                                                .contains("http://www.w3.org/ns/dcat#Dataset")
                                        {
                                            crate::button::fetch_dataset_information(
                                                ctx_clone,
                                                state_clone,
                                                clicked_node_id.clone(),
                                                clicked_node_id,
                                            );
                                        }
                                    }
                                }
                            }
                        }

                        // move child node in sync
                        if let Some((parent_idx, delta)) = dragged_node_delta {
                            nodes[parent_idx].pos += delta;

                            // for edge in edges.iter() {
                            //     if edge.source == parent_idx && edge.visible {
                            //         let child_idx = edge.target;
                            //         nodes[child_idx].pos += delta;
                            //     }
                            // }
                        }

                        // expansion
                        if let Some(parent_idx) = clicked_to_expand {
                            let is_currently_expanded = nodes[parent_idx].expanded;

                            if is_currently_expanded {
                                // cascade collapse
                                let mut stack = vec![parent_idx];

                                while let Some(current_idx) = stack.pop() {
                                    nodes[current_idx].expanded = false;

                                    for edge_idx in 0..edges.len() {
                                        let mut child_idx_opt = None;

                                        if edges[edge_idx].source == current_idx
                                            && edges[edge_idx].visible
                                        {
                                            child_idx_opt = Some(edges[edge_idx].target);
                                        } else if edges[edge_idx].target == current_idx
                                            && edges[edge_idx].visible
                                        {
                                            child_idx_opt = Some(edges[edge_idx].source);
                                        }

                                        if let Some(child_idx) = child_idx_opt {
                                            edges[edge_idx].visible = false;

                                            let has_other_active_parents = edges.iter().any(|e| {
                                                (e.target == child_idx || e.source == child_idx)
                                                    && e.visible
                                            });

                                            if !has_other_active_parents {
                                                nodes[child_idx].visible = false;

                                                if nodes[child_idx].expanded {
                                                    stack.push(child_idx);
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                nodes[parent_idx].expanded = true;
                                let mut children_indices = Vec::new();

                                for (edge_idx, edge) in edges.iter().enumerate() {
                                    if edge.source == parent_idx {
                                        children_indices.push((edge_idx, edge.target));
                                    } else if edge.target == parent_idx {
                                        children_indices.push((edge_idx, edge.source));
                                    }
                                }

                                let total_children = children_indices.len();
                                let mut angle: f32 = 0.0;
                                let angle_step =
                                    std::f32::consts::TAU / (total_children.max(1) as f32);
                                let spawn_radius = 240.0;

                                for (edge_idx, target_idx) in children_indices {
                                    let target_pos = nodes[parent_idx].pos
                                        + egui::vec2(
                                            angle.cos() * spawn_radius,
                                            angle.sin() * spawn_radius,
                                        );
                                    angle += angle_step;

                                    if !nodes[target_idx].visible {
                                        nodes[target_idx].pos = target_pos;
                                    }
                                    nodes[target_idx].visible = true;
                                    edges[edge_idx].visible = true;
                                }
                            }
                        }
                    }
                } else if let AppState::Error(err_msg) = &*state_lock {
                    ui.heading("Something went wrong:");
                    ui.label(
                        egui::RichText::new(err_msg)
                            .color(egui::Color32::RED)
                            .strong(),
                    );
                } else {
                    ui.heading("Loading...");
                }
            });

        // nativ png
        #[cfg(not(target_arch = "wasm32"))]
        {
            // Check if egui just handed us a fresh screenshot event
            for event in ctx.input(|i| i.events.clone()) {
                if let egui::Event::Screenshot { image, .. } = event {
                    if let Some(rect) = self.canvas_rect {
                        let ppp = ctx.pixels_per_point();

                        // Convert logical egui coordinates into physical monitor pixels
                        let min_x = (rect.min.x * ppp).round() as u32;
                        let min_y = (rect.min.y * ppp).round() as u32;
                        let max_x = (rect.max.x * ppp).round() as u32;
                        let max_y = (rect.max.y * ppp).round() as u32;

                        let width = max_x.saturating_sub(min_x);
                        let height = max_y.saturating_sub(min_y);

                        if width > 0 && height > 0 {
                            let mut img_buf = image::ImageBuffer::new(width, height);

                            // Crop the raw full-screen image down to just the canvas area
                            for y in 0..height {
                                for x in 0..width {
                                    let img_x = (min_x + x) as usize;
                                    let img_y = (min_y + y) as usize;

                                    if img_x < image.size[0] && img_y < image.size[1] {
                                        // egui stores pixels in a 1D array: (y * width) + x
                                        let pixel = image.pixels[img_y * image.size[0] + img_x];
                                        img_buf.put_pixel(
                                            x,
                                            y,
                                            image::Rgba([
                                                pixel.r(),
                                                pixel.g(),
                                                pixel.b(),
                                                pixel.a(),
                                            ]),
                                        );
                                    }
                                }
                            }

                            // Save it to the current directory!
                            match img_buf.save("graph_export.png") {
                                Ok(_) => println!("Successfully exported to graph_export.png!"),
                                Err(e) => println!("Failed to save PNG: {}", e),
                            }
                        }
                    }
                }
            }
        }
    }
}

// native entrypoint
#[cfg(not(target_arch = "wasm32"))]
fn main() -> eframe::Result<()> {
    // Initialize native logger
    env_logger::init();

    let native_options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default().with_inner_size([800.0, 600.0]),
        ..Default::default()
    };

    eframe::run_native(
        "Standalone Test App",
        native_options,
        Box::new(|cc| Box::new(App::new(cc))),
    )
}

// wasm entrypoint
#[cfg(target_arch = "wasm32")]
fn main() {
    // Initialize web logger
    eframe::WebLogger::init(log::LevelFilter::Debug).ok();

    let _ = js_sys::eval(
        r#"
        const ogGetContext = HTMLCanvasElement.prototype.getContext;
        HTMLCanvasElement.prototype.getContext = function(type, attrs) {
            if (type === 'webgl' || type === 'webgl2') {
                attrs = Object.assign({}, attrs || {}, { preserveDrawingBuffer: true });
            }
            return ogGetContext.call(this, type, attrs);
        };
    "#,
    );

    let web_options = eframe::WebOptions::default();

    wasm_bindgen_futures::spawn_local(async {
        eframe::WebRunner::new()
            .start(
                "the_canvas_id",
                web_options,
                Box::new(|cc| Box::new(App::new(cc))),
            )
            .await
            .expect("failed to start eframe");
    });
}
