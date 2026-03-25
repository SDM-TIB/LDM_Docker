mod parser;
mod theme;

use eframe::egui;
use env_logger;
use log::{error, info};
use std::sync::{Arc, Mutex};

use theme::Theme;
use parser::{parse_n3_to_graph, Edge, Node};

enum AppState {
    Loading,
    Error(String),
    Ready {
        selected_entrypoint: String,
        nodes: Vec<Node>,
        edges: Vec<Edge>,
    },
}

struct App {
    state: Arc<Mutex<AppState>>,
    zoom: f32,
    pan: egui::Vec2,
    theme: Theme,
    selected_node: Option<usize>,
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
fn load_local_file(path: &str) -> Result<(Vec<Node>, Vec<Edge>), String> {
    match std::fs::read_to_string(path) {
        Ok(content) => {
            // Call the parser we fixed earlier!
            Ok(parse_n3_to_graph(&content))
        }
        Err(e) => Err(format!("Failed to read file '{}': {}", path, e)),
    }
}

// A dummy version for WASM so it still compiles,
// though you'd typically use a browser file picker here instead.
#[cfg(target_arch = "wasm32")]
fn load_local_file(_path: &str) -> Result<(Vec<Node>, Vec<Edge>), String> {
    Err("Direct file access is not supported in the browser.".to_string())
}

impl App {
    pub fn new(cc: &eframe::CreationContext<'_>) -> Self {
        cc.egui_ctx.style_mut(|style| {
            style.interaction.tooltip_delay = 0.0;
        });

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
                                let (nodes, edges) = parse_n3_to_graph(text);
                                *app_state = AppState::Ready {
                                    selected_entrypoint: "placeholder".to_string(),
                                    nodes,
                                    edges
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
            Ok((nodes, edges)) => {
                *app_state = AppState::Ready {
                    selected_entrypoint: "sample.n3".to_string(),
                    nodes,
                    edges
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
            theme: Theme::default(),
            selected_node: None,
        }
    }
}

impl eframe::App for App {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.heading("Knowledge graph visualization");

            ui.horizontal(|ui| {
                ui.label("Graph Controls:");

                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    if ui.button("Reset View").clicked() {
                        self.zoom = 1.0;
                        self.pan = egui::vec2(0.0, 0.0);

                        let mut state_lock = self.state.lock().unwrap();
                        if let AppState::Ready { nodes, .. } = &mut *state_lock {
                            for node in nodes.iter_mut() {
                                node.pos = node.original_pos;
                            }
                        }
                    }

                    if ui.button("Load sample.n3").clicked() {
                        let mut state_lock = self.state.lock().unwrap();
                        *state_lock = AppState::Loading;

                        match load_local_file("sample.n3") {
                            Ok((nodes, edges)) => {
                                *state_lock = AppState::Ready {
                                    selected_entrypoint: "file_loaded".to_string(),
                                    nodes,
                                    edges,
                                };
                                self.zoom = 1.0;
                                self.pan = egui::vec2(400.0, 300.0);
                            }
                            Err(err_msg) => {
                                *state_lock = AppState::Error(err_msg);
                            }
                        }
                    }
                });
            });

            let mut state_lock = self.state.lock().unwrap();

