use crate::{App, SearchType};
use eframe::egui;

/* the search bar is on its own just one ui.horizontal element which
  houses a label a combobox and a text edit and a button as well as the progressinfo label
  when the uses inputs text in the author name or dataset name fiels a query against the ckan
  instance is execute to show suggestions
*/

impl App {
    pub fn render_search_bar(&mut self, ui: &mut egui::Ui, ctx: &egui::Context) {
        // disable search bar when opened from dataset
        if !self.config.is_global_viewer {
            return;
        }

        // process incoming background data
        if let Ok(msg) = self.search.autocomplete_rx.try_recv() {
            if let crate::FetchMessage::Success(mut new_strings) = msg {
                let received_count = new_strings.len();

                self.search.found_strings.append(&mut new_strings);
                self.search.found_strings.sort();
                self.search.found_strings.dedup();

                if received_count < self.config.rows_per_page {
                    self.search.autocomplete_fetching = false;
                } else {
                    self.search.current_offset += self.config.rows_per_page;
                    self.trigger_autocomplete_fetch();
                }
            }
        }

        // main element
        ui.horizontal(|ui| {
            // the element has a hight of 19 pixel from the top the seperator HACK for consitency
            ui.spacing_mut().interact_size.y = 19.0;

            ui.label("Select a start point:");

            let combo_response = egui::ComboBox::from_id_salt("fetch_dropdown")
                .selected_text(self.search.search_type.as_str())
                .show_ui(ui, |ui| {
                    let mut changed = false;
                    for st in SearchType::all() {
                        if ui.selectable_value(&mut self.search.search_type, st.clone(), st.as_str()).changed() {
                            changed = true;
                        }
                    }
                    changed
                });

            if combo_response.inner.unwrap_or(false) {
                self.search.search_input.clear();
                self.search.highlighted_index = 0;
            }

            let is_failed = *self.search.search_failed.lock().unwrap();

            if is_failed {
                let error_stroke = egui::Stroke::new(1.5, self.ui.theme.error_fg);
                ui.visuals_mut().widgets.inactive.bg_stroke = error_stroke;
                ui.visuals_mut().widgets.hovered.bg_stroke = error_stroke;
                ui.visuals_mut().widgets.active.bg_stroke = error_stroke;
            }

            let text_response = ui.add(egui::TextEdit::singleline(&mut self.search.search_input).desired_width(300.0));

            if text_response.changed() && is_failed {
                *self.search.search_failed.lock().unwrap() = false;
            }

            let popup_id = text_response.id.with("popup");
            let mut is_open = egui::Popup::is_id_open(ui.ctx(), popup_id);

            // trigger a api call when more than equal to 3 character are present
            if text_response.changed() {
                self.search.highlighted_index = 0;
                if is_failed {
                    *self.search.search_failed.lock().unwrap() = false;
                }

                if !self.search.search_input.is_empty() {
                    is_open = true;

                    // limit search_type that support suggestions
                    if self.search.search_type == SearchType::AuthorName || self.search.search_type == SearchType::DatasetTitle {
                        if self.search.search_input.len() >= 3 {
                            self.search.found_strings.clear();
                            self.search.current_offset = 0;
                            self.search.autocomplete_fetching = true;
                            self.trigger_autocomplete_fetch();
                        }
                    }
                } else {
                    self.search.found_strings.clear();
                    self.search.autocomplete_fetching = false;
                }
            }

            let mut filtered_suggestions: Vec<String> = self.search.found_strings
                .iter()
                .filter(|word| {
                    let s_lower = word.name.to_lowercase();
                    let input_lower = self.search.search_input.to_lowercase();
                    s_lower.contains(&input_lower) && word.name != self.search.search_input
                })
                .map(|word| word.name.clone())
                .collect();

            if self.search.search_type == SearchType::AuthorName || self.search.search_type == SearchType::DatasetTitle {
                for word in &self.search.found_strings {
                    // deduplicate
                    if !filtered_suggestions.contains(&word.name) && word.name != self.search.search_input {
                        filtered_suggestions.push(word.name.clone());
                    }
                }
            }

            if is_open {
                // keyboard navigation
                if ui.input(|i| i.key_pressed(egui::Key::ArrowDown)) {
                    self.search.highlighted_index = self
                        .search.highlighted_index
                        .saturating_add(1)
                        .min(filtered_suggestions.len().saturating_sub(1));
                }
                if ui.input(|i| i.key_pressed(egui::Key::ArrowUp)) {
                    self.search.highlighted_index = self.search.highlighted_index.saturating_sub(1);
                }
                if text_response.lost_focus() && ui.input(|i| i.key_pressed(egui::Key::Enter)) {
                    if let Some(suggestion) = filtered_suggestions.get(self.search.highlighted_index) {
                        self.search.search_input = suggestion.to_string();
                        is_open = false;
                    }
                }
                // close on esc key
                if ui.input(|i| i.key_pressed(egui::Key::Escape)) {
                    is_open = false;
                    text_response.surrender_focus();
                }
            }

            // Critical change: Only force-close if we are NOT currently fetching
            if self.search.search_input.is_empty()
                || (filtered_suggestions.is_empty() && !self.search.autocomplete_fetching)
                || (!text_response.has_focus() && !is_open)
            {
                is_open = false;
            }

            // Sync state with egui memory
            if is_open {
                egui::Popup::open_id(ui.ctx(), popup_id);
            } else {
                egui::Popup::close_id(ui.ctx(), popup_id);
            }

            // render the popup window
            if is_open {
                let screen_rect = ui.ctx().content_rect();

                // TODO figure out why the height is magic
                let pos_x = 0.0;
                let pos_y = text_response.rect.bottom() + 6.0;
                let target_width = screen_rect.width() - 14.0;
                let target_height = screen_rect.width() - 244.0;

                egui::Area::new("autocomplete_popup_area".into())
                    .fixed_pos([pos_x, pos_y])
                    .show(ui.ctx(), |ui| {
                        egui::Frame::popup(ui.style()).show(ui, |ui| {
                            ui.set_min_width(target_width);
                            ui.set_max_width(target_width);
                            ui.set_min_height(target_height);
                            ui.set_max_height(target_height);

                            egui::ScrollArea::vertical().show(ui, |ui| {
                                if filtered_suggestions.is_empty() && !self.search.autocomplete_fetching {
                                    ui.label(
                                        egui::RichText::new("No matching results.")
                                            .italics()
                                            .color(self.ui.theme.dimmed_text_fg),
                                    );
                                } else {
                                    for (i, suggestion) in filtered_suggestions.iter().enumerate() {
                                        let is_selected = i == self.search.highlighted_index;

                                        let row_response =
                                            ui.add_sized([target_width, 0.0], egui::Button::selectable(is_selected, suggestion.as_str()));

                                        if row_response.clicked() {
                                            self.search.search_input = suggestion.to_string();
                                            text_response.surrender_focus();
                                            egui::Popup::close_id(ui.ctx(), popup_id);
                                        }
                                    }
                                }
                            });
                        });
                    });
            }

            // confirm fetch datasets from api button
            let is_currently_fetching = *self.search.is_fetching.lock().unwrap();

            let start_point_confirm_button = egui::Button::new("Confirm");

            if ui.add_enabled(!is_currently_fetching, start_point_confirm_button).clicked() {
                log::info!("Requested Fetch! Type: {}, Input: {}", self.search.search_type.as_str(), self.search.search_input);
                *self.search.search_failed.lock().unwrap() = false;
                *self.search.is_fetching.lock().unwrap() = true;

                let state_clone = self.graph_data.clone();
                let ctx_clone = ctx.clone();
                let input = self.search.search_input.clone();
                let search_type = self.search.search_type.clone();
                let failed_clone = self.search.search_failed.clone();
                let fetching_clone = self.search.is_fetching.clone();
                let base_url = self.config.api_url.clone();

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

            // fetching info text
            if self.search.autocomplete_fetching {
                ui.add(egui::Spinner::new());
                ui.label("Fetching Suggestion data...");
            }

            if is_currently_fetching {
                ui.add(egui::Spinner::new());
                ui.label("Fetching Graph data...");
            }
        });

        ui.separator();
    }
}
