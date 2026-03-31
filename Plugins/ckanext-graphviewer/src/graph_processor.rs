use crate::parser::RawTriple;
use eframe::egui;
use std::collections::{HashMap, HashSet, VecDeque};

const RDF_TYPE: &str = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";

#[derive(Debug, Clone)]
pub struct Node {
    pub id: String,
    pub label: String,
    pub rdf_type: String,
    pub node_type: String,
    pub pos: egui::Pos2,
    pub original_pos: egui::Pos2,
    pub expanded: bool,
    pub visible: bool,
    pub parent_index: Option<usize>,
    pub properties: Vec<(String, String)>,
    pub api_fetched: bool,
}

#[derive(Debug, Clone, Hash, Eq, PartialEq)]
pub struct Edge {
    pub source: usize,
    pub target: usize,
    pub label: String,
    pub reverse_label: Option<String>,
    pub visible: bool,
    pub bidirectional: bool,
}

// used to display the label of a node
fn extract_label(uri_or_literal: &str) -> String {
    if uri_or_literal.starts_with('"') {
        return uri_or_literal
            .split('"')
            .nth(1)
            .unwrap_or(uri_or_literal)
            .to_string();
    }
    let cleaned = uri_or_literal.trim_matches('<').trim_matches('>');
    cleaned
        .split('#')
        .last()
        .unwrap_or(cleaned)
        .split('/')
        .last()
        .unwrap_or(cleaned)
        .to_string()
}

