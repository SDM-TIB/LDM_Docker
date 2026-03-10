use eframe::egui;
use std::collections::{HashMap, HashSet};
use std::sync::{Arc, Mutex};
use oxttl::TurtleParser;
//use log::{info, error};
use log::error;

// struct that represents a subject or object
struct RDFNode {
    id: String,
    label: String,
    rdf_type: String,
    node_type: String,
    edges_from_center: i8,
    pos: egui::Pos2,
}

// struct that represents the predicate and links a subject to an object
#[derive(Clone, Hash, Eq, PartialEq)]
struct RDFEdge {
    source: String,
    target: String,
    label: String,
}

enum AppState {
    Loading,
    Error(String),
    Ready {
        nodes: HashMap<String, RDFNode>,
        edges: HashSet<RDFEdge>,
    },
}

struct RdfGraphApp {
    state: Arc<Mutex<AppState>>,
}

// parse the current path to get the ttl file we want to use
#[cfg(target_arch = "wasm32")]
fn get_ttl_url_from_current_path() -> Option<String> {
    let window = web_sys::window()?;

    let location = window.location();

    let pathname = location.pathname().ok()?;

    let pathname2 = pathname.strip_suffix("/graph")?;

    Some(format!("{}.ttl", pathname2))
}

// parse the content of the ttl file and populate the RDFNode and RDFEdge struct
fn parse_ttl_to_graph(ttl_text: &str) -> (HashMap<String, RDFNode>, HashSet<RDFEdge>) {
    let mut nodes: HashMap<String, RDFNode> = HashMap::new();
    let mut edges: HashSet<RDFEdge> = HashSet::new();

    let rdf_type_string = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";

    let center_pos = egui::pos2(500.0, 500.0);

    for triple in TurtleParser::new().for_slice(ttl_text.as_bytes()) {
        // info!("{:?}", triple);
        match triple {
            Ok(content) => {
                let subject_string;
                let subject_node_type;

                let object_string;
                let object_node_type;
                let mut object_rdf_type = "".to_string();

                match &content.subject {
                    oxrdf::NamedOrBlankNode::NamedNode(node) => {
                        subject_string = node.as_str().to_string();
                        subject_node_type = "NamedNode".to_string();
                    },
                    oxrdf::NamedOrBlankNode::BlankNode(node) => {
                        subject_string = node.as_str().to_string();
                        subject_node_type = "BlankNode".to_string();
                    },
                };

                let predicate_string =  &content.predicate.into_string();

                match &content.object {
                    oxrdf::Term::NamedNode(node) => {
                        object_string = node.as_str().to_string();
                        object_node_type = "NamedNode".to_string();
                    },
                    oxrdf::Term::BlankNode(node) => {
                        object_string = node.as_str().to_string();
                        object_node_type = "BlankNode".to_string();
                    },
                    oxrdf::Term::Literal(literal) => {
                        object_string = literal.value().to_string();
                        object_node_type = "Literal".to_string();
                        object_rdf_type = literal.datatype().to_string();
                    },
                };

                // info!("triple:\n\ts: {}\n\tp: {}\n\to: {}\n", subject_string, predicate_string, object_string);

                if predicate_string == &rdf_type_string {
                    if !nodes.contains_key(&subject_string) {
                        nodes.insert(subject_string.clone(), RDFNode {
                            id: subject_string.clone(),
                            label: extract_label(&subject_string),
                            rdf_type: object_string.clone(),
                            node_type: subject_node_type.clone(),
                            edges_from_center: -1,
                            pos: egui::pos2(0.0, 0.0),
                        });
                    }
                } else {
                    if !nodes.contains_key(&subject_string) {
                        nodes.insert(subject_string.clone(), RDFNode {
                            id: subject_string.clone(),
                            label: extract_label(&subject_string),
                            rdf_type: "".into(),
                            node_type: subject_node_type.clone(),
                            edges_from_center: -1,
                            pos: egui::pos2(0.0, 0.0),
                        });
                    }

                    if !nodes.contains_key(&object_string) {
                        nodes.insert(object_string.clone(), RDFNode {
                            id: object_string.clone(),
                            label: extract_label(&object_string),
                            rdf_type: object_rdf_type,
                            node_type: object_node_type.clone(),
                            edges_from_center: -1,
                            pos: egui::pos2(0.0, 0.0),
                        });
                    }

                    edges.insert(RDFEdge {
                        source: subject_string.clone(),
                        target: object_string.clone(),
                        label: extract_label(&predicate_string),
                    });
                }
            },
            Err(e) => {
                error!("got turtle parse error: {}", e);
            }
        };
    }

    // populate the structs
    if !nodes.is_empty() {
        let mut current_hop = 0;
        let mut nodes_updated = true;

        let mut parent_map: HashMap<String, String> = HashMap::new();

        for node in nodes.values_mut() {
            if node.rdf_type == "http://www.w3.org/ns/dcat#Dataset".to_string() {
                node.edges_from_center = current_hop;
                node.pos = center_pos;
                break;
            }
        }

        while nodes_updated {
            nodes_updated = false;

            let mut updates: Vec<(String, i8, String)> = Vec::new();

            for edge in &edges {
                if let Some(source_node) = nodes.get(&edge.source) {
                    if source_node.edges_from_center == current_hop {
                        updates.push((edge.target.clone(), current_hop + 1, edge.source.clone()));
                    }
                }
            }

            for (target_id, new_hop_count, source_id) in updates {
                if let Some(target_node) = nodes.get_mut(&target_id) {
                    if target_node.edges_from_center == -1 {
                        target_node.edges_from_center = new_hop_count;

                        parent_map.insert(target_id.clone(), source_id);
                        nodes_updated = true;
                    }
                }
            }
            current_hop += 1;
        }

        // position node in a circle around the center grouped by hops
        let mut hop_groups: HashMap<i8, Vec<String>> = HashMap::new();
        let mut max_hop = 0;

        for (id, node) in &nodes {
            hop_groups.entry(node.edges_from_center).or_default().push(id.clone());
            if node.edges_from_center > max_hop {
                max_hop = node.edges_from_center;
            }
        }

        let radius_step = 200.0;

        let mut node_angles: HashMap<String, f32> = HashMap::new();

        for hop in 1..=max_hop {
            if let Some(node_ids) = hop_groups.get(&hop) {
                let radius = (hop as f32) * radius_step;

                if hop == 1 {
                    let num_nodes = node_ids.len();
                    for (i, id) in node_ids.iter().enumerate() {
                        let angle = (i as f32) * std::f32::consts::TAU / (num_nodes as f32);
                        node_angles.insert(id.clone(), angle);

                        if let Some(node) = nodes.get_mut(id) {
                            node.pos = egui::pos2(
                                center_pos.x + radius * angle.cos(),
                                center_pos.y + radius * angle.sin(),
                            );
                        }
                    }
                } else {
                    let mut parent_to_children: HashMap<String, Vec<String>> = HashMap::new();
                    for id in node_ids {
                        if let Some(parent_id) = parent_map.get(id) {
                            parent_to_children.entry(parent_id.clone()).or_default().push(id.clone());
                        }
                    }

                    for (parent_id, children) in parent_to_children {
                        if let Some(&parent_angle) = node_angles.get(&parent_id) {
                            let num_children = children.len();

                            let spread = std::f32::consts::PI / (hop as f32);

                            for (i, child_id) in children.iter().enumerate() {
                                let offset = if num_children == 1 {
                                    0.0
                                } else {
                                    -spread / 2.0 + (spread * (i as f32) / ((num_children - 1) as f32))
                                };

                                let child_angle = parent_angle + offset;
                                node_angles.insert(child_id.clone(), child_angle);

                                if let Some(node) = nodes.get_mut(child_id) {
                                    node.pos = egui::pos2(
                                        center_pos.x + radius * child_angle.cos(),
                                        center_pos.y + radius * child_angle.sin(),
                                    );
                                }
                            }
                        }
                    }
                }
            }
        }

        // unreachable node
        if let Some(disconnected) = hop_groups.get(&-1) {
            let radius = (max_hop as f32 + 1.0) * radius_step;
            let num_nodes = disconnected.len();
            for (i, id) in disconnected.iter().enumerate() {
                let angle = (i as f32) * std::f32::consts::TAU / (num_nodes as f32);
                if let Some(node) = nodes.get_mut(id) {
                    node.pos = egui::pos2(
                        center_pos.x + radius * angle.cos(),
                        center_pos.y + radius * angle.sin(),
                    );
                }
            }
        }
    }

    //info!("Finished parsing: {} nodes, {} edges", nodes.len(), edges.len());
    (nodes, edges)
}

