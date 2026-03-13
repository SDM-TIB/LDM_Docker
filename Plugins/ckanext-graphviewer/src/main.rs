use eframe::egui;
use log::{error, info};
use oxttl::TurtleParser;
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use oxrdf::Triple;

const RDF_TYPE: &str = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";
const RDF_LABEL: &str = "http://www.w3.org/2000/01/rdf-schema#label";

const VCARD_FN: &str = "http://www.w3.org/2006/vcard/ns#fn";

const PRO_AUTHOR: &str = "http://purl.org/spar/pro/Author";
const DCAT_DISTRIBUTION: &str = "http://www.w3.org/ns/dcat#Distribution";
const DCAT_DISTRIBUTION_PROP: &str = "http://www.w3.org/ns/dcat#distribution";
const DCAT_DATASERVICE: &str = "http://www.w3.org/ns/dcat#DataService";
const DCAT_DATASET: &str = "http://www.w3.org/ns/dcat#Dataset";
const DCAT_KEYWORD_PROP: &str = "http://www.w3.org/ns/dcat#keyword";

const DCAT_LANDING_PAGE: &str = "http://www.w3.org/ns/dcat#landingPage";
const DCTERMS_DESCRIBED_BY: &str = "http://purl.org/dc/terms/isReferencedBy";
const DCTERMS_CITATION: &str = "http://purl.org/dc/terms/bibliographicCitation";

const VCARD_ORGANIZATION: &str = "http://www.w3.org/2006/vcard/ns#Organization";
const SKOS_CONCEPT: &str = "http://www.w3.org/2004/02/skos/core#Concept";

const DCTERMS_TITLE: &str = "http://purl.org/dc/terms/title";
const DCTERMS_MODIFIED: &str = "http://purl.org/dc/terms/modified";
const DCTERMS_LICENSE: &str = "http://purl.org/dc/terms/license";
const DCTERMS_DESCRIPTION: &str = "http://purl.org/dc/terms/description";
const DCTERMS_IDENTIFIER: &str = "http://purl.org/dc/terms/identifier";
const DCTERMS_ISSUED: &str = "http://purl.org/dc/terms/issued";
const DCTERMS_PUBLISHER: &str = "http://purl.org/dc/terms/publisher";
const DCTERMS_CREATOR: &str = "http://purl.org/dc/terms/creator";

// srtuct representing a subject or object
#[derive(Debug)]
struct RDFNode {
    id: String,
    label: String,
    rdf_type: String,
    node_type: String,
    pos: egui::Pos2,
}

// struct representing a predicate
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
        edges: HashMap<(String, String), RDFEdge>,
    },
}

struct RdfGraphApp {
    state: Arc<Mutex<AppState>>,
    color_map: HashMap<String, NodeColors>,
}

#[derive(Debug)]
struct NodeColors {
    normal: egui::Color32,
    selected: egui::Color32,
}

// obtain source ttl file
#[cfg(target_arch = "wasm32")]
fn get_ttl_url_from_current_path() -> Option<String> {
    let window = web_sys::window()?;
    let location = window.location();
    let pathname = location.pathname().ok()?;
    let pathname2 = pathname.strip_suffix("/graph")?;
    Some(format!("{}.ttl", pathname2))
}

struct ParsedTriple {
    subject: String,
    subject_type: String,
    predicate: String,
    object: String,
}

impl ParsedTriple {
    fn from_triple(triple: &Triple) -> Self {
        let (subject, subject_type) = match &triple.subject {
            oxrdf::NamedOrBlankNode::NamedNode(node) => {
                (node.as_str().to_string(), "NamedNode".to_string())
            }
            oxrdf::NamedOrBlankNode::BlankNode(node) => {
                (node.as_str().to_string(), "BlankNode".to_string())
            }
        };

        let object = match &triple.object {
            oxrdf::Term::NamedNode(node) => node.as_str().to_string(),
            oxrdf::Term::BlankNode(node) => node.as_str().to_string(),
            oxrdf::Term::Literal(literal) => literal.value().to_string(),
        };

        Self {
            subject,
            subject_type,
            predicate: triple.predicate.as_str().to_string(),
            object,
        }
    }
}

fn extract_label(uri: &str) -> String {
    uri.trim_matches('<')
        .trim_matches('>')
        .split('/')
        .last()
        .unwrap_or(uri)
        .to_string()
}

