pub mod api_client;
pub mod constants;
pub mod export;
mod graph_processor;
mod node_menu;
mod parser;
mod theme;
pub mod ui;

use eframe::egui;
use log::info;
use std::sync::{Arc, Mutex};

use graph_processor::{Edge, Node};
use theme::Theme;

#[derive(PartialEq)]
pub enum Scene {
    Graph,
    Analytics,
    NodeInspector,
}

#[derive(PartialEq, Eq, Hash, Clone)]
pub enum SearchType {
    AuthorName,
    AuthorOrcid,
    AuthorLdmId,
    PaperDoi,
    PaperTitle,
    DatasetDoi,
    DatasetTitle,
    DatasetLdmId,
}

#[derive(PartialEq)]
pub enum ThemeMode {
    Light,
    Dark,
    TestingRed,
}

impl SearchType {
    pub fn as_str(&self) -> &'static str {
        match self {
            SearchType::AuthorName => "Author Name",
            SearchType::AuthorOrcid => "Author ORCID",
            SearchType::AuthorLdmId => "Author LDM ID",
            SearchType::PaperDoi => "Paper DOI",
            SearchType::PaperTitle => "Paper Title",
            SearchType::DatasetDoi => "Dataset DOI",
            SearchType::DatasetTitle => "Dataset Title",
            SearchType::DatasetLdmId => "Dataset LDM ID",
        }
    }

    pub fn all() -> Vec<SearchType> {
        vec![
            SearchType::AuthorName,
            SearchType::AuthorOrcid,
            SearchType::AuthorLdmId,
            SearchType::PaperDoi,
            SearchType::PaperTitle,
            SearchType::DatasetDoi,
            SearchType::DatasetTitle,
            SearchType::DatasetLdmId,
        ]
    }
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
    pub theme_mode: ThemeMode,
    canvas_rect: Option<egui::Rect>,
    current_scene: Scene,
    inspector_selected_node: Option<String>,
    inspector_search_text: String,
    search_type: SearchType,
    search_input: String,
    api_url: String,
    is_global_viewer: bool,
    pub is_fetching: Arc<Mutex<bool>>,
    pub search_failed: Arc<Mutex<bool>>,
    pub highlighted_index: usize,
    pub suggestions: Arc<Mutex<std::collections::HashMap<crate::SearchType, Vec<String>>>>,
}

#[cfg(target_arch = "wasm32")]
fn get_api_url_from_dom() -> Option<String> {
    let window = web_sys::window()?;
    let document = window.document()?;
    if let Some(canvas) = document.get_element_by_id("the_canvas_id") {
        if let Some(url) = canvas.get_attribute("data-api-url") {
            return Some(url.trim_end_matches('/').to_string());
        }
    }
    None
}

#[cfg(target_arch = "wasm32")]
fn get_n3_url_from_dom() -> Option<String> {
    let window = web_sys::window()?;
    let document = window.document()?;

    if let Some(canvas) = document.get_element_by_id("the_canvas_id") {
        if let Some(url) = canvas.get_attribute("data-n3-url") {
            if !url.is_empty() {
                return Some(url);
            }
        }
    }
    None
}

