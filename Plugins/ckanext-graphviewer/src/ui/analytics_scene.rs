use crate::App;
use crate::graph_processor::{Edge, Node};
use crate::parser::RawTriple;
use eframe::egui;

impl App {
    pub fn render_analytics_scene(&mut self, ui: &mut egui::Ui, nodes: &[Node], edges: &[Edge], raw_triples: &[RawTriple]) {
        // render analytics
        egui::ScrollArea::vertical().auto_shrink([false, false]).show(ui, |ui| {
            ui.add_space(1.0);

            // calculate graph statistics
            let mut unique_subjects = std::collections::HashSet::new();
            let mut unique_predicates = std::collections::HashSet::new();
            let mut unique_objects = std::collections::HashSet::new();
            let mut unique_classes = std::collections::HashSet::new();
            let mut unique_instances = std::collections::HashSet::new();
            let mut object_properties = std::collections::HashSet::new();
            let mut datatype_properties = std::collections::HashSet::new();
            let mut namespaces = std::collections::HashSet::new();

            let rdf_type_uri = "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>";

            // Helper to rip namespaces out of URIs
            let extract_namespace = |uri: &str| -> Option<String> {
                let clean = uri.trim_matches('<').trim_matches('>');
                if let Some(idx) = clean.rfind('#').or_else(|| clean.rfind('/')) {
                    Some(clean[..=idx].to_string())
                } else {
                    None
                }
            };

            for t in raw_triples.iter() {
                unique_subjects.insert(&t.subject);
                unique_predicates.insert(&t.predicate);
                unique_objects.insert(&t.object);

                // Check Ontology Classes & Instances
                if t.predicate == rdf_type_uri {
                    unique_classes.insert(&t.object);
                    unique_instances.insert(&t.subject);
                }

                // Separate Datatype vs Object Properties
                if t.is_object_literal {
                    datatype_properties.insert(&t.predicate);
                } else {
                    object_properties.insert(&t.predicate);
                }

                // Extract Namespaces
                if let Some(ns) = extract_namespace(&t.subject) {
                    namespaces.insert(ns);
                }
                if let Some(ns) = extract_namespace(&t.predicate) {
                    namespaces.insert(ns);
                }
                if !t.is_object_literal {
                    if let Some(ns) = extract_namespace(&t.object) {
                        namespaces.insert(ns);
                    }
                }
            }

            let total_triples = raw_triples.len();
            let total_nodes = nodes.len();
            let total_edges = edges.len();
            let visible_nodes = nodes.iter().filter(|n| n.visible).count();
            let visible_edges = edges.iter().filter(|n| n.visible).count();
            let uri_nodes = nodes.iter().filter(|n| n.node_type == "NamedNode").count();
            let literal_nodes = nodes.iter().filter(|n| n.node_type == "Attribute").count();
            let blank_nodes = nodes.iter().filter(|n| n.node_type == "BlankNode").count();

            // calculate node types
            let mut type_counts = std::collections::HashMap::new();
            for n in nodes.iter() {
                if n.rdf_type.is_empty() {
                    *type_counts.entry("Untyped Node".to_string()).or_insert(0) += 1;
                } else {
                    // Split the string in case the node has multiple types!
                    for single_type in n.rdf_type.split(", ") {
                        // Clean up the URI to get just the display name
                        let display_name = single_type.split('#').last().unwrap_or(single_type);
                        let display_name = display_name.split('/').last().unwrap_or(display_name).to_string();
                        *type_counts.entry(display_name).or_insert(0) += 1;
                    }
                }
            }

            // Convert to a vector and sort alphabetically
            let mut sorted_types: Vec<(String, i32)> = type_counts.into_iter().collect();
            sorted_types.sort_by(|a, b| a.0.to_lowercase().cmp(&b.0.to_lowercase()));

            // draw the 2x2 dashboard
            let card_height = 260.0;

            let mut total_byte_size: f64 = 0.0;
            let mut dataset_count = 0;
            let mut author_count = 0;
            let mut publication_count = 0;

            for node in nodes.iter() {
                let type_lower = node.rdf_type.to_lowercase();
                if type_lower.contains("dataset") { dataset_count += 1; }
                if type_lower.contains("author") || type_lower.contains("person") { author_count += 1; }
                if type_lower.contains("publication") || type_lower.contains("article") || type_lower.contains("paper") { publication_count += 1; }

                for (key, value) in &node.properties {
                    if key.to_lowercase().contains("bytesize") {
                        let clean_val = value.split('^').next().unwrap_or(value).trim_matches('"');
                        if let Ok(size) = clean_val.parse::<f64>() {
                            total_byte_size += size;
                        }
                    }
                }
            }

            let format_bytes = |bytes: f64| -> String {
                if bytes > 1_073_741_824.0 { format!("{:.2} GB", bytes / 1_073_741_824.0) }
                else if bytes > 1_048_576.0 { format!("{:.2} MB", bytes / 1_048_576.0) }
                else if bytes > 1024.0 { format!("{:.2} KB", bytes / 1024.0) }
                else { format!("{} B", bytes.round()) }
            };

            // row 1
            ui.columns(2, |cols| {
                // left
                cols[0].group(|ui| {
                    ui.set_min_height(card_height);
                    ui.heading(egui::RichText::new("Triple Composition").color(self.theme.text_fg));
                    ui.add_space(10.0);

                    ui.horizontal(|ui| {
                        ui.strong("Total Triples:");
                        ui.label(total_triples.to_string());
                    });
                    ui.horizontal(|ui| {
                        ui.strong("Total Nodes:");
                        ui.label(format!("{} ({} visible)", total_nodes, visible_nodes));
                    });
                    ui.horizontal(|ui| {
                        ui.strong("Total Edges:");
                        ui.label(format!("{} ({} visible)", total_edges, visible_edges));
                    });
                    ui.add_space(5.0);
                    ui.horizontal(|ui| {
                        ui.strong("URI Nodes:");
                        ui.label(uri_nodes.to_string());
                    });
                    ui.horizontal(|ui| {
                        ui.strong("Literal Nodes:");
                        ui.label(literal_nodes.to_string());
                    });
                    ui.horizontal(|ui| {
                        ui.strong("Blank Nodes:");
                        ui.label(blank_nodes.to_string());
                    });
                    ui.add_space(5.0);
                    ui.horizontal(|ui| {
                        ui.strong("Unique Subjects:");
                        ui.label(unique_subjects.len().to_string());
                    });
                    ui.horizontal(|ui| {
                        ui.strong("Unique Predicates:");
                        ui.label(unique_predicates.len().to_string());
                    });
                    ui.horizontal(|ui| {
                        ui.strong("Unique Objects:");
                        ui.label(unique_objects.len().to_string());
                    });
                });

                // right
                cols[1].group(|ui| {
                    ui.set_min_height(card_height);
                    ui.heading(egui::RichText::new("Ontology Statistics").color(self.theme.text_fg));
                    ui.add_space(10.0);

                    ui.horizontal(|ui| {
                        ui.strong("Classes:");
                        ui.label(unique_classes.len().to_string());
                    });
                    ui.horizontal(|ui| {
                        ui.strong("Instances:");
                        ui.label(unique_instances.len().to_string());
                    });
                    ui.add_space(5.0);
                    ui.horizontal(|ui| {
                        ui.strong("Object Properties:");
                        ui.label(object_properties.len().to_string());
                    });
                    ui.horizontal(|ui| {
                        ui.strong("Datatype Properties:");
                        ui.label(datatype_properties.len().to_string());
                    });
                    ui.add_space(5.0);
                    ui.horizontal(|ui| {
                        ui.strong("Namespaces:");
                        ui.label(namespaces.len().to_string());
                    });
                });
            });

            ui.add_space(5.0);

            // ROW 2
            ui.columns(2, |cols| {
                // left
                cols[0].group(|ui| {
                    ui.set_min_height(card_height);
                    ui.heading(egui::RichText::new("Node Types Breakdown").color(self.theme.text_fg));
                    ui.add_space(10.0);

                    egui::ScrollArea::vertical()
                        .id_salt("types_breakdown_scroll")
                        .max_height(card_height - 50.0)
                        .show(ui, |ui| {
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
                        });
                });

                // right
                cols[1].group(|ui| {
                    ui.set_min_height(card_height);
                    ui.heading(egui::RichText::new("Knowledge Graph Information").color(self.theme.text_fg));
                    ui.add_space(10.0);

                    // Data Size
                    ui.horizontal(|ui| {
                        ui.strong("Distribution addative Size:");
                        if total_byte_size > 0.0 {
                            ui.label(format_bytes(total_byte_size));
                        } else {
                            ui.label("Unknown (No byteSize fields found)");
                        }
                    });

                    ui.add_space(5.0);

                    // Network Health
                    let avg_degree = if total_nodes > 0 { (edges.len() * 2) as f32 / total_nodes as f32 } else { 0.0 };
                    ui.horizontal(|ui| {
                        ui.strong("Average Node Connectivity:");
                        ui.label(format!("{:.1} edges / node", avg_degree));
                    });
                });
            });
        });
    }
}