// TODO debug author
fn add_or_update_edge(
    edges: &mut HashMap<(String, String), RDFEdge>,
    source: String,
    target: String,
    label: String,
) {
    let key = (source.clone(), target.clone());
    edges
        .entry(key)
        .and_modify(|e| {
            if !e.label.contains(&label) {
                e.label.push_str(", ");
                e.label.push_str(&label);
            }
        })
        .or_insert(RDFEdge { source, target, label });
}

// parse ttl file and populate graph struct
fn parse_ttl_to_graph(ttl_text: &str) -> (HashMap<String, RDFNode>, HashMap<(String, String), RDFEdge>) {
    let mut nodes: HashMap<String, RDFNode> = HashMap::new();
    let mut edges: HashMap<(String, String), RDFEdge> = HashMap::new();

    let mut center_subject = String::new();
    let center_pos = egui::pos2(500.0, 600.0);

    let modified_pos = egui::pos2(200.0, 400.0);
    let issued_pos = egui::pos2(200.0, 500.0);
    let publisher_pos = egui::pos2(200.0, 800.0);

    let license_pos = egui::pos2(800.0, 700.0);
    let description_pos = egui::pos2(800.0, 600.0);
    let id_pos = egui::pos2(800.0, 800.0);

    let mut creator_pos = egui::pos2(250.0, 900.0);
    let mut distribution_pos = egui::pos2(750.0, 900.0);
    let mut keyword_pos = egui::pos2(400.0, 900.0);

    let mut citation_pos = egui::pos2(800.0, 300.0);
    let mut landing_page_pos = egui::pos2(800.0, 300.0);
    let mut described_by_pos = egui::pos2(600.0, 900.0);

    let iteration_delta = 50.0;

    let mut author_names: Vec<String> = Vec::new();

    let triples: Vec<Triple> = TurtleParser::new()
        .for_slice(ttl_text.as_bytes())
        .filter_map(|r| r.map_err(|e| error!("Parse error: {}", e)).ok())
        .collect();

    let parsed_triples: Vec<ParsedTriple> = triples.iter().map(|t| {
        // info!("{:?}", t);
        let pt = ParsedTriple::from_triple(t);
        // info!("triple:\n\ts: {}\n\tp: {}\n\to: {}\n", pt.subject, pt.predicate, pt.object);
        pt
    }).collect();

    let insert_literal_node = |nodes: &mut HashMap<String, RDFNode>,
    edges: &mut HashMap<(String, String), RDFEdge>,
    pt: &ParsedTriple,
    pos: egui::Pos2| {

        if nodes.contains_key(&pt.subject) {
            nodes.insert(
                pt.object.clone(),
                RDFNode {
                    id: pt.object.clone(),
                    label: pt.object.clone(),
                    rdf_type: "Literal".to_string(),
                    node_type: pt.subject_type.clone(),
                    pos,
                },
            );
            add_or_update_edge(edges, pt.subject.clone(), pt.object.clone(), extract_label(&pt.predicate));
        }
    };

    // 1. pass to find all types present in the ttl
    for pt in &parsed_triples {
        if pt.predicate == RDF_TYPE {
            match pt.object.as_str() {
                DCAT_DATASERVICE | DCAT_DATASET => {
                    center_subject = pt.subject.clone();
                    nodes.entry(pt.subject.clone())
                        .and_modify(|entry| {
                            entry.rdf_type.push_str(", ");
                            entry.rdf_type.push_str(&pt.object);
                        })
                        .or_insert_with(|| RDFNode {
                            id: pt.subject.clone(),
                            label: extract_label(&pt.subject),
                            rdf_type: pt.object.clone(),
                            node_type: pt.subject_type.clone(),
                            pos: center_pos,
                        });
                }
                PRO_AUTHOR | DCAT_DISTRIBUTION | SKOS_CONCEPT => {
                    nodes.insert(
                        pt.subject.clone(),
                        RDFNode {
                            id: pt.subject.clone(),
                            label: extract_label(&pt.subject),
                            rdf_type: pt.object.clone(),
                            node_type: pt.subject_type.clone(),
                            pos: egui::pos2(0.0, 0.0),
                        },
                    );
                }
                VCARD_ORGANIZATION => {
                    nodes.insert(
                        pt.subject.clone(),
                        RDFNode {
                            id: pt.subject.clone(),
                            label: extract_label(&pt.subject),
                            rdf_type: pt.object.clone(),
                            node_type: pt.subject_type.clone(),
                            pos: publisher_pos,
                        },
                    );
                }
                _ => {}
            }
        }
    }

    // 2. pass to fill in label and edges
for pt in &parsed_triples {
        let is_dataset_or_service = nodes.get(&pt.subject)
            .map(|n| n.rdf_type.contains("Dataset") || n.rdf_type.contains("Service"))
            .unwrap_or(false);

        match pt.predicate.as_str() {
            // Labels
            RDF_LABEL | DCTERMS_TITLE => {
                if let Some(entry) = nodes.get_mut(&pt.subject) {
                    entry.label.clear();
                    entry.label.push_str(&pt.object);
                }
            }
            DCTERMS_DESCRIPTION => {
                if pt.subject == center_subject {
                    insert_literal_node(&mut nodes, &mut edges, pt, description_pos);
                }
            }

            // Collect Author Names (vcard:fn)
            VCARD_FN => {
                if pt.subject == center_subject {
                    author_names.push(pt.object.clone());
                }
            }

            // Literals requiring Dataset/Service verification
            DCTERMS_MODIFIED => {
                if is_dataset_or_service {
                    insert_literal_node(&mut nodes, &mut edges, pt, modified_pos);
                }
            }
            DCTERMS_ISSUED => {
                if is_dataset_or_service {
                    insert_literal_node(&mut nodes, &mut edges, pt, issued_pos);
                }
            }
            DCTERMS_PUBLISHER => {
                if is_dataset_or_service {
                    add_or_update_edge(&mut edges, pt.subject.clone(), pt.object.clone(), extract_label(&pt.predicate));
                    if let Some(obj_entry) = nodes.get_mut(&pt.object) {
                        obj_entry.pos = publisher_pos;
                    }
                }
            }

            // General Literals
            DCTERMS_LICENSE => insert_literal_node(&mut nodes, &mut edges, pt, license_pos),
            DCTERMS_IDENTIFIER => insert_literal_node(&mut nodes, &mut edges, pt, id_pos),

            // Relational Edges
            DCTERMS_CREATOR => {
                add_or_update_edge(&mut edges, pt.subject.clone(), pt.object.clone(), extract_label(&pt.predicate));
                if let Some(entry) = nodes.get_mut(&pt.object) {
                    entry.pos = creator_pos;
                    creator_pos.y += iteration_delta;
                }
            }
            DCAT_DISTRIBUTION_PROP => {
                add_or_update_edge(&mut edges, pt.subject.clone(), pt.object.clone(), extract_label(&pt.predicate));
                if let Some(entry) = nodes.get_mut(&pt.object) {
                    entry.pos = distribution_pos;
                    distribution_pos.y += iteration_delta;
                }
            }
            DCAT_KEYWORD_PROP => {
                add_or_update_edge(&mut edges, pt.subject.clone(), pt.object.clone(), extract_label(&pt.predicate));
                if let Some(entry) = nodes.get_mut(&pt.object) {
                    entry.pos = keyword_pos;
                    keyword_pos.y += iteration_delta;
                }
            }
            DCAT_LANDING_PAGE => {
                add_or_update_edge(&mut edges, pt.subject.clone(), pt.object.clone(), extract_label(&pt.predicate));
                if let Some(entry) = nodes.get_mut(&pt.object) {
                    entry.pos = landing_page_pos;
                    landing_page_pos.y += iteration_delta;
                }
            }
            DCTERMS_DESCRIBED_BY => {
                add_or_update_edge(&mut edges, pt.subject.clone(), pt.object.clone(), extract_label(&pt.predicate));
                if let Some(entry) = nodes.get_mut(&pt.object) {
                    entry.pos = described_by_pos;
                    described_by_pos.y += iteration_delta;
                }
            }
            DCTERMS_CITATION => {
                add_or_update_edge(&mut edges, pt.subject.clone(), pt.object.clone(), extract_label(&pt.predicate));
                if let Some(entry) = nodes.get_mut(&pt.object) {
                    entry.pos = citation_pos;
                    citation_pos.y += iteration_delta;
                }
            }
            _ => {}
        }
    }

    // ----------------------------------------------------------------
    // CLEANUP: Resolve Author Names
    // Match the collected string literals to actual node labels.
    // ----------------------------------------------------------------
    for author_name in author_names {
        // Find the node ID whose label exactly matches the string literal
        if let Some((node_id, _)) = nodes.iter().find(|(_, n)| n.label == author_name) {
            // Update the edge to append "author"
            add_or_update_edge(&mut edges, center_subject.clone(), node_id.clone(), "author".to_string());
        }
    }

    (nodes, edges)
}
impl RdfGraphApp {
    pub fn new(cc: &eframe::CreationContext<'_>) -> Self {
        cc.egui_ctx.style_mut(|style| {
            style.interaction.tooltip_delay = 0.0;
        });

        let state = Arc::new(Mutex::new(AppState::Loading));

        let mut color_map = HashMap::new();
        color_map.insert(
            DCAT_DATASET.to_string(),
            NodeColors {
                normal: egui::Color32::from_rgb(255, 165, 0),
                selected: egui::Color32::from_rgb(255, 200, 100),
            },
        );
        color_map.insert(
            PRO_AUTHOR.to_string(),
            NodeColors {
                normal: egui::Color32::from_rgb(250, 50, 50),
                selected: egui::Color32::from_rgb(255, 100, 100),
            },
        );
        color_map.insert(
            DCAT_DISTRIBUTION.to_string(),
            NodeColors {
                normal: egui::Color32::from_rgb(50, 120, 220),
                selected: egui::Color32::from_rgb(100, 180, 255),
            },
        );
        color_map.insert(
            SKOS_CONCEPT.to_string(),
            NodeColors {
                normal: egui::Color32::from_rgb(50, 180, 50),
                selected: egui::Color32::from_rgb(120, 255, 120),
            },
        );
        color_map.insert(
            VCARD_ORGANIZATION.to_string(),
            NodeColors {
                normal: egui::Color32::from_rgb(150, 80, 220),
                selected: egui::Color32::from_rgb(200, 150, 255),
            },
        );
        color_map.insert(
            "Literal".to_string(),
            NodeColors {
                normal: egui::Color32::from_rgb(220, 200, 0),
                selected: egui::Color32::from_rgb(255, 240, 100),
            },
        );

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

        Self { state, color_map }
    }
}

