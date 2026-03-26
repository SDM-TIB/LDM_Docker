use eframe::egui;
use log::{error, info};
use oxttl::TurtleParser;
use oxttl::N3Parser;
use std::collections::{HashMap, HashSet, VecDeque};
use oxrdf::Triple;

// constants used for filtering
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

#[derive(Debug, Clone)]
pub struct Node {
    pub id: String,
    pub label: String,
    pub rdf_type: String,
    pub node_type: String,
    pub pos: egui::Pos2,
    pub original_pos: egui::Pos2,
    pub attributes: HashMap<String, String>,
    pub expanded: bool,
    pub visible: bool,
    pub parent_index: Option<usize>,
}

#[derive(Debug, Clone, Hash, Eq, PartialEq)]
pub struct Edge {
    pub source: usize,
    pub target: usize,
    pub label: String,
    pub visible: bool,
}

struct ParsedTriple {
    subject: String,
    subject_type: String,
    predicate: String,
    object: String,
}

impl ParsedTriple {
    fn from_n3_strings(subject: String, predicate: String, object: String) -> Self {
        let subject_type = if subject.starts_with('<') {
            "NamedNode".to_string()
        } else if subject.starts_with("_:") {
            "BlankNode".to_string()
        } else if subject.starts_with('?') {
            "Variable".to_string()
        } else if subject.starts_with('{') {
            "Formula".to_string()
        } else {
            "Unknown".to_string()
        };

        let clean_subject = subject.trim_matches('<').trim_matches('>').to_string();
        let clean_predicate = predicate.trim_matches('<').trim_matches('>').to_string();

        let clean_object = if object.starts_with('"') {
            object.split('"').nth(1).unwrap_or(&object).to_string()
        } else {
            object.trim_matches('<').trim_matches('>').to_string()
        };

        Self {
            subject: clean_subject,
            subject_type,
            predicate: clean_predicate,
            object: clean_object,
        }
    }
}

// show a pretty string as label under a node circle
fn extract_label(uri: &str) -> String {
    uri.trim_matches('<')
        .trim_matches('>')
        .split('/')
        .last()
        .unwrap_or(uri)
        .to_string()
}

// used to add author to creator edge
fn add_or_update_edge(
    edges_map: &mut HashMap<(String, String), String>,
    source: String,
    target: String,
    label: String,
) {
    let key = (source, target);
    edges_map
        .entry(key)
        .and_modify(|existing_label| {
            if !existing_label.contains(&label) {
                existing_label.push_str(", ");
                existing_label.push_str(&label);
            }
        })
        .or_insert(label);
}

