use crate::{AppState, graph_processor, parser::RawTriple};
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
                if let Ok(json) = serde_json::from_str::<serde_json::Value>(text) {
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

                        // B. Convert the API JSON into RawTriples
                        if let Some(results) = json.get("results").and_then(|r| r.as_array()) {
                            for item in results {
                                let dataset = item.get("dataset").and_then(|v| v.as_str()).unwrap_or("").to_string();
                                let author = item.get("author").and_then(|v| v.as_str()).unwrap_or("").to_string();
                                let author_label = item.get("author_label").and_then(|v| v.as_str()).unwrap_or("").to_string();
                                let title = item.get("title").and_then(|v| v.as_str()).unwrap_or("").to_string();
                                let license = item.get("license").and_then(|v| v.as_str()).unwrap_or("").to_string();

                                if !dataset.is_empty() {
                                    raw_triples.push(RawTriple {
                                        subject: format!("<{}>", dataset),
                                        predicate: "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>".to_string(),
                                        object: "<http://www.w3.org/ns/dcat#Dataset>".to_string(),
                                        is_object_literal: false,
                                    });

                                    if !title.is_empty() {
                                        raw_triples.push(RawTriple {
                                            subject: format!("<{}>", dataset),
                                            predicate: "<http://purl.org/dc/terms/title>".to_string(),
                                            object: format!("\"{}\"", title),
                                            is_object_literal: true,
                                        });
                                    }

                                    if !license.is_empty() {
                                        raw_triples.push(RawTriple {
                                            subject: format!("<{}>", dataset),
                                            predicate: "<http://purl.org/dc/terms/license>".to_string(),
                                            object: format!("<{}>", license),
                                            is_object_literal: false,
                                        });
                                    }

                                    if !author.is_empty() {
                                        raw_triples.push(RawTriple {
                                            subject: format!("<{}>", dataset),
                                            predicate: "<http://purl.org/dc/terms/creator>".to_string(),
                                            object: format!("<{}>", author),
                                            is_object_literal: false,
                                        });

                                        raw_triples.push(RawTriple {
                                            subject: format!("<{}>", author),
                                            predicate: "<http://purl.org/spar/pro/authorOf>".to_string(),
                                            object: format!("<{}>", dataset),
                                            is_object_literal: false,
                                        });

                                        if !author_label.is_empty() {
                                            raw_triples.push(RawTriple {
                                                subject: format!("<{}>", author),
                                                predicate: "<http://www.w3.org/2000/01/rdf-schema#label>".to_string(),
                                                object: format!("\"{}\"", author_label),
                                                is_object_literal: true,
                                            });
                                        }
                                    }
                                }
                            }
                        }

                        // C. Feed everything back into Graph Processor
                        let (mut new_nodes, mut new_edges) = graph_processor::build_ui_graph(raw_triples.clone());

                        // FIX HIERARCHY
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

                        // D. RESTORE OLD STATE & LAYOUT NEW NODES
                        let clicked_pos = old_nodes.get(&clicked_node_id).map(|n| n.pos).unwrap_or(egui::Pos2::ZERO);
                        let mut new_node_indices = Vec::new();

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
                                n.visible = true;
                                n.expanded = false;
                                new_node_indices.push(i);
                            }
                        }

                        let total_new = new_node_indices.len();
                        if total_new > 0 {
                            let mut angle: f32 = 0.0;
                            let angle_step = std::f32::consts::TAU / (total_new as f32);
                            let spawn_radius = 200.0 * (1.0 + (total_new as f32 / 10.0));

                            for idx in new_node_indices {
                                let target_pos = clicked_pos + egui::vec2(
                                    angle.cos() * spawn_radius,
                                    angle.sin() * spawn_radius,
                                );
                                angle += angle_step;

                                new_nodes[idx].pos = target_pos;
                                new_nodes[idx].original_pos = target_pos;
                            }
                        }

                        // E. RESTORE EDGE VISIBILITY
                        for edge in &mut new_edges {
                            let s_id = &new_nodes[edge.source].id;
                            let t_id = &new_nodes[edge.target].id;

                            if old_edges_vis.contains(&(s_id.clone(), t_id.clone())) {
                                edge.visible = true;
                            } else if new_nodes[edge.source].visible && new_nodes[edge.target].visible {
                                edge.visible = false;
                            }
                        }

                        // F. Overwrite the state
                        *nodes = new_nodes;
                        *edges = new_edges;
                    }
                }
            }
        }
        ctx.request_repaint();
    });
}