// wasm png export
#[cfg(target_arch = "wasm32")]
fn trigger_wasm_canvas_download(rect: egui::Rect, ppp: f32, filename: &str) {
    use wasm_bindgen::JsCast;

    let window = web_sys::window().unwrap();
    let document = window.document().unwrap();

    if let Some(main_canvas_elem) = document.get_element_by_id("the_canvas_id") {
        if let Ok(main_canvas) = main_canvas_elem.dyn_into::<web_sys::HtmlCanvasElement>() {
            let sx = (rect.min.x * ppp).round() as f64;
            let sy = (rect.min.y * ppp).round() as f64;
            let s_width = (rect.width() * ppp).round() as f64;
            let s_height = (rect.height() * ppp).round() as f64;

            if s_width > 0.0 && s_height > 0.0 {
                if let Ok(temp_canvas_elem) = document.create_element("canvas") {
                    if let Ok(temp_canvas) = temp_canvas_elem.dyn_into::<web_sys::HtmlCanvasElement>() {
                        temp_canvas.set_width(s_width as u32);
                        temp_canvas.set_height(s_height as u32);

                        if let Ok(Some(ctx_obj)) = temp_canvas.get_context("2d") {
                            if let Ok(ctx) = ctx_obj.dyn_into::<web_sys::CanvasRenderingContext2d>() {
                                let _ = ctx.draw_image_with_html_canvas_element_and_sw_and_sh_and_dx_and_dy_and_dw_and_dh(
                                    &main_canvas,
                                    sx,
                                    sy,
                                    s_width,
                                    s_height,
                                    0.0,
                                    0.0,
                                    s_width,
                                    s_height,
                                );

                                if let Ok(data_url) = temp_canvas.to_data_url_with_type("image/png") {
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
        cc.egui_ctx.global_style_mut(|style| {
            style.interaction.tooltip_delay = 0.0;
        });

        let is_system_dark = cc.egui_ctx.global_style().visuals.dark_mode;

        if is_system_dark {
            cc.egui_ctx.set_visuals(egui::Visuals::dark());
        } else {
            cc.egui_ctx.set_visuals(egui::Visuals::light());
        }

        let state = Arc::new(Mutex::new(AppState::Loading));

        #[cfg(target_arch = "wasm32")]
        let api_url = get_api_url_from_dom().unwrap_or_else(|| "http://0.0.0.0:5742".to_string());
        #[cfg(not(target_arch = "wasm32"))]
        let api_url = "http://194.95.157.131:5742".to_string();

        #[cfg(target_arch = "wasm32")]
        let n3_target_url = get_n3_url_from_dom();
        #[cfg(not(target_arch = "wasm32"))]
        let n3_target_url: Option<String> = None;

        let is_global_viewer = {
            #[cfg(target_arch = "wasm32")]
            {
                get_n3_url_from_dom().is_none()
            }
            #[cfg(not(target_arch = "wasm32"))]
            {
                true
            }
        };

        // Fetch N3 File (If Applicable) or mark Ready directly
        if let Some(target_url) = n3_target_url {
            let state_guard_clone = state.clone();
            let ctx_guard_clone = cc.egui_ctx.clone();

            let request = ehttp::Request::get(&target_url);
            ehttp::fetch(request, move |response| {
                match response {
                    Ok(res) => {
                        if let Some(text) = res.text() {
                            let raw_triples = parser::parse_n3_file(&text);
                            let (nodes, edges) = graph_processor::build_ui_graph(raw_triples.clone());
                            let init_snapshot = GraphSnapshot::new(&nodes, &edges);

                            *state_guard_clone.lock().unwrap() = AppState::Ready {
                                nodes,
                                edges,
                                raw_triples,
                                init_snapshot,
                            };
                        } else {
                            *state_guard_clone.lock().unwrap() = AppState::Error("failed to read text from n3".into());
                        }
                    }
                    Err(err) => {
                        *state_guard_clone.lock().unwrap() = AppState::Error(format!("Network Error: {}", err));
                    }
                }
                ctx_guard_clone.request_repaint();
            });
        } else {
            // Global viewer without predefined n3 file, jump straight to Ready
            *state.lock().unwrap() = AppState::Ready {
                nodes: Vec::new(),
                edges: Vec::new(),
                raw_triples: Vec::new(),
                init_snapshot: GraphSnapshot::new(&[], &[]),
            };
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
            theme_mode: ThemeMode::Dark,
            canvas_rect: None,
            current_scene: Scene::Graph,
            inspector_selected_node: None,
            inspector_search_text: String::new(),
            search_type: SearchType::AuthorName,
            search_input: String::new(),
            api_url,
            is_global_viewer,
            search_failed: Arc::new(Mutex::new(false)),
            is_fetching: Arc::new(Mutex::new(false)),
            highlighted_index: 0,
            suggestions: Arc::new(Mutex::new(std::collections::HashMap::new())),
        }
    }
}

impl eframe::App for App {
    fn ui(&mut self, app_ui: &mut egui::Ui, _frame: &mut eframe::Frame) {
        let ctx = app_ui.ctx().clone();

        ctx.set_visuals(self.theme.to_egui_visuals());

        let main_app_frame = egui::Frame::central_panel(&ctx.global_style())
            .fill(self.theme.master_bg)
            .inner_margin(6.0);

        egui::CentralPanel::default().frame(main_app_frame).show_inside(app_ui, |ui| {
            let state_arc = self.state.clone();
            let mut state_lock = state_arc.lock().unwrap();

            if let AppState::Ready { .. } = &mut *state_lock {
                self.render_search_bar(ui, &ctx);
            }
            match &mut *state_lock {
                AppState::Ready {
                    nodes,
                    edges,
                    raw_triples,
                    init_snapshot,
                } => {
                    ui.spacing_mut().interact_size.y = 19.0;

                    // scene select tabs
                    ui.add_space(1.0); // to ocd or not to ocd
                    ui.horizontal(|ui| {
                        let graph_bg = if self.current_scene == crate::Scene::Graph {
                            self.theme.menu_expand_bg
                        } else {
                            self.theme.button_bg
                        };
                        if ui.add(egui::Button::new("Graph View").fill(graph_bg)).clicked() {
                            self.current_scene = crate::Scene::Graph;
                        }

                        let analytics_bg = if self.current_scene == crate::Scene::Analytics {
                            self.theme.menu_expand_bg
                        } else {
                            self.theme.button_bg
                        };
                        if ui.add(egui::Button::new("Analytics View").fill(analytics_bg)).clicked() {
                            self.current_scene = crate::Scene::Analytics;
                        }

                        let inspector_bg = if self.current_scene == crate::Scene::NodeInspector {
                            self.theme.menu_expand_bg
                        } else {
                            self.theme.button_bg
                        };
                        if ui.add(egui::Button::new("Node Inspector View").fill(inspector_bg)).clicked() {
                            self.current_scene = crate::Scene::NodeInspector;
                        }

                        ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                            // theme button
                            let theme_string = match self.theme_mode {
                                ThemeMode::Dark => "Dark Mode",
                                ThemeMode::Light => "Light Mode",
                                ThemeMode::TestingRed => "Testing Red",
                            };

                            let theme_button = egui::Button::new(theme_string);

                            if ui.add(theme_button).clicked() {
                                match self.theme_mode {
                                    ThemeMode::Dark => {
                                        self.theme_mode = ThemeMode::Light;
                                        self.theme = Theme::light();
                                    }
                                    ThemeMode::Light => {
                                        self.theme_mode = ThemeMode::TestingRed;
                                        self.theme = Theme::testing_red();
                                    }
                                    ThemeMode::TestingRed => {
                                        self.theme_mode = ThemeMode::Dark;
                                        self.theme = Theme::dark();
                                    }
                                }
                            }

                            let mut dummy = 0;
                            egui::ComboBox::from_id_salt("export_menu")
                                .selected_text("Export")
                                .show_ui(ui, |ui| {
                                    if ui.selectable_value(&mut dummy, 1, "Export as SVG").clicked() {
                                        let _svg_data = crate::export::generate_svg(nodes, edges, &self.theme);
                                        log::info!("Generated SVG");
                                    }
                                    if ui.selectable_value(&mut dummy, 2, "Export as PNG").clicked() {
                                        log::info!("PNG export requested");
                                    }
                                    if ui.selectable_value(&mut dummy, 3, "Export as N3").clicked() {
                                        let _n3_data = crate::export::generate_n3(nodes, edges);
                                        log::info!("Generated N3");
                                    }
                                    if ui.selectable_value(&mut dummy, 4, "Export as JSON").clicked() {
                                        let _json_data = crate::export::generate_json(nodes, edges);
                                        log::info!("Generated JSON");
                                    }
                                });
                        });
                    });
                    ui.separator();

                    match self.current_scene {
                        crate::Scene::Graph => {
                            self.render_graph_scene(ui, &ctx, nodes, edges, init_snapshot);
                        }
                        crate::Scene::Analytics => {
                            self.render_analytics_scene(ui, nodes, edges, raw_triples);
                        }
                        crate::Scene::NodeInspector => {
                            self.render_inspector_scene(ui, nodes, edges);
                        }
                    }
                }
                AppState::Error(err_msg) => {
                    ui.heading("Something went wrong:");
                    ui.label(egui::RichText::new(err_msg.as_str()).color(self.theme.error_fg).strong());
                }
                AppState::Loading => {
                    ui.heading("Loading Workspace and Fetching Dictionaries...");
                    ui.add(egui::Spinner::new());
                }
            }
        });
    }
}

// native entrypoint
#[cfg(not(target_arch = "wasm32"))]
fn main() -> eframe::Result<()> {
    env_logger::init();

    let native_options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default().with_inner_size([800.0, 600.0]),
        ..Default::default()
    };

    eframe::run_native("Standalone Test App", native_options, Box::new(|cc| Ok(Box::new(App::new(cc)))))
}

// wasm entrypoint
#[cfg(target_arch = "wasm32")]
fn main() {
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
        use wasm_bindgen::JsCast;

        let document = web_sys::window().unwrap().document().unwrap();
        let canvas = document
            .get_element_by_id("the_canvas_id")
            .expect("Failed to find 'the_canvas_id' in DOM")
            .dyn_into::<web_sys::HtmlCanvasElement>()
            .expect("Element was not a HtmlCanvasElement");

        eframe::WebRunner::new()
            .start(canvas, web_options, Box::new(|cc| Ok(Box::new(App::new(cc)))))
            .await
            .expect("failed to start eframe");
    });
}
