use eframe::egui;
use log::{error, info};
use oxttl::TurtleParser;
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
//use log::error;

// struct that represents a subject or object
#[derive(Debug)]
struct RDFNode {
    id: String,
    label: String,
    rdf_type: String,
    node_type: String,
    edges_from_center: i8,
    pos: egui::Pos2,
}

// struct that represents the predicate and links a subject to an object
#[derive(Debug, Clone, Hash, Eq, PartialEq)]
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
        edges: HashMap<u64, RDFEdge>,
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
fn parse_ttl_to_graph(ttl_text: &str) -> (HashMap<String, RDFNode>, HashMap<u64, RDFEdge>) {
    let mut nodes: HashMap<String, RDFNode> = HashMap::new();
    let mut edges: HashMap<u64, RDFEdge> = HashMap::new();

    let mut edge_counter = 1;

    let rdf_type_string = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";

    let creator_string = "http://purl.org/spar/pro/Author";

    let distribution_string = "http://www.w3.org/ns/dcat#Distribution";

    let organization_string = "http://www.w3.org/2006/vcard/ns#Organization";

    let center_string_service = "http://www.w3.org/ns/dcat#DataService";
    let center_string_dataset = "http://www.w3.org/ns/dcat#Dataset";
    let center_pos = egui::pos2(500.0, 200.0);

    for triple in TurtleParser::new().for_slice(ttl_text.as_bytes()) {
        // info!("{:?}", triple);
        match triple {
            Ok(content) => {
                let subject_string;
                let subject_node_type;

                let object_string;

                match &content.subject {
                    oxrdf::NamedOrBlankNode::NamedNode(node) => {
                        subject_string = node.as_str().to_string();
                        subject_node_type = "NamedNode".to_string();
                    }
                    oxrdf::NamedOrBlankNode::BlankNode(node) => {
                        subject_string = node.as_str().to_string();
                        subject_node_type = "BlankNode".to_string();
                    }
                };

                let predicate_string = &content.predicate.into_string();

                match &content.object {
                    oxrdf::Term::NamedNode(node) => {
                        object_string = node.as_str().to_string();
                    }
                    oxrdf::Term::BlankNode(node) => {
                        object_string = node.as_str().to_string();
                    }
                    oxrdf::Term::Literal(literal) => {
                        object_string = literal.value().to_string();
                    }
                };

                // info!("triple:\n\ts: {}\n\tp: {}\n\to: {}\n", subject_string, predicate_string, object_string);

                // dataset / service
                // get the center node
                // TODO fix entry and unwrap
                if (predicate_string == rdf_type_string && object_string == center_string_service)
                    || (predicate_string == rdf_type_string
                        && object_string == center_string_dataset)
                {
                    match nodes.get_mut(&subject_string) {
                        Some(entry) => {
                            entry.rdf_type.push(',');
                            entry.rdf_type.push(' ');
                            entry.rdf_type.push_str(&object_string);
                        }
                        None => {
                            nodes.insert(
                                subject_string.clone(),
                                RDFNode {
                                    id: subject_string.clone(),
                                    label: extract_label(&subject_string),
                                    rdf_type: object_string.clone(),
                                    node_type: subject_node_type.clone(),
                                    edges_from_center: 0,
                                    pos: center_pos,
                                },
                            );
                        }
                    }
                }

                // creator
                if (predicate_string == rdf_type_string && object_string == creator_string)
                    || (predicate_string == rdf_type_string && object_string == creator_string)
                {
                    nodes.insert(
                        subject_string.clone(),
                        RDFNode {
                            id: subject_string.clone(),
                            label: extract_label(&subject_string),
                            rdf_type: object_string.clone(),
                            node_type: subject_node_type.clone(),
                            edges_from_center: -1,
                            pos: egui::pos2(0.0, 0.0),
                        },
                    );
                }

                // distribution
                if (predicate_string == rdf_type_string && object_string == distribution_string)
                    || (predicate_string == rdf_type_string && object_string == distribution_string)
                {
                    nodes.insert(
                        subject_string.clone(),
                        RDFNode {
                            id: subject_string.clone(),
                            label: extract_label(&subject_string),
                            rdf_type: object_string.clone(),
                            node_type: subject_node_type.clone(),
                            edges_from_center: -1,
                            pos: egui::pos2(0.0, 0.0),
                        },
                    );
                }

                // organization
                if (predicate_string == rdf_type_string && object_string == organization_string)
                    || (predicate_string == rdf_type_string && object_string == organization_string)
                {
                    nodes.insert(
                        subject_string.clone(),
                        RDFNode {
                            id: subject_string.clone(),
                            label: extract_label(&subject_string),
                            rdf_type: object_string.clone(),
                            node_type: subject_node_type.clone(),
                            edges_from_center: -1,
                            pos: egui::pos2(0.0, 0.0),
                        },
                    );
                }
            }
            Err(e) => {
                error!("got turtle parse error: {}", e);
            }
        };
    }

    // 2. iteration to add label to node and edges
    for triple in TurtleParser::new().for_slice(ttl_text.as_bytes()) {
        let label_string = "http://www.w3.org/2000/01/rdf-schema#label";
        let title_string = "http://purl.org/dc/terms/title";

        let id_string = "http://purl.org/dc/terms/identifier";
        let issue_string = "http://purl.org/dc/terms/issued";
        let mod_string = "http://purl.org/dc/terms/modified";
        let publisher_string = "http://purl.org/dc/terms/publisher";

        match triple {
            Ok(content) => {
                let subject_string;
                let subject_node_type;

                let object_string;

                match &content.subject {
                    oxrdf::NamedOrBlankNode::NamedNode(node) => {
                        subject_string = node.as_str().to_string();
                        subject_node_type = "NamedNode".to_string();
                    }
                    oxrdf::NamedOrBlankNode::BlankNode(node) => {
                        subject_string = node.as_str().to_string();
                        subject_node_type = "BlankNode".to_string();
                    }
                };

                let predicate_string = &content.predicate.into_string();

                match &content.object {
                    oxrdf::Term::NamedNode(node) => {
                        object_string = node.as_str().to_string();
                    }
                    oxrdf::Term::BlankNode(node) => {
                        object_string = node.as_str().to_string();
                    }
                    oxrdf::Term::Literal(literal) => {
                        object_string = literal.value().to_string();
                    }
                };

                if predicate_string == label_string {
                    match nodes.get_mut(&subject_string) {
                        Some(entry) => {
                            entry.label.clear();
                            entry.label.push_str(&object_string);
                        }
                        None => {}
                    }
                }

                if predicate_string == title_string {
                    match nodes.get_mut(&subject_string) {
                        Some(entry) => {
                            entry.label.clear();
                            entry.label.push_str(&object_string);
                        }
                        None => {}
                    }
                }

                if predicate_string == id_string {
                    match nodes.get(&subject_string) {
                        Some(_) => {
                            nodes.insert(
                                object_string.clone(),
                                RDFNode {
                                    id: object_string.clone(),
                                    label: object_string.clone(),
                                    rdf_type: "Literal".to_string(),
                                    node_type: subject_node_type.clone(),
                                    edges_from_center: -1,
                                    pos: egui::pos2(500.0, 100.0),
                                },
                            );
                            edges.insert(
                                edge_counter,
                                RDFEdge {
                                    source: subject_string.clone(),
                                    target: object_string.clone(),
                                    label: extract_label(&predicate_string),
                                },
                            );
                            edge_counter += 1;
                        }
                        None => {}
                    }
                }

                if predicate_string == issue_string {
                    match nodes.get(&subject_string) {
                        Some(entry) => {
                            if entry.rdf_type.contains("Dataset")
                                || entry.rdf_type.contains("Service")
                            {
                                match nodes.get(&subject_string) {
                                    Some(_) => {
                                        nodes.insert(
                                            object_string.clone(),
                                            RDFNode {
                                                id: object_string.clone(),
                                                label: object_string.clone(),
                                                rdf_type: "Literal".to_string(),
                                                node_type: subject_node_type.clone(),
                                                edges_from_center: -1,
                                                pos: egui::pos2(200.0, 100.0),
                                            },
                                        );
                                        edges.insert(
                                            edge_counter,
                                            RDFEdge {
                                                source: subject_string.clone(),
                                                target: object_string.clone(),
                                                label: extract_label(&predicate_string),
                                            },
                                        );
                                        edge_counter += 1;
                                    }
                                    None => {}
                                }
                            }
                        }
                        None => {}
                    }
                }

                if predicate_string == mod_string {
                    match nodes.get(&subject_string) {
                        Some(entry) => {
                            if entry.rdf_type.contains("Dataset")
                                || entry.rdf_type.contains("Service")
                            {
                                match nodes.get(&subject_string) {
                                    Some(_) => {
                                        nodes.insert(
                                            object_string.clone(),
                                            RDFNode {
                                                id: object_string.clone(),
                                                label: object_string.clone(),
                                                rdf_type: "Literal".to_string(),
                                                node_type: subject_node_type.clone(),
                                                edges_from_center: -1,
                                                pos: egui::pos2(800.0, 100.0),
                                            },
                                        );
                                        edges.insert(
                                            edge_counter,
                                            RDFEdge {
                                                source: subject_string.clone(),
                                                target: object_string.clone(),
                                                label: extract_label(&predicate_string),
                                            },
                                        );
                                        edge_counter += 1;
                                    }
                                    None => {}
                                }
                            }
                        }
                        None => {}
                    }
                }

                if predicate_string == publisher_string {
                    match nodes.get(&subject_string) {
                        Some(entry) => {
                            if entry.rdf_type.contains("Dataset")
                                || entry.rdf_type.contains("Service")
                            {
                                edges.insert(
                                    edge_counter,
                                    RDFEdge {
                                        source: subject_string.clone(),
                                        target: object_string.clone(),
                                        label: extract_label(&predicate_string),
                                    },
                                );
                                edge_counter += 1;

                                match nodes.get_mut(&object_string) {
                                    Some(entry) => {
                                        entry.pos = egui::pos2(500.0, 300.0);
                                    }
                                    None => {}
                                }
                            }
                        }
                        None => {}
                    }
                }
            }
            Err(e) => {
                error!("got turtle parse error: {}", e);
            }
        }
    }

    let mut creator_pos = egui::pos2(200.0, 300.0);
    let mut distribution_pos = egui::pos2(800.0, 300.0);

    let iteration_delta = 80.0;

    for triple in TurtleParser::new().for_slice(ttl_text.as_bytes()) {
        let creator_string = "http://purl.org/dc/terms/creator";
        let distribution_string = "http://www.w3.org/ns/dcat#distribution";

        match triple {
            Ok(content) => {
                let subject_string;

                let object_string;

                match &content.subject {
                    oxrdf::NamedOrBlankNode::NamedNode(node) => {
                        subject_string = node.as_str().to_string();
                    }
                    oxrdf::NamedOrBlankNode::BlankNode(node) => {
                        subject_string = node.as_str().to_string();
                    }
                };

                let predicate_string = &content.predicate.into_string();

                match &content.object {
                    oxrdf::Term::NamedNode(node) => {
                        object_string = node.as_str().to_string();
                    }
                    oxrdf::Term::BlankNode(node) => {
                        object_string = node.as_str().to_string();
                    }
                    oxrdf::Term::Literal(literal) => {
                        object_string = literal.value().to_string();
                    }
                };

                if predicate_string == creator_string {
                    edges.insert(
                        edge_counter,
                        RDFEdge {
                            source: subject_string.clone(),
                            target: object_string.clone(),
                            label: extract_label(&predicate_string),
                        },
                    );
                    edge_counter += 1;

                    match nodes.get_mut(&object_string) {
                        Some(entry) => {
                            entry.pos = creator_pos.clone();
                            creator_pos.y += iteration_delta;
                        }
                        None => {}
                    }
                }
                if predicate_string == distribution_string {
                    edges.insert(
                        edge_counter,
                        RDFEdge {
                            source: subject_string.clone(),
                            target: object_string.clone(),
                            label: extract_label(&predicate_string),
                        },
                    );
                    edge_counter += 1;
                    match nodes.get_mut(&object_string) {
                        Some(entry) => {
                            entry.pos = distribution_pos;
                            distribution_pos.y += iteration_delta;
                        }
                        None => {}
                    }
                }
            }
            Err(e) => {
                error!("got turtle parse error: {}", e);
            }
        }
    }
    (nodes, edges)
}