fn extract_label(uri: &str) -> String {
    uri.trim_matches('<').trim_matches('>').split('/').last().unwrap_or(uri).to_string()
}

// render loop
impl RdfGraphApp {
    pub fn new(cc: &eframe::CreationContext<'_>) -> Self {
        let state = Arc::new(Mutex::new(AppState::Loading));

        #[cfg(target_arch = "wasm32")]
        {
            if let Some(target_url) = get_ttl_url_from_current_path() {
                let state_clone = state.clone();
                let ctx_clone = cc.egui_ctx.clone();

                let request = ehttp::Request::get(&target_url);

                ehttp::fetch(request, move |response| {
                    let mut app_state = state_clone.lock().unwrap();
                    match response {
                        Ok(res) => {
                            if let Some(text) = res.text() {
                                let (nodes, edges) = parse_ttl_to_graph(text);
                                *app_state = AppState::Ready { nodes, edges };
                            } else {
                                *app_state = AppState::Error("Failed to read text from TTL".into());
                            }
                        }
                        Err(err) => *app_state = AppState::Error(format!("Network Error: {}", err)),
                    }
                    ctx_clone.request_repaint();
                });
            } else {
                *state.lock().unwrap() = AppState::Error("Could not determine TTL path from URL".into());
            }
        }

        Self { state }
    }
}

