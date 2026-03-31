use crate::{AppState, graph_processor, parser};
use eframe::egui;
use std::sync::{Arc, Mutex};

pub fn fetch_author_datasets(
    ctx: egui::Context,
    state: Arc<Mutex<AppState>>,
    clicked_node_id: String,
    orcid: String,
) {
    let url = format!("http://194.95.157.131:5742/get_dataset_attributes_by_author_orcid?orcid={}", orcid);
    let request = ehttp::Request::get(&url);

    ehttp::fetch(request, move |response| {
        if let Ok(res) = response {
            if let Some(text) = res.text() {
                
                // 1 & 2. DELEGATE PARSING TO PARSER.RS
                let new_triples = parser::parse_author_datasets_json(&text);
                
                if new_triples.is_empty() {
                    return; 
                }

                let mut state_lock = state.lock().unwrap();

                if let AppState::Ready { raw_triples, nodes, edges, .. } = &mut *state_lock {

                    // A. SNAPSHOT THE OLD STATE
                    let mut old_nodes = std::collections::HashMap::new();
                    for n in nodes.iter() {
                        old_nodes.insert(n.id.clone(), n.clone());
                    }

                    let mut old_edges_vis = std::collections::HashSet::new();
                    for e in edges.iter() {
                        if e.visible {
                            let s_id = nodes[e.source].id.clone();
                            let t_id = nodes[e.target].id.clone();
                            old_edges_vis.insert((s_id, t_id));
                        }
                    }

                    // B. APPEND NEW DATA & REBUILD
                    raw_triples.extend(new_triples);
                    let (mut new_nodes, mut new_edges) = graph_processor::build_ui_graph(raw_triples.clone());

                    // C. FIX HIERARCHY (Datasets remain children of the Author)
                    for edge in &mut new_edges {
                        let s_id = &new_nodes[edge.source].id;
                        let t_id = &new_nodes[edge.target].id;

                        let source_is_old = old_nodes.contains_key(s_id);
                        let target_is_old = old_nodes.contains_key(t_id);

                        if target_is_old && !source_is_old {
                            std::mem::swap(&mut edge.source, &mut edge.target);
                            if let Some(rev) = edge.reverse_label.clone() {
                                edge.reverse_label = Some(edge.label.clone());
                                edge.label = rev;
                            }
                        }
                    }

                    // D. IDENTIFY DIRECT CHILDREN & PROPERTIES
                    let clicked_pos = old_nodes.get(&clicked_node_id).map(|n| n.pos).unwrap_or(egui::Pos2::ZERO);
                    
                    let mut direct_new_children = std::collections::HashSet::new();
                    for edge in new_edges.iter() {
                        let s_id = &new_nodes[edge.source].id;
                        let t_id = &new_nodes[edge.target].id;
                        if s_id == &clicked_node_id && !old_nodes.contains_key(t_id) {
                            direct_new_children.insert(t_id.clone());
                        }
                    }

                    let mut properties_of_new = std::collections::HashMap::new();
                    for edge in new_edges.iter() {
                        let s_id = &new_nodes[edge.source].id;
                        let t_id = &new_nodes[edge.target].id;
                        if direct_new_children.contains(s_id) && !old_nodes.contains_key(t_id) {
                            properties_of_new.entry(s_id.clone()).or_insert_with(Vec::new).push(t_id.clone());
                        }
                    }

                    // E. SET NEW VISIBILITY & EXPANDED STATE
                    let mut new_dataset_indices = Vec::new();

                    for (i, n) in new_nodes.iter_mut().enumerate() {
                        if let Some(old_n) = old_nodes.get(&n.id) {
                            n.pos = old_n.pos;
                            n.original_pos = old_n.original_pos;
                            n.visible = old_n.visible;
                            
                            if n.id == clicked_node_id {
                                n.expanded = true;
                            } else {
                                n.expanded = old_n.expanded;
                            }
                        } else {
                            if direct_new_children.contains(&n.id) {
                                // Datasets are visible AND immediately expanded!
                                n.visible = true;
                                n.expanded = true; 
                                new_dataset_indices.push(i);
                            } else {
                                // Properties are visible because their dataset is expanded!
                                n.visible = true;
                                n.expanded = false;
                            }
                        }
                    }

                    // F. LAYOUT THE EXPANDED GRAPH
                    let total_datasets = new_dataset_indices.len();
                    if total_datasets > 0 {
                        let mut angle: f32 = 0.0;
                        let angle_step = std::f32::consts::TAU / (total_datasets as f32);
                        // Wider radius so the properties don't overlap the author
                        let dataset_radius = 280.0 * (1.0 + (total_datasets as f32 / 10.0));

                        for idx in new_dataset_indices {
                            let dataset_id = new_nodes[idx].id.clone();
                            
                            let target_pos = clicked_pos + egui::vec2(
                                angle.cos() * dataset_radius,
                                angle.sin() * dataset_radius,
                            );
                            angle += angle_step;

                            new_nodes[idx].pos = target_pos;
                            new_nodes[idx].original_pos = target_pos;

                            // Second Ring: Layout the properties around the expanded Dataset
                            if let Some(props) = properties_of_new.get(&dataset_id) {
                                let mut prop_angle: f32 = 0.0;
                                let prop_angle_step = std::f32::consts::TAU / (props.len().max(1) as f32);
                                let prop_radius = 120.0; // Tighter radius for properties

                                for prop_id in props {
                                    if let Some(prop_idx) = new_nodes.iter().position(|n| &n.id == prop_id) {
                                        let prop_pos = target_pos + egui::vec2(
                                            prop_angle.cos() * prop_radius,
                                            prop_angle.sin() * prop_radius,
                                        );
                                        prop_angle += prop_angle_step;
                                        
                                        new_nodes[prop_idx].pos = prop_pos;
                                        new_nodes[prop_idx].original_pos = prop_pos;
                                    }
                                }
                            }
                        }
                    }

                    // G. RESTORE & SHOW NEW EDGES
                    for edge in &mut new_edges {
                        let s_id = &new_nodes[edge.source].id;
                        let t_id = &new_nodes[edge.target].id;

                        if old_edges_vis.contains(&(s_id.clone(), t_id.clone())) {
                            edge.visible = true; // Old visible edges
                        } else if s_id == &clicked_node_id && direct_new_children.contains(t_id) {
                            edge.visible = true; // Author -> Dataset edge
                        } else if direct_new_children.contains(s_id) && !old_nodes.contains_key(t_id) {
                            edge.visible = true; // Dataset -> Property edge (because dataset is expanded)
                        } else {
                            edge.visible = false;
                        }
                    }

                    *nodes = new_nodes;
                    *edges = new_edges;
                }
            }
        }
        ctx.request_repaint();
    });
}