fn extract_label(uri: &str) -> String {
    uri.trim_matches('<')
        .trim_matches('>')
        .split('/')
        .last()
        .unwrap_or(uri)
        .to_string()
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
                *state.lock().unwrap() =
                    AppState::Error("Could not determine TTL path from URL".into());
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

                    for (_, edge) in edges {
                        if let (Some(source_node), Some(target_node)) =
                            (nodes.get(&edge.source), nodes.get(&edge.target))
                        {
                            let midpoint: egui::Pos2;

                            if edge.source == edge.target {
                                let node_radius = 15.0;
                                let loop_radius = 20.0;

                                let loop_center = source_node.pos
                                    + egui::vec2(0.0, -(node_radius + loop_radius - 5.0));

                                painter.circle_stroke(
                                    loop_center,
                                    loop_radius,
                                    (2.0, egui::Color32::from_gray(100)),
                                );

                                midpoint = loop_center + egui::vec2(0.0, -loop_radius);
                            } else {
                                let p1 = source_node.pos;
                                let p2 = target_node.pos;

                                painter
                                    .line_segment([p1, p2], (2.0, egui::Color32::from_gray(100)));

                                midpoint = egui::pos2((p1.x + p2.x) / 2.0, (p1.y + p2.y) / 2.0);
                            }

                            let font_id = egui::FontId::proportional(10.0);
                            let text_color = egui::Color32::WHITE;
                            let bg_color = egui::Color32::from_rgb(60, 60, 60);

                            let galley =
                                painter.layout_no_wrap(edge.label.clone(), font_id, text_color);
                            let text_rect = egui::Rect::from_center_size(midpoint, galley.size());

                            painter.rect_filled(text_rect.expand(2.0), 2.0, bg_color);

                            painter.galley(text_rect.left_top(), galley, egui::Color32::BROWN);
                        }
                    }

                    for node in nodes.values_mut() {
                        let node_radius = 15.0;
                        let rect = egui::Rect::from_center_size(
                            node.pos,
                            egui::vec2(node_radius * 2.0, node_radius * 2.0),
                        );

                        let response = ui.interact(
                            rect,
                            ui.id().with(&node.id),
                            egui::Sense::click_and_drag(),
                        );

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