            if let AppState::Ready { selected_entrypoint, nodes, edges } = &mut *state_lock {
                let draw_node_details = |ui: &mut egui::Ui, node: &Node| {
                    egui::Grid::new(format!("tooltip_grid_{}", node.id))
                        .num_columns(2)
                        .spacing([10.0, 4.0])
                        .show(ui, |ui| {
                            if !node.id.is_empty() {
                                ui.strong("ID:");
                                ui.label(&node.id);
                                ui.end_row();
                            }

                            if !node.rdf_type.is_empty() {
                                ui.strong("RDF Type:");
                                ui.label(&node.rdf_type);
                                ui.end_row();
                            }

                            if !node.node_type.is_empty() {
                                ui.strong("Node Type:");
                                ui.label(&node.node_type);
                                ui.end_row();
                            }
                        });
                };

                egui::Window::new("Legend")
                    .anchor(egui::Align2::LEFT_TOP, egui::vec2(15.0, 60.0))
                    .collapsible(true)
                    .resizable(false)
                    .show(ui.ctx(), |ui| {
                        egui::Grid::new("legend_grid")
                            .num_columns(2)
                            .spacing([10.0, 8.0])
                            .show(ui, |ui| {
                                for (uri, colors) in &self.theme.node_map {
                                    let display_name = uri.split('#').last().unwrap_or(uri);
                                    let display_name = display_name.split('/').last().unwrap_or(display_name);

                                    let (rect, _) = ui.allocate_exact_size(egui::vec2(12.0, 12.0), egui::Sense::hover());
                                    ui.painter().circle_filled(rect.center(), 6.0, colors.normal);

                                    ui.label(display_name);
                                    ui.end_row();
                                }

                                let (rect, _) = ui.allocate_exact_size(egui::vec2(12.0, 12.0), egui::Sense::hover());
                                ui.painter().circle_filled(rect.center(), 6.0, self.theme.default_node.normal);
                                ui.label("Other / Unknown");
                                ui.end_row();
                            });
                    });

                let background_rect = ui.available_rect_before_wrap();
                let area_to_fill = ui.available_rect_before_wrap();

                let screen_center = area_to_fill.center().to_vec2();

                let background_response = ui.interact(
                    background_rect,
                    ui.id().with("background"),
                    egui::Sense::click_and_drag()
                );
                if background_response.dragged() {
                    self.pan += background_response.drag_delta();
                }
                if background_response.clicked() {
                    self.selected_node = None;
                }

                let zoom_delta = ui.input(|i| i.zoom_delta());

                if zoom_delta != 1.0 {
                    if let Some(pointer_pos) = ui.ctx().pointer_hover_pos() {
                        let pointer_vec = pointer_pos.to_vec2();

                        let graph_pos = (pointer_vec - screen_center - self.pan) / self.zoom;

                        self.zoom *= zoom_delta;
                        self.zoom = self.zoom.clamp(0.1, 5.0);

                        self.pan = pointer_vec - screen_center - graph_pos * self.zoom;
                    }
                }

                let to_screen = |p: egui::Pos2| -> egui::Pos2 {
                    (screen_center + self.pan + p.to_vec2() * self.zoom).to_pos2()
                };

                let painter = ui.painter().with_clip_rect(area_to_fill);

                painter.rect_filled(
                    area_to_fill,
                    0.0,
                    self.theme.canvas_bg
                );

                // draw edge
                for edge in edges.iter() {
                    let s = &nodes[edge.source];
                    let t = &nodes[edge.target];
                    painter.line_segment(
                        [to_screen(s.pos), to_screen(t.pos)],
                        (2.0 * self.zoom, self.theme.edge_line)
                    );
                }

                // draw edge label
                for edge in edges.iter() {
                    let s = &nodes[edge.source];
                    let t = &nodes[edge.target];

                    let center_point = to_screen(s.pos + (t.pos - s.pos) * 0.5);
                    let font_size = 10.0 * self.zoom;

                    if font_size > 4.0 {
                        let galley = painter.layout_no_wrap(
                            edge.label.clone(),
                            egui::FontId::proportional(font_size),
                            self.theme.edge_text,
                        );

                        let text_rect = egui::Align2::CENTER_CENTER
                            .anchor_rect(egui::Rect::from_min_size(center_point, galley.size()));

                        painter.rect_filled(
                            text_rect.expand(2.0 * self.zoom),
                            2.0 * self.zoom,
                            self.theme.edge_text_bg,
                        );

                        painter.galley(text_rect.min, galley, egui::Color32::WHITE);
                    }
                }

                // draw node
                for (index, node) in nodes.iter_mut().enumerate() {
                    let screen_pos = to_screen(node.pos);
                    let radius = 15.0 * self.zoom;

                    let response = ui.interact(
                        egui::Rect::from_center_size(screen_pos, egui::vec2(radius * 2.0, radius * 2.0)),
                        ui.id().with(&node.id),
                        egui::Sense::click_and_drag(),
                    );

                    if response.dragged() {
                        node.pos += response.drag_delta() / self.zoom;
                        self.selected_node = None;
                    }

                    if response.hovered() && self.selected_node.is_some() && self.selected_node != Some(index) {
                        self.selected_node = None;
                    }

                    if response.clicked() {
                        if self.selected_node == Some(index) {
                            self.selected_node = None;
                        } else {
                            self.selected_node = Some(index);
                        }
                    }

                    let is_pinned = self.selected_node == Some(index);
                    let is_hovered = response.hovered() && !response.dragged();

                    if is_pinned || is_hovered {
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

                                if is_pinned {
                                    ui.add_space(5.0);
                                    if ui.button("Close").clicked() {
                                        self.selected_node = None;
                                    }
                                } else {
                                    ui.add_space(5.0);
                                    ui.label(
                                        egui::RichText::new("(Click to pin)")
                                            .italics()
                                            .color(egui::Color32::GRAY)
                                    );
                                }
                            });
                    }

                    let node_theme = self.theme.get_node_colors(&node.rdf_type);
                    let color = if is_hovered || is_pinned {
                        node_theme.hovered
                    } else {
                        node_theme.normal
                    };

                    painter.circle_filled(screen_pos, radius, color);

                    let font_size = 12.0 * self.zoom;
                    if font_size > 4.0 {

                        let display_text = if node.label.len() > 50 {
                            "Description (Click to show)"
                        } else {
                            &node.label
                        };

                        let galley = painter.layout_no_wrap(
                            display_text.to_string(),
                            egui::FontId::proportional(font_size),
                            self.theme.node_text,
                        );

                        let text_pos = screen_pos + egui::vec2(0.0, 20.0 * self.zoom);
                        let text_rect = egui::Align2::CENTER_TOP
                            .anchor_rect(egui::Rect::from_min_size(text_pos, galley.size()));

                        painter.rect_filled(
                            text_rect.expand(2.0 * self.zoom),
                            2.0 * self.zoom,
                            self.theme.edge_text_bg,
                        );

                        painter.galley(text_rect.min, galley, self.theme.node_text);
                    }
                }

            } else if let AppState::Error(err_msg) = &*state_lock {
                ui.heading("Something went wrong:");
                ui.label(
                    egui::RichText::new(err_msg)
                        .color(egui::Color32::RED)
                        .strong()
                );
            } else {
                ui.heading("Loading...");
            }
        });
    }
}

// native entrypoint
#[cfg(not(target_arch = "wasm32"))]
fn main() -> eframe::Result<()> {
    // Initialize native logger
    env_logger::init();

    let native_options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([800.0, 600.0]),
        ..Default::default()
    };

    eframe::run_native(
        "Standalone Test App",
        native_options,
        Box::new(|cc| Box::new(App::new(cc))),
    )
}


#[cfg(target_arch = "wasm32")]
fn main() {
    eframe::WebLogger::init(log::LevelFilter::Debug).ok();

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