pub fn parse_n3_to_graph(file_content: &str) -> (Vec<Node>, Vec<Edge>) {
    let mut nodes_map: HashMap<String, Node> = HashMap::new();
    let mut edges_map: HashMap<(String, String), String> = HashMap::new();

    let mut center_subject = String::new();
    let mut author_names: Vec<String> = Vec::new();

    let parsed_triples: Vec<ParsedTriple> = N3Parser::new()
        .for_slice(file_content.as_bytes())
        .filter_map(|r| r.map_err(|e| error!("Parse error: {}", e)).ok())
        .map(|quad| {
            ParsedTriple::from_n3_strings(
                quad.subject.to_string(),
                quad.predicate.to_string(),
                quad.object.to_string()
            )
        })
        .collect();

    // iteration 1 type discovery
    for pt in &parsed_triples {
        if pt.predicate == RDF_TYPE {
            match pt.object.as_str() {
                DCAT_DATASERVICE | DCAT_DATASET => {
                    center_subject = pt.subject.clone();
                    nodes_map.entry(pt.subject.clone())
                        .and_modify(|entry| {
                            entry.rdf_type.push_str(", ");
                            entry.rdf_type.push_str(&pt.object);
                        })
                        .or_insert_with(|| Node {
                            id: pt.subject.clone(),
                            label: extract_label(&pt.subject),
                            rdf_type: pt.object.clone(),
                            node_type: pt.subject_type.clone(),
                            pos: egui::Pos2::ZERO,
                            original_pos: egui::Pos2::ZERO,
                            attributes: HashMap::new(),
                            expanded: false,
                            visible: true,
                            parent_index: None,
                        });
                }
                PRO_AUTHOR | DCAT_DISTRIBUTION | SKOS_CONCEPT | VCARD_ORGANIZATION => {
                    nodes_map.insert(
                        pt.subject.clone(),
                        Node {
                            id: pt.subject.clone(),
                            label: extract_label(&pt.subject),
                            rdf_type: pt.object.clone(),
                            node_type: pt.subject_type.clone(),
                            pos: egui::Pos2::ZERO,
                            original_pos: egui::Pos2::ZERO,
                            attributes: HashMap::new(),
                            expanded: false,
                            visible: false,
                            parent_index: None,
                        },
                    );
                }
                _ => {}
            }
        }
    }

    // iteration 2 identify labels literals and edges
for pt in &parsed_triples {
        let pred_label = extract_label(&pt.predicate);

        // Identify if this property is a structural edge linking two real nodes
        let is_structural_edge = match pt.predicate.as_str() {
            DCTERMS_PUBLISHER | DCTERMS_CREATOR | DCAT_DISTRIBUTION_PROP |
            DCAT_KEYWORD_PROP | DCAT_LANDING_PAGE | DCTERMS_DESCRIBED_BY |
            DCTERMS_CITATION | VCARD_FN => true,
            _ => false,
        };

        if let Some(node) = nodes_map.get_mut(&pt.subject) {
            // Only add to attributes if it's NOT a structural edge
            if pt.predicate != RDF_TYPE && pred_label != "label" && pred_label != "title" && !is_structural_edge {
                node.attributes
                    .entry(pred_label.clone())
                    .and_modify(|val| {
                        if !val.contains(&pt.object) {
                            val.push_str(", ");
                            val.push_str(&pt.object);
                        }
                    })
                    .or_insert(pt.object.clone());
            }
        }

        match pt.predicate.as_str() {
            RDF_LABEL | DCTERMS_TITLE => {
                if let Some(entry) = nodes_map.get_mut(&pt.subject) {
                    entry.label.clear();
                    entry.label.push_str(&pt.object);
                }
            }
            VCARD_FN => {
                if pt.subject == center_subject {
                    author_names.push(pt.object.clone());
                }
            }
            DCTERMS_PUBLISHER | DCTERMS_CREATOR | DCAT_DISTRIBUTION_PROP |
            DCAT_KEYWORD_PROP | DCAT_LANDING_PAGE | DCTERMS_DESCRIBED_BY |
            DCTERMS_CITATION => {
                // Create the permanent connecting line!
                add_or_update_edge(&mut edges_map, pt.subject.clone(), pt.object.clone(), pred_label);
            }
            _ => {} // Everything else (descriptions, dates) is safely inside the attributes backpack!
        }
    }

    // // iteration 2 identify labels literals and edges
    // for pt in &parsed_triples {
    //     let pred_label = extract_label(&pt.predicate);

    //     if let Some(node) = nodes_map.get_mut(&pt.subject) {

    //         if pt.predicate != RDF_TYPE && pred_label != "label" && pred_label != "title" {

    //             node.attributes
    //                 .entry(pred_label.clone())
    //                 .and_modify(|val| {
    //                     if !val.contains(&pt.object) {
    //                         val.push_str(", ");
    //                         val.push_str(&pt.object);
    //                     }
    //                 })
    //                 .or_insert(pt.object.clone());
    //         }
    //     }

    //     let is_dataset_or_service = nodes_map.get(&pt.subject)
    //         .map(|n| n.rdf_type.contains("Dataset") || n.rdf_type.contains("Service"))
    //         .unwrap_or(false);

    //     match pt.predicate.as_str() {
    //         RDF_LABEL | DCTERMS_TITLE => {
    //             if let Some(entry) = nodes_map.get_mut(&pt.subject) {
    //                 entry.label.clear();
    //                 entry.label.push_str(&pt.object);
    //             }
    //         }
    //         DCTERMS_DESCRIPTION => {
    //             if pt.subject == center_subject {
    //                 insert_literal_node(&mut nodes_map, &mut edges_map, pt);
    //             }
    //         }
    //         VCARD_FN => {
    //             if pt.subject == center_subject {
    //                 author_names.push(pt.object.clone());
    //             }
    //         }
    //         DCTERMS_MODIFIED | DCTERMS_ISSUED | DCTERMS_LICENSE | DCTERMS_IDENTIFIER => {
    //             if is_dataset_or_service || pt.predicate == DCTERMS_LICENSE || pt.predicate == DCTERMS_IDENTIFIER {
    //                 insert_literal_node(&mut nodes_map, &mut edges_map, pt);
    //             }
    //         }
    //         DCTERMS_PUBLISHER | DCTERMS_CREATOR | DCAT_DISTRIBUTION_PROP | DCAT_KEYWORD_PROP | DCAT_LANDING_PAGE | DCTERMS_DESCRIBED_BY | DCTERMS_CITATION => {
    //             add_or_update_edge(&mut edges_map, pt.subject.clone(), pt.object.clone(), extract_label(&pt.predicate));
    //         }
    //         _ => {}
    //     }
    // }

    // add author to label
    for author_name in author_names {
        if let Some((node_id, _)) = nodes_map.iter().find(|(_, n)| n.label == author_name) {
            add_or_update_edge(&mut edges_map, center_subject.clone(), node_id.clone(), "author".to_string());
        }
    }

    // adjust positoin to be circular around center node
    let mut adjacency: HashMap<String, Vec<String>> = HashMap::new();
    for (src, tgt) in edges_map.keys() {
        adjacency.entry(src.clone()).or_default().push(tgt.clone());
    }

    let mut visited = HashSet::new();
    let root_pos = egui::pos2(0.0, 0.0);

    let start_node = if !center_subject.is_empty() {
        center_subject.clone()
    } else if let Some(first) = nodes_map.keys().next() {
        first.clone()
    } else {
        String::new()
    };

    if !start_node.is_empty() {
        if let Some(root_node) = nodes_map.get_mut(&start_node) {
            root_node.pos = root_pos;
        }
        visited.insert(start_node.clone());

        let mut queue = VecDeque::new();
        queue.push_back((start_node, root_pos, 250.0, 0.0, std::f32::consts::TAU));

        while let Some((curr_id, parent_pos, radius, start_angle, end_angle)) = queue.pop_front() {
            if let Some(children) = adjacency.get(&curr_id) {
                let unvisited_children: Vec<String> = children.iter()
                    .filter(|c| !visited.contains(*c))
                    .cloned()
                    .collect();

                let n = unvisited_children.len();
                if n > 0 {
                    let angle_step = (end_angle - start_angle) / (n as f32);

                    for (i, child_id) in unvisited_children.into_iter().enumerate() {
                        visited.insert(child_id.clone());

                        let child_angle = start_angle + (i as f32 + 0.5) * angle_step;
                        let child_pos = egui::pos2(
                            parent_pos.x + radius * child_angle.cos(),
                            parent_pos.y + radius * child_angle.sin()
                        );

                        if let Some(node) = nodes_map.get_mut(&child_id) {
                            node.pos = child_pos;
                        }

                        let new_radius = radius * 0.7;
                        let cone_width = angle_step * 0.9;
                        let new_start = child_angle - cone_width / 2.0;
                        let new_end = child_angle + cone_width / 2.0;

                        queue.push_back((child_id, child_pos, new_radius, new_start, new_end));
                    }
                }
            }
        }
    }

    let mut unvisited_idx = 0;
    for (id, node) in nodes_map.iter_mut() {
        if !visited.contains(id) {
            node.pos = egui::pos2(50.0 + (unvisited_idx as f32 * 60.0), 50.0);
            unvisited_idx += 1;
        }
    }

    // convert hashmap into vector
    let mut nodes: Vec<Node> = Vec::with_capacity(nodes_map.len());
    let mut id_to_index: HashMap<String, usize> = HashMap::new();

    for (id, mut node) in nodes_map {
        id_to_index.insert(id, nodes.len());

        node.original_pos = node.pos;

        nodes.push(node);
    }

    let mut edges: Vec<Edge> = Vec::with_capacity(edges_map.len());
    for ((source_id, target_id), label) in edges_map {
        if let (Some(&source_idx), Some(&target_idx)) = (id_to_index.get(&source_id), id_to_index.get(&target_id)) {
            edges.push(Edge {
                source: source_idx,
                target: target_idx,
                label: label,
                visible: false,
            });
        }
    }

    (nodes, edges)
}
