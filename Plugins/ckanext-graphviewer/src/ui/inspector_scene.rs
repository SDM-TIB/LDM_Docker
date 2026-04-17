use crate::App;
use crate::graph_processor::{Edge, Node};
use eframe::egui;

impl App {
    pub fn render_inspector_scene(&mut self, ui: &mut egui::Ui, nodes: &mut [Node], edges: &mut [Edge]) {
        // render node inspector
        egui::ScrollArea::vertical().auto_shrink([false, false]).show(ui, |ui| {
            ui.add_space(10.0);

            // Fetch all non-literal nodes for the dropdown
            let mut sorted_nodes: Vec<_> = nodes.iter().filter(|n| n.node_type != "Attribute").collect();
            sorted_nodes.sort_by(|a, b| a.label.to_lowercase().cmp(&b.label.to_lowercase()));

            // 1. Draw the Dropdown Menu
            ui.horizontal(|ui| {
                ui.label("Select a Node:");

                let selected_label = if let Some(id) = &self.inspector_selected_node {
                    nodes
                        .iter()
                        .find(|n| n.id == *id)
                        .map(|n| n.label.clone())
                        .unwrap_or_else(|| "Unknown Node".to_string())
                } else {
                    "--- Select a Node ---".to_string()
                };

                egui::ComboBox::from_id_salt("node_inspector_dropdown")
                    .width(ui.available_width())
                    .height(ui.ctx().content_rect().height())
                    .selected_text(selected_label)
                    .show_ui(ui, |ui| {
                        for node in sorted_nodes {
                            let uri_tail = node.id.split('/').last().unwrap_or(&node.id).split('#').last().unwrap_or(&node.id);
                            let display_text = format!("{} ({})", node.label, uri_tail);

                            ui.selectable_value(&mut self.inspector_selected_node, Some(node.id.clone()), display_text);
                        }
                    });
            });

            ui.add_space(10.0);
            ui.separator();
            ui.add_space(10.0);

            let total_width = ui.available_width();
            let grid_spacing = 20.0;
            let col1_width = (total_width - grid_spacing) * 0.30;
            let col2_width = (total_width - grid_spacing) * 0.70;

            if let Some(selected_id) = self.inspector_selected_node.clone() {
                if let Some(node_idx) = nodes.iter().position(|n| n.id == selected_id) {
                    let node = &nodes[node_idx];

                    // header
                    ui.heading(&node.label);
                    ui.label(egui::RichText::new(format!("URI: {}", node.id)).color(self.theme.dimmed_text_fg));
                    ui.add_space(20.0);

                    // subject
                    ui.heading("As Subject");
                    ui.add_space(5.0);

                    egui::Grid::new("inspector_subject_grid")
                        .num_columns(2)
                        .spacing([grid_spacing, 15.0])
                        .striped(true)
                        .show(ui, |ui| {
                            let mut seen_props = std::collections::HashSet::new();

                            for (key, value) in &node.properties {
                                if !seen_props.insert((key.clone(), value.clone())) {
                                    continue;
                                }

                                ui.vertical(|ui| {
                                    ui.set_min_width(col1_width);
                                    ui.set_max_width(col1_width);
                                    ui.label(key);
                                });

                                ui.vertical(|ui| {
                                    ui.set_min_width(col2_width);
                                    ui.set_max_width(col2_width);
                                    ui.label(value);
                                });

                                ui.end_row();
                            }
                        });

                    ui.separator();
                    ui.add_space(10.0);

                    ui.heading("As Object");
                    ui.add_space(5.0);

                    egui::Grid::new("inspector_object_grid")
                        .num_columns(2)
                        .spacing([grid_spacing, 15.0])
                        .striped(true)
                        .show(ui, |ui| {
                            let mut has_incoming = false;

                            for edge in edges.iter() {
                                let mut is_incoming = false;
                                let mut source_id = "";
                                let mut display_label = edge.label.clone();

                                if edge.target == node_idx {
                                    is_incoming = true;
                                    source_id = nodes[edge.source].id.as_str();
                                } else if edge.source == node_idx && edge.bidirectional {
                                    is_incoming = true;
                                    source_id = nodes[edge.target].id.as_str();
                                    if let Some(rev) = &edge.reverse_label {
                                        display_label = rev.clone();
                                    }
                                }

                                if is_incoming {
                                    has_incoming = true;

                                    ui.vertical(|ui| {
                                        ui.set_min_width(col2_width);
                                        ui.set_max_width(col2_width);
                                        ui.label(source_id);
                                    });

                                    ui.vertical(|ui| {
                                        ui.set_min_width(col1_width);
                                        ui.set_max_width(col1_width);
                                        ui.label(display_label);
                                    });

                                    ui.end_row();
                                }
                            }
                        });
                } else {
                    ui.label(
                        egui::RichText::new("Please select a node from the dropdown above to view its properties.")
                            .color(self.theme.dimmed_text_fg)
                            .italics(),
                    );
                }
            }
        });
    }
}
