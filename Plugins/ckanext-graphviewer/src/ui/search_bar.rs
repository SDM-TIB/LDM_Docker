use crate::{App, SearchType};
use eframe::egui;

impl App {
    pub fn render_search_bar(&mut self, ui: &mut egui::Ui, ctx: &egui::Context) {
        if !self.is_global_viewer {
            return;
        }

        ui.horizontal(|ui| {
            ui.spacing_mut().interact_size.y = 19.0;

            ui.label("Select a start point:");

            let combo_response = egui::ComboBox::from_id_salt("fetch_dropdown")
                .selected_text(self.search_type.as_str())
                .show_ui(ui, |ui| {
                    let mut changed = false;
                    for st in SearchType::all() {
                        if ui.selectable_value(&mut self.search_type, st.clone(), st.as_str()).changed() {
                            changed = true;
                        }
                    }
                    changed
                });

            if combo_response.inner.unwrap_or(false) {
                self.search_input.clear();
                self.highlighted_index = 0;
            }

            let is_failed = *self.search_failed.lock().unwrap();

            if is_failed {
                let error_stroke = egui::Stroke::new(1.5, self.theme.error_fg);
                ui.visuals_mut().widgets.inactive.bg_stroke = error_stroke;
                ui.visuals_mut().widgets.hovered.bg_stroke = error_stroke;
                ui.visuals_mut().widgets.active.bg_stroke = error_stroke;
            }

            let text_response = ui.add(egui::TextEdit::singleline(&mut self.search_input).desired_width(300.0));

            if text_response.changed() && is_failed {
                *self.search_failed.lock().unwrap() = false;
            }

            let preloaded_suggestions: Vec<String> = {
                let lock = self.suggestions.lock().unwrap();
                lock.get(&self.search_type).cloned().unwrap_or_default()
            };

            let filtered_suggestions: Vec<_> = preloaded_suggestions
                .iter()
                .filter(|s| {
                    let s_lower = s.to_lowercase();
                    let input_lower = self.search_input.to_lowercase();
                    s_lower.contains(&input_lower) && *s != &self.search_input
                })
                .collect();

            let popup_id = text_response.id.with("popup");
            let mut is_open = egui::Popup::is_id_open(ui.ctx(), popup_id);

            if text_response.changed() {
                self.highlighted_index = 0;
                if !self.search_input.is_empty() && !filtered_suggestions.is_empty() {
                    is_open = true;
                }
            }

            if is_open {
                if ui.input(|i| i.key_pressed(egui::Key::ArrowDown)) {
                    self.highlighted_index = self
                        .highlighted_index
                        .saturating_add(1)
                        .min(filtered_suggestions.len().saturating_sub(1));
                }
                if ui.input(|i| i.key_pressed(egui::Key::ArrowUp)) {
                    self.highlighted_index = self.highlighted_index.saturating_sub(1);
                }
                if text_response.lost_focus() && ui.input(|i| i.key_pressed(egui::Key::Enter)) {
                    if let Some(&suggestion) = filtered_suggestions.get(self.highlighted_index) {
                        self.search_input = suggestion.to_string();
                        is_open = false;
                    }
                }
            }

            if self.search_input.is_empty() || filtered_suggestions.is_empty() || (!text_response.has_focus() && !is_open) {
                is_open = false;
            }

            if is_open {
                egui::Popup::open_id(ui.ctx(), popup_id);
            } else {
                egui::Popup::close_id(ui.ctx(), popup_id);
            }

            egui::Popup::from_response(&text_response).id(popup_id).open(is_open).show(|ui| {
                ui.set_min_width(text_response.rect.width());
                egui::ScrollArea::vertical().max_height(200.0).show(ui, |ui| {
                    for (i, suggestion) in filtered_suggestions.iter().enumerate() {
                        let is_selected = i == self.highlighted_index;
                        if ui.selectable_label(is_selected, suggestion.as_str()).clicked() {
                            self.search_input = suggestion.to_string();
                            egui::Popup::close_id(ui.ctx(), popup_id);
                            text_response.surrender_focus();
                        }
                    }
                });
            });

            // Confirm Fetch Button
            let is_currently_fetching = *self.is_fetching.lock().unwrap();

            let start_point_confirm_button = egui::Button::new("Confirm");

            if ui.add_enabled(!is_currently_fetching, start_point_confirm_button).clicked() {
                log::info!("Requested Fetch! Type: {}, Input: {}", self.search_type.as_str(), self.search_input);
                *self.search_failed.lock().unwrap() = false;
                *self.is_fetching.lock().unwrap() = true;

                let state_clone = self.state.clone();
                let ctx_clone = ctx.clone();
                let input = self.search_input.clone();
                let search_type = self.search_type.clone();
                let failed_clone = self.search_failed.clone();
                let fetching_clone = self.is_fetching.clone();
                let base_url = self.api_url.clone();

                let target_url = match search_type {
                    SearchType::AuthorName => format!("{}/get_dataset_information_by_author_name?author_name={}", base_url, input),
                    SearchType::AuthorOrcid => format!("{}/get_dataset_information_by_author_orcid?author_orcid={}", base_url, input),
                    SearchType::AuthorLdmId => format!("{}/get_dataset_information_by_author_ldm_id?author_ldm_id={}", base_url, input),
                    SearchType::PaperDoi => format!("{}/get_dataset_information_by_paper_doi?paper_doi={}", base_url, input),
                    SearchType::PaperTitle => format!("{}/get_dataset_information_by_paper_title?paper_title={}", base_url, input),
                    SearchType::DatasetDoi => format!("{}/get_dataset_information_by_dataset_doi?dataset_doi={}", base_url, input),
                    SearchType::DatasetTitle => format!("{}/get_dataset_information_by_dataset_title?dataset_title={}", base_url, input),
                    SearchType::DatasetLdmId => {
                        format!("{}/get_dataset_information_by_dataset_ldm_id?dataset_ldm_id={}", base_url, input)
                    }
                };

                let request = ehttp::Request::get(&target_url);

                ehttp::fetch(request, move |response| {
                    let mut fetch_successful = false;

                    if let Ok(res) = response {
                        if let Some(text) = res.text() {
                            let new_triples = crate::parser::parse_dynamic_api_json(&text);

                            if !new_triples.is_empty() {
                                fetch_successful = true;

                                let (temp_nodes, temp_edges) = crate::graph_processor::build_ui_graph(new_triples.clone());

                                let mut temp_node_map = std::collections::HashMap::new();
                                for n in temp_nodes.iter() {
                                    temp_node_map.insert(n.id.clone(), n.clone());
                                }

                                let mut temp_edge_vis = std::collections::HashSet::new();
                                for e in temp_edges.iter() {
                                    if e.visible {
                                        let s_id = temp_nodes[e.source].id.clone();
                                        let t_id = temp_nodes[e.target].id.clone();
                                        temp_edge_vis.insert((s_id, t_id));
                                    }
                                }

                                let mut combined_triples = Vec::new();
                                let mut old_fetched = std::collections::HashSet::new();
                                {
                                    let current_state = state_clone.lock().unwrap();
                                    if let crate::AppState::Ready {
                                        raw_triples,
                                        nodes: old_nodes,
                                        ..
                                    } = &*current_state
                                    {
                                        combined_triples.extend(raw_triples.clone());

                                        for n in old_nodes {
                                            if n.api_fetched {
                                                old_fetched.insert(n.id.clone());
                                            }
                                        }
                                    }
                                }

                                combined_triples.extend(new_triples.clone());
                                combined_triples.sort();
                                combined_triples.dedup();

                                let (mut nodes, mut edges) = crate::graph_processor::build_ui_graph(combined_triples.clone());

                                for node in nodes.iter_mut() {
                                    if let Some(temp_n) = temp_node_map.get(&node.id) {
                                        node.pos = temp_n.pos;
                                        node.original_pos = temp_n.original_pos;
                                        node.visible = temp_n.visible;
                                        node.expanded = temp_n.expanded;
                                    } else {
                                        node.visible = false;
                                        node.expanded = false;
                                    }

                                    if old_fetched.contains(&node.id) {
                                        node.api_fetched = true;
                                    }
                                }

                                for edge in edges.iter_mut() {
                                    let s_id = &nodes[edge.source].id;
                                    let t_id = &nodes[edge.target].id;

                                    if temp_edge_vis.contains(&(s_id.clone(), t_id.clone()))
                                        || temp_edge_vis.contains(&(t_id.clone(), s_id.clone()))
                                    {
                                        edge.visible = true;
                                    } else {
                                        edge.visible = false;
                                    }
                                }

                                let init_snapshot = crate::GraphSnapshot::new(&nodes, &edges);

                                *state_clone.lock().unwrap() = crate::AppState::Ready {
                                    nodes,
                                    edges,
                                    raw_triples: combined_triples,
                                    init_snapshot,
                                };
                            }
                        }
                    }

                    if !fetch_successful {
                        *failed_clone.lock().unwrap() = true;
                    }

                    *fetching_clone.lock().unwrap() = false;
                    ctx_clone.request_repaint();
                });
            }

            if is_currently_fetching {
                ui.add(egui::Spinner::new());
                ui.label("Fetching data...");
            }
        });

        ui.separator();
    }
}