impl eframe::App for RdfGraphApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            let mut state = self.state.lock().unwrap();

            match &mut *state {
                AppState::Loading => {
                    ui.heading("Downloading and Parsing RDF Graph...");
                    ui.spinner();
                }
                AppState::Error(err) => {
                    ui.colored_label(egui::Color32::RED, format!("Error: {}", err));
                }
                AppState::Ready { nodes, edges } => {
                    let painter = ui.painter();

                    for edge in edges.iter() {
                        if let (Some(source_node), Some(target_node)) = (nodes.get(&edge.source), nodes.get(&edge.target)) {

                            let midpoint: egui::Pos2;

                            if edge.source == edge.target {
                                let node_radius = 15.0;
                                let loop_radius = 20.0;

                                let loop_center = source_node.pos + egui::vec2(0.0, -(node_radius + loop_radius - 5.0));

                                painter.circle_stroke(
                                    loop_center,
                                    loop_radius,
                                    (2.0, egui::Color32::from_gray(100))
                                );

                                midpoint = loop_center + egui::vec2(0.0, -loop_radius);

                            } else {
                                let p1 = source_node.pos;
                                let p2 = target_node.pos;

                                painter.line_segment([p1, p2], (2.0, egui::Color32::from_gray(100)));

                                midpoint = egui::pos2(
                                    (p1.x + p2.x) / 2.0,
                                    (p1.y + p2.y) / 2.0,
                                );
                            }

                            let font_id = egui::FontId::proportional(10.0);
                            let text_color = egui::Color32::WHITE;
                            let bg_color = egui::Color32::from_rgb(60, 60, 60);

                            let galley = painter.layout_no_wrap(edge.label.clone(), font_id, text_color);
                            let text_rect = egui::Rect::from_center_size(midpoint, galley.size());

                            painter.rect_filled(text_rect.expand(2.0), 2.0, bg_color);

                            painter.galley(text_rect.left_top(), galley, egui::Color32::BROWN);
                        }
                    }

                    for node in nodes.values_mut() {
                        let node_radius = 15.0;
                        let rect = egui::Rect::from_center_size(
                            node.pos,
                            egui::vec2(node_radius * 2.0, node_radius * 2.0)
                        );

                        let response = ui.interact(rect, ui.id().with(&node.id), egui::Sense::click_and_drag());

                        if response.dragged() {
                            node.pos += response.drag_delta();
                        }

                        let color: egui::Color32;

                        if node.node_type == "BlankNode".to_string() {
                            color = if response.hovered() || response.dragged() {
                                egui::Color32::LIGHT_GREEN
                            } else {
                                egui::Color32::GREEN
                            };
                        } else {
                            color = if response.hovered() || response.dragged() {
                                egui::Color32::LIGHT_BLUE
                            } else {
                                egui::Color32::BLUE
                            };
                        }

                        painter.circle_filled(node.pos, node_radius, color);
                        painter.text(
                            node.pos + egui::vec2(0.0, node_radius + 5.0),
                            egui::Align2::CENTER_TOP,
                            &node.label,
                            egui::FontId::proportional(14.0),
                            egui::Color32::WHITE,
                        );

                        // Tooltip showing metadata
                        if response.hovered() || response.clicked() {
                            egui::show_tooltip(ctx, response.id, |ui| {
                                ui.heading(&node.label);
                                ui.separator();
                                ui.label(format!("URI: {}", node.id));
                                ui.label(format!("rdf type: {}", node.rdf_type));
                                ui.label(format!("node type: {}", node.node_type));
                                ui.label(format!("hops from center: {}", node.edges_from_center));
                            });
                        }
                    }
                }
            }
        });
    }
}

#[cfg(target_arch = "wasm32")]
fn main() {
    // init logger
    eframe::WebLogger::init(log::LevelFilter::Debug).ok();

    // set defaults
    let web_options = eframe::WebOptions::default();

    // start the webrunner
    wasm_bindgen_futures::spawn_local(async {
        eframe::WebRunner::new()
            .start(
                "the_canvas_id",
                web_options,
                Box::new(|cc| Box::new(RdfGraphApp::new(cc))),
            )
            .await
            .expect("failed to start eframe");
    });
}