impl eframe::App for RdfGraphApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            let mut state_lock = self.state.lock().unwrap();

            if let AppState::Ready { nodes, edges } = &mut *state_lock {
                let painter = ui.painter();

                // 1. edge line
                for edge in edges.values() {
                    if let (Some(s), Some(t)) = (nodes.get(&edge.source), nodes.get(&edge.target)) {
                        painter.line_segment([s.pos, t.pos], (2.0, egui::Color32::from_gray(100)));
                    }
                }

                // 2. edge label
                for edge in edges.values() {
                    if let (Some(s), Some(t)) = (nodes.get(&edge.source), nodes.get(&edge.target)) {
                        let center_point = s.pos + (t.pos - s.pos) * 0.5;

                        let galley = painter.layout_no_wrap(
                            edge.label.clone(),
                            egui::FontId::proportional(10.0),
                            egui::Color32::WHITE,
                        );

                        let text_rect = egui::Align2::CENTER_CENTER
                            .anchor_rect(egui::Rect::from_min_size(center_point, galley.size()));

                        painter.rect_filled(
                            text_rect.expand(2.0),
                            2.0,
                            egui::Color32::from_gray(10),
                        );

                        painter.galley(text_rect.min, galley, egui::Color32::WHITE);
                    }
                }

                // draw node
                for node in nodes.values_mut() {
                    let response = ui.interact(
                        egui::Rect::from_center_size(node.pos, egui::vec2(30.0, 30.0)),
                        ui.id().with(&node.id),
                        egui::Sense::click_and_drag(),
                    )
                        .on_hover_text(format!("ID : {}\nRDF Type : {}\nNode type : {}", node.id, node.rdf_type, node.node_type));

                    if response.dragged() {
                        node.pos += response.drag_delta();
                    }

                    let theme = self.color_map.get(&node.rdf_type).unwrap_or(&NodeColors {
                        normal: egui::Color32::GRAY,
                        selected: egui::Color32::WHITE,
                    });

                    let color = if response.hovered() { theme.selected } else { theme.normal };

                    // Node Circle
                    painter.circle_filled(node.pos, 15.0, color);

                    // Node Text
                    painter.text(
                        node.pos + egui::vec2(0.0, 20.0),
                        egui::Align2::CENTER_TOP,
                        &node.label,
                        egui::FontId::proportional(12.0),
                        egui::Color32::WHITE,
                    );
                }
            } else if let AppState::Error(err_msg) = &*state_lock {
                // Now the string is read and displayed on the screen!
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

#[cfg(target_arch = "wasm32")]
fn main() {
    eframe::WebLogger::init(log::LevelFilter::Debug).ok();
    let web_options = eframe::WebOptions::default();

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
