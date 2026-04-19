use crate::App;
use crate::graph_processor::{Edge, Node};
use eframe::egui;

impl App {
    pub fn render_inspector_scene(&mut self, ui: &mut egui::Ui, nodes: &mut [Node], edges: &mut [Edge]) {
        // render node inspector
        let max_width = ui.available_width() - 12.0; // magic number for margin
        let max_height = ui.available_height() - 34.0; // magic number for margin

        egui::ScrollArea::vertical().auto_shrink([false, false]).show(ui, |ui| {
            ui.add_space(1.0);

            let mut sorted_nodes: Vec<_> = nodes.iter().filter(|n| n.node_type != "Attribute").collect();
            sorted_nodes.sort_by(|a, b| a.label.to_lowercase().cmp(&b.label.to_lowercase()));

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

                let popup_id = ui.id().with("inspector_searchable_popup");
                let mut is_open = egui::Popup::is_id_open(ui.ctx(), popup_id);

                let target_width = ui.available_width() - 0.0;
                let default_height = ui.spacing().interact_size.y;

                let button_response = ui.add_sized(
                    [target_width, default_height],
                    egui::Button::new(selected_label)
                );

                if button_response.clicked() {
                    is_open = !is_open;
                }

                if is_open && ui.input(|i| i.key_pressed(egui::Key::Escape)) {
                    is_open = false;
                }

                if is_open {
                    egui::Popup::open_id(ui.ctx(), popup_id);
                } else {
                    egui::Popup::close_id(ui.ctx(), popup_id);
                }

                egui::Popup::from_response(&button_response).id(popup_id).open(is_open).show(|ui| {
                    ui.set_min_width(max_width);
                    ui.set_max_width(max_width);
                    ui.set_min_height(max_height);
                    ui.set_max_height(max_height);

                    ui.add_sized(
                        [max_width, 0.0],
                        egui::TextEdit::singleline(&mut self.inspector_search_text)
                            .hint_text("Search nodes...")
                    );

                    ui.separator();

                    let search_term = self.inspector_search_text.to_lowercase();
                    let mut match_found = false;

                    egui::ScrollArea::vertical().show(ui, |ui| {
                        for node in sorted_nodes {
                            let uri_tail = node.id.split('/').last().unwrap_or(&node.id).split('#').last().unwrap_or(&node.id);
                            let display_text = format!("{} ({})", node.label, uri_tail);

                            if search_term.is_empty() || display_text.to_lowercase().contains(&search_term) {
                                match_found = true;

                                let is_selected = self.inspector_selected_node == Some(node.id.clone());

                                let row_response = ui.add_sized(
                                    [max_width, 0.0],
                                    egui::SelectableLabel::new(is_selected, display_text)
                                );

                                if row_response.clicked() {
                                    self.inspector_selected_node = Some(node.id.clone());
                                    self.inspector_search_text.clear();
                                    egui::Popup::close_id(ui.ctx(), popup_id);
                                }
                            }
                        }

                        if !match_found {
                            ui.label(egui::RichText::new("No matching nodes found.").color(self.theme.dimmed_text_fg).italics());
                        }
                    });
                });
            });

            ui.separator();

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

                    egui::Frame::NONE
                        .fill(self.theme.painter_bg)
                        .corner_radius(5.0)
                        .inner_margin(8.0)
                        .show(ui, |ui| {
                            let total_width = ui.available_width();
                            let grid_spacing = 20.0;
                            let col1_width = (total_width - grid_spacing) * 0.30;
                            let col2_width = (total_width - grid_spacing) * 0.70;

                            ui.add_space(3.0);

                            egui::Grid::new("inspector_subject_grid")
                                .num_columns(2)
                                .spacing([grid_spacing - 10.0, 15.0])
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
                            ui.add_space(7.0);
                        });

                    ui.add_space(5.0);
                    ui.heading("As Object");
                    ui.add_space(5.0);

                    egui::Frame::NONE
                        .fill(self.theme.painter_bg)
                        .corner_radius(5.0)
                        .inner_margin(8.0)
                        .show(ui, |ui| {
                            let frame_width = ui.available_width();
                            let grid_spacing = 20.0;
                            let col1_width = (frame_width - grid_spacing) * 0.30;
                            let col2_width = (frame_width - grid_spacing) * 0.70;

                            ui.add_space(3.0);

                            egui::Grid::new("inspector_object_grid")
                                .num_columns(2)
                                .spacing([grid_spacing - 10.0, 15.0])
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
                            ui.add_space(7.0);
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