// output a lean vec of filtered information
pub fn build_ui_graph(triples: Vec<RawTriple>) -> (Vec<Node>, Vec<Edge>) {
    let mut nodes_map: HashMap<String, Node> = HashMap::new();
    let mut edges_map: HashMap<(String, String), Vec<String>> = HashMap::new();

    // nodes
    for pt in &triples {
        let clean_sub = pt.subject.trim_matches('<').trim_matches('>').to_string();
        let clean_pred = pt.predicate.trim_matches('<').trim_matches('>').to_string();
        let pred_label = extract_label(&pt.predicate);
        let clean_obj = if pt.is_object_literal {
            pt.object.clone()
        } else {
            pt.object.trim_matches('<').trim_matches('>').to_string()
        };

        // ensure subject node exists
        nodes_map.entry(clean_sub.clone()).or_insert_with(|| Node {
            id: clean_sub.clone(),
            label: extract_label(&clean_sub),
            rdf_type: String::new(),
            node_type: if pt.subject.starts_with("_:") {
                "BlankNode".into()
            } else {
                "NamedNode".into()
            },
            pos: egui::Pos2::ZERO,
            original_pos: egui::Pos2::ZERO,
            expanded: false,
            visible: false,
            parent_index: None,
            properties: Vec::new(),
            api_fetched: false,
        });

        let is_type_pred = clean_pred == RDF_TYPE.trim_matches('<').trim_matches('>');

        // ensure object node exists
        if pred_label != "label" && pred_label != "title" && pred_label != "fn" && !is_type_pred {
            nodes_map.entry(clean_obj.clone()).or_insert_with(|| Node {
                id: clean_obj.clone(),
                label: extract_label(&clean_obj),
                rdf_type: if pt.is_object_literal {
                    "Literal".to_string()
                } else {
                    String::new()
                },
                node_type: if pt.is_object_literal {
                    "Attribute".to_string()
                } else {
                    "NamedNode".to_string()
                },
                pos: egui::Pos2::ZERO,
                original_pos: egui::Pos2::ZERO,
                expanded: false,
                visible: false,
                parent_index: None,
                properties: Vec::new(),
                api_fetched: false,
            });
        }

        if let Some(node) = nodes_map.get_mut(&clean_sub) {
            node.properties
                .push((pred_label.clone(), clean_obj.clone()));
        }

        // apply rules based on predicate
        if clean_pred == RDF_TYPE.trim_matches('<').trim_matches('>') {
            if let Some(node) = nodes_map.get_mut(&clean_sub) {
                if !node.rdf_type.is_empty() {
                    node.rdf_type.push_str(", ");
                }
                node.rdf_type.push_str(&clean_obj);

                // dataset dataservice
                if clean_obj.contains("Dataset") || clean_obj.contains("DataService") {
                    node.visible = true;
                }
            }
        } else if pred_label == "label" || pred_label == "title" {
            // set label string of parent
            if let Some(node) = nodes_map.get_mut(&clean_sub) {
                node.label = extract_label(&clean_obj);
            }
        } else if pred_label == "fn" {
            // ignore vcard:fn entirely
            continue;
        } else {
            // all other edges
            let src = clean_sub.clone();
            let tgt = clean_obj.clone();
            let lbl = pred_label.clone();

            let key = (src.clone(), tgt.clone());
            let entry = edges_map.entry(key).or_insert_with(Vec::new);
            if !entry.contains(&lbl) {
                entry.push(lbl.clone());
            }

            // Inject 'author' into the forward path deterministically!
            if lbl == "authorOf" {
                let reverse_key = (tgt, src);
                let rev_entry = edges_map.entry(reverse_key).or_insert_with(Vec::new);
                let author_lbl = "author".to_string();

                if !rev_entry.contains(&author_lbl) {
                    rev_entry.push(author_lbl);
                }
            }
        }
    }

    // circular layout
    let mut adjacency: HashMap<String, Vec<String>> = HashMap::new();
    for (src, tgt) in edges_map.keys() {
        adjacency.entry(src.clone()).or_default().push(tgt.clone());
    }

    let mut visited = HashSet::new();
    let root_pos = egui::pos2(0.0, 0.0);

    // center
    let start_node = nodes_map
        .iter()
        .find(|(_, n)| n.rdf_type.contains("Dataset") || n.rdf_type.contains("DataService"))
        .map(|(id, _)| id.clone())
        .unwrap_or_else(|| nodes_map.keys().next().cloned().unwrap_or_default());

    if !start_node.is_empty() {
        if let Some(root_node) = nodes_map.get_mut(&start_node) {
            root_node.pos = root_pos;
        }
        visited.insert(start_node.clone());

        let mut queue = VecDeque::new();
        queue.push_back((start_node.clone(), root_pos, 250.0, 0.0, std::f32::consts::TAU));

        while let Some((curr_id, parent_pos, radius, start_angle, end_angle)) = queue.pop_front() {
            if let Some(children) = adjacency.get(&curr_id) {
                let unvisited_children: Vec<String> = children
                    .iter()
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
                            parent_pos.y + radius * child_angle.sin(),
                        );
                        if let Some(node) = nodes_map.get_mut(&child_id) {
                            node.pos = child_pos;
                        }

                        let new_radius = radius * 0.7;
                        let cone_width = angle_step * 0.9;
                        queue.push_back((
                            child_id,
                            child_pos,
                            new_radius,
                            child_angle - cone_width / 2.0,
                            child_angle + cone_width / 2.0,
                        ));
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

    // cleanup
    // sort the edge keys
    let mut sorted_keys: Vec<_> = edges_map.keys().collect();
    sorted_keys.sort_by(|a, b| {
        let a_is_root = nodes_map.get(&a.0).map_or(false, |n| {
            n.rdf_type.contains("Dataset") || n.rdf_type.contains("DataService")
        });
        let b_is_root = nodes_map.get(&b.0).map_or(false, |n| {
            n.rdf_type.contains("Dataset") || n.rdf_type.contains("DataService")
        });
        b_is_root.cmp(&a_is_root)
    });

    // build vector
    let mut nodes: Vec<Node> = Vec::with_capacity(nodes_map.len());
    let mut id_to_index: HashMap<String, usize> = HashMap::new();

    for (id, mut node) in nodes_map {
        id_to_index.insert(id, nodes.len());
        node.original_pos = node.pos;
        nodes.push(node);
    }

    let mut edges: Vec<Edge> = Vec::new();
    let mut processed_edges = HashSet::new();

    for key in sorted_keys {
        if processed_edges.contains(key) {
            continue;
        }

        let (source_id, target_id) = key;

        let mut fwd_list = edges_map.get(key).unwrap().clone();
        fwd_list.sort();
        let label = fwd_list.join(", ");

        let reverse_key = &(target_id.clone(), source_id.clone());
        let is_bidirectional = edges_map.contains_key(reverse_key);
        let mut rev_label_opt = None;

        if is_bidirectional {
            processed_edges.insert(reverse_key.clone());

            let mut rev_list = edges_map.get(reverse_key).unwrap().clone();
            rev_list.sort();
            let reverse_label = rev_list.join(", ");

            if label != reverse_label {
                rev_label_opt = Some(reverse_label);
            }
        }

        processed_edges.insert(key.clone());

        if let (Some(&source_idx), Some(&target_idx)) =
            (id_to_index.get(source_id), id_to_index.get(target_id))
        {
            edges.push(Edge {
                source: source_idx,
                target: target_idx,
                label: label,
                reverse_label: rev_label_opt,
                visible: false,
                bidirectional: is_bidirectional,
            });
        }
    }

    // expand center dataset block
    if let Some(&root_idx) = id_to_index.get(&start_node) {
        nodes[root_idx].expanded = true;
        for edge in &mut edges {
            // Outgoing edges
            if edge.source == root_idx {
                edge.visible = true;
                nodes[edge.target].visible = true;
            } 
            // Incoming edges
            else if edge.target == root_idx {
                edge.visible = true;
                nodes[edge.source].visible = true;
            }
        }
    }

    (nodes, edges)
}
