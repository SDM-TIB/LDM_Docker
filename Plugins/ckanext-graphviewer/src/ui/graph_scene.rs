use crate::graph_processor::{Edge, Node};
use crate::{App, GraphSnapshot};
use eframe::egui;

impl App {
    pub fn render_graph_scene(
        &mut self,
        ui: &mut egui::Ui,
        ctx: &egui::Context,
        nodes: &mut [Node],
        edges: &mut [Edge],
        init_snapshot: &mut GraphSnapshot,
    ) {
        // render graph
        ui.add_space(1.0);
        ui.horizontal(|ui| {
            ui.label(egui::RichText::new("Graph Controls:").color(self.theme.text_fg));
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                let reset_view_button =
                    egui::Button::new(egui::RichText::new("Reset View").color(self.theme.text_fg)).fill(self.theme.button_bg);
                if ui.add(reset_view_button).clicked() {
                    self.zoom = 1.0;
                    self.pan = egui::vec2(0.0, 0.0);
                    self.selected_node = None;

                    for node in nodes.iter_mut() {
                        if let Some(&pos) = init_snapshot.node_positions.get(&node.id) {
                            node.pos = pos;
                        } else {
                            node.pos = node.original_pos;
                        }
                        node.visible = init_snapshot.visible_nodes.contains(&node.id);
                        node.expanded = init_snapshot.expanded_nodes.contains(&node.id);
                    }

                    for edge in edges.iter_mut() {
                        let s_id = &nodes[edge.source].id;
                        let t_id = &nodes[edge.target].id;

                        edge.visible = init_snapshot.visible_edges.contains(&(s_id.clone(), t_id.clone()))
                            || init_snapshot.visible_edges.contains(&(t_id.clone(), s_id.clone()));
                    }

                    *init_snapshot = GraphSnapshot::new(nodes, edges);
                }
            });
        });
        ui.add_space(3.0);

        let draw_node_details = |ui: &mut egui::Ui, node: &Node| {
            egui::Grid::new(format!("tooltip_grid_{}", node.id))
                .num_columns(2)
                .spacing([10.0, 4.0])
                .show(ui, |ui| {
                    let display_id = if node.node_type == "Attribute" { &node.label } else { &node.id };

                    if !display_id.is_empty() {
                        ui.strong("ID:");
                        if display_id.len() > 60 {
                            egui::ScrollArea::vertical()
                                .id_salt(format!("scroll_id_{}", node.id))
                                .max_height(60.0)
                                .min_scrolled_height(0.0)
                                .show(ui, |ui| {
                                    ui.label(display_id);
                                });
                        } else {
                            ui.label(display_id);
                        }
                        ui.end_row();
                    }

                    let mut seen_props = std::collections::HashSet::new();

                    for (i, (key, value)) in node.properties.iter().enumerate() {
                        if !seen_props.insert((key.clone(), value.clone())) {
                            continue;
                        }

                        let display_key = {
                            let mut c = key.chars();
                            match c.next() {
                                None => String::new(),
                                Some(f) => f.to_uppercase().collect::<String>() + c.as_str(),
                            }
                        };

                        ui.strong(format!("{}:", display_key));

                        if value.len() > 60 {
                            egui::ScrollArea::vertical()
                                .id_salt(format!("scroll_prop_{}_{}", node.id, i))
                                .max_height(100.0)
                                .min_scrolled_height(0.0)
                                .show(ui, |ui| {
                                    ui.label(value);
                                });
                        } else {
                            ui.label(value);
                        }
                        ui.end_row();
                    }
                });
        };

        // define a frame that houses the color config for the legend
        let legend_outline = egui::Frame::window(&ui.ctx().global_style())
            .fill(self.theme.button_bg)
            .inner_margin(3.0)
            .corner_radius(5.0)
            .stroke(egui::Stroke::new(2.0, self.theme.master_bg));

        // render legend
        egui::Window::new(egui::RichText::new("Legend").color(self.theme.text_fg))
            .anchor(egui::Align2::LEFT_TOP, egui::vec2(12.0, 101.0)) // 6 pixel space from left and top
            .collapsible(true)
            .resizable(false)
            .frame(legend_outline)
            .show(ui.ctx(), |ui| {
                ui.style_mut().visuals.override_text_color = Some(self.theme.text_fg);
                egui::Frame::NONE
                    .inner_margin(5.0)
                    .corner_radius(5.0)
                    .stroke(egui::Stroke::new(1.0, self.theme.edge_fg))
                    .fill(self.theme.master_bg)
                    .show(ui, |ui| {
                        egui::Grid::new("legend_grid").num_columns(2).spacing([10.0, 8.0]).show(ui, |ui| {
                            for (uri, colors) in &self.theme.node_map {
                                let display_name = uri.split('#').last().unwrap_or(uri);
                                let display_name = display_name.split('/').last().unwrap_or(display_name);

                                let (rect, _) = ui.allocate_exact_size(egui::vec2(12.0, 12.0), egui::Sense::hover());
                                ui.painter().circle_filled(rect.center(), 6.0, colors.normal);

                                ui.label(display_name);
                                ui.end_row();
                            }

                            let (rect, _) = ui.allocate_exact_size(egui::vec2(12.0, 12.0), egui::Sense::hover());
                            ui.painter().circle_filled(rect.center(), 6.0, self.theme.default_node.normal);
                            ui.label("Other");
                            ui.end_row();
                        });
                    });
            });

        let background_rect = ui.available_rect_before_wrap();
        let area_to_fill = ui.available_rect_before_wrap();

        self.canvas_rect = Some(area_to_fill);

        let screen_center = area_to_fill.center().to_vec2();

        let background_response = ui.interact(background_rect, ui.id().with("background"), egui::Sense::click_and_drag());
        if background_response.dragged() {
            self.pan += background_response.drag_delta();
        }
        if background_response.clicked() {
            self.selected_node = None;
        }

        let scroll_y = ui.input(|i| i.smooth_scroll_delta.y);

        let pinch_zoom = ui.input(|i| i.zoom_delta());

        let mut zoom_multiplier = pinch_zoom;
        if scroll_y != 0.0 {
            zoom_multiplier *= (scroll_y * 0.005).exp();
        }

        if zoom_multiplier != 1.0 {
            if let Some(pointer_pos) = ui.ctx().pointer_hover_pos() {
                let pointer_vec = pointer_pos.to_vec2();

                let graph_pos = (pointer_vec - screen_center - self.pan) / self.zoom;

                self.zoom *= zoom_multiplier;
                self.zoom = self.zoom.clamp(0.1, 5.0);

                self.pan = pointer_vec - screen_center - graph_pos * self.zoom;
            }
        }

        let to_screen = |p: egui::Pos2| -> egui::Pos2 { (screen_center + self.pan + p.to_vec2() * self.zoom).to_pos2() };

        let painter = ui.painter().with_clip_rect(area_to_fill);

        painter.rect_filled(area_to_fill, 0.0, self.theme.painter_bg);

        // draw edges and labels
        for edge in edges.iter() {
            if !edge.visible {
                continue;
            }

            let s = &nodes[edge.source];
            let t = &nodes[edge.target];

            let p1 = to_screen(s.pos);
            let p2 = to_screen(t.pos);
            let vector = p2 - p1;
            let length = vector.length();

            if length == 0.0 {
                continue;
            }
            let dir = vector / length;

            // draw edge
            painter.line_segment([p1, p2], egui::Stroke::new(1.5 * self.zoom, self.theme.edge_fg));

            let node_radius = 15.0 * self.zoom;
            let arrow_len = 12.0 * self.zoom;
            let arrow_angle = 0.4;
            let line_angle = dir.y.atan2(dir.x);

            // draw arrowhead
            let tip = p2 - (dir * node_radius);
            let angle_left = line_angle - arrow_angle;
            let p_left = tip - egui::vec2(angle_left.cos(), angle_left.sin()) * arrow_len;
            let angle_right = line_angle + arrow_angle;
            let p_right = tip - egui::vec2(angle_right.cos(), angle_right.sin()) * arrow_len;

            painter.add(egui::Shape::convex_polygon(
                vec![tip, p_left, p_right],
                self.theme.edge_fg,
                egui::Stroke::NONE,
            ));

            // draw arrowhead reverse
            if edge.bidirectional {
                let tip_rev = p1 + (dir * node_radius);
                let dir_rev = -dir;
                let line_angle_rev = dir_rev.y.atan2(dir_rev.x);

                let angle_left_rev = line_angle_rev - arrow_angle;
                let p_left_rev = tip_rev - egui::vec2(angle_left_rev.cos(), angle_left_rev.sin()) * arrow_len;
                let angle_right_rev = line_angle_rev + arrow_angle;
                let p_right_rev = tip_rev - egui::vec2(angle_right_rev.cos(), angle_right_rev.sin()) * arrow_len;

                painter.add(egui::Shape::convex_polygon(
                    vec![tip_rev, p_left_rev, p_right_rev],
                    self.theme.edge_fg,
                    egui::Stroke::NONE,
                ));
            }

            // draw label
            let center_point = p1 + (dir * length * 0.5);

            let font_size = (10.0 * self.zoom).round();

            if font_size > 4.0 {
                let is_flipped = dir.x < 0.0;

                let display_text = if !is_flipped {
                    // target is to the right
                    if let Some(rev) = &edge.reverse_label {
                        format!("{} ->\n<- {}", edge.label, rev)
                    } else if edge.bidirectional {
                        format!("<- {} ->", edge.label)
                    } else {
                        format!("{} ->", edge.label)
                    }
                } else {
                    // target is to the left
                    if let Some(rev) = &edge.reverse_label {
                        format!("<- {}\n{} ->", edge.label, rev)
                    } else if edge.bidirectional {
                        format!("<- {} ->", edge.label)
                    } else {
                        format!("<- {}", edge.label)
                    }
                };

                let galley = painter.layout_no_wrap(display_text, egui::FontId::proportional(font_size), self.theme.text_fg);

                let size = galley.size();
                let padding = 3.0 * self.zoom;

                let snapped_center = egui::pos2(center_point.x.round(), center_point.y.round());
                let text_rect = egui::Rect::from_center_size(snapped_center, size);

                // background box for label
                painter.rect_filled(text_rect.expand(padding), 2.0 * self.zoom, self.theme.painter_bg);

                painter.galley(text_rect.min, galley, self.theme.text_fg);
            }
        }

        // draw node
        let mut clicked_to_expand = None;

        let mut dragged_node_delta = None;

        for (index, node) in nodes.iter().enumerate() {
            if !node.visible {
                continue;
            }

            let screen_pos = to_screen(node.pos);
            let radius = 15.0 * self.zoom;

            let response = ui.interact(
                egui::Rect::from_center_size(screen_pos, egui::vec2(radius * 2.0, radius * 2.0)),
                ui.id().with(&node.id),
                egui::Sense::click_and_drag(),
            );

            let current_time = ui.input(|i| i.time);

            // node it dragged
            if response.dragged() {
                let delta = response.drag_delta() / self.zoom;
                self.selected_node = None;
                self.pending_click_node = None;
                dragged_node_delta = Some((index, delta));
            }

            // left double click / left click
            if response.double_clicked() {
                clicked_to_expand = Some(index);
                self.selected_node = None;
                self.pending_click_node = None;
            } else if response.clicked() {
                self.pending_click_node = Some(index);
                self.pending_click_time = current_time;
            }

            // right click
            if response.secondary_clicked() {
                self.selected_node = Some(index);
                self.show_menu = true;
                self.pending_click_node = None;
            }

            // delay infobox till we are sure no double click happend
            if self.pending_click_node == Some(index) {
                if (current_time - self.pending_click_time) > 0.25 {
                    // 250 ms
                    if self.selected_node == Some(index) && !self.show_menu {
                        self.selected_node = None;
                    } else {
                        self.selected_node = Some(index);
                        self.show_menu = false;
                    }
                    self.pending_click_node = None; // Clear the timer
                } else {
                    ui.ctx().request_repaint();
                }
            }

            let is_pinned = self.selected_node == Some(index) && !self.show_menu;

            if is_pinned {
                let offset = egui::vec2(20.0 * self.zoom, 20.0 * self.zoom);

                egui::Window::new(format!("node_window_{}", node.id))
                    .fixed_pos(screen_pos + offset)
                    .title_bar(false)
                    .resizable(false)
                    .collapsible(false)
                    .frame(egui::Frame::popup(&ctx.global_style()))
                    .show(&ctx, |ui| {
                        ui.heading(&node.label);
                        ui.separator();

                        draw_node_details(ui, node);

                        ui.add_space(5.0);
                        if ui.button("Close").clicked() {
                            self.selected_node = None;
                        }
                    });
            }

            let node_theme = self.theme.get_node_colors(&node.rdf_type);

            let color = if response.hovered() {
                node_theme.hovered
            } else {
                node_theme.normal
            };

            painter.circle_filled(screen_pos, radius, color);

            let font_size = 12.0 * self.zoom;
            if font_size > 4.0 {
                let display_text = if node.label.len() > 50 {
                    let pred_name = edges
                        .iter()
                        .find(|e| e.target == index)
                        .map(|e| e.label.clone())
                        .unwrap_or_else(|| "Dataset".to_string());
                    let display_pred = {
                        let mut c = pred_name.chars();
                        match c.next() {
                            None => String::new(),
                            Some(f) => f.to_uppercase().collect::<String>() + c.as_str(),
                        }
                    };

                    format!("{} (Click to show)", display_pred)
                } else {
                    node.label.clone()
                };

                let galley = painter.layout_no_wrap(display_text.to_string(), egui::FontId::proportional(font_size), self.theme.text_fg);

                let text_pos = screen_pos + egui::vec2(0.0, 20.0 * self.zoom);
                let text_rect = egui::Align2::CENTER_TOP.anchor_rect(egui::Rect::from_min_size(text_pos, galley.size()));

                painter.rect_filled(text_rect.expand(2.0 * self.zoom), 2.0 * self.zoom, self.theme.painter_bg);

                painter.galley(text_rect.min, galley, self.theme.text_fg);
            }
        }

        // node menu
        if let Some(menu_idx) = self.selected_node {
            if self.show_menu {
                let screen_pos = to_screen(nodes[menu_idx].pos);

                crate::node_menu::draw_radial_menu(
                    ui,
                    &ctx,
                    &painter,
                    menu_idx,
                    screen_pos,
                    self.zoom,
                    &self.theme,
                    nodes,
                    edges,
                    &self.api_url,
                    self.state.clone(),
                    &mut self.show_menu,
                    &mut self.selected_node,
                    &mut clicked_to_expand,
                );
            }
        }

        // move child node in sync
        if let Some((parent_idx, delta)) = dragged_node_delta {
            nodes[parent_idx].pos += delta;

            // TODO decide on a movement strategie
            // for edge in edges.iter() {
            //     if edge.source == parent_idx && edge.visible {
            //         let child_idx = edge.target;
            //         nodes[child_idx].pos += delta;
            //     }
            // }
        }

        // expansion
        if let Some(parent_idx) = clicked_to_expand {
            let is_currently_expanded = nodes[parent_idx].expanded;

            if is_currently_expanded {
                // cascade collapse
                let mut stack = vec![parent_idx];

                while let Some(current_idx) = stack.pop() {
                    nodes[current_idx].expanded = false;

                    for edge_idx in 0..edges.len() {
                        let mut child_idx_opt = None;

                        if edges[edge_idx].source == current_idx && edges[edge_idx].visible {
                            child_idx_opt = Some(edges[edge_idx].target);
                        } else if edges[edge_idx].target == current_idx && edges[edge_idx].visible {
                            child_idx_opt = Some(edges[edge_idx].source);
                        }

                        if let Some(child_idx) = child_idx_opt {
                            edges[edge_idx].visible = false;

                            let has_other_active_parents =
                                edges.iter().any(|e| (e.target == child_idx || e.source == child_idx) && e.visible);

                            if !has_other_active_parents {
                                nodes[child_idx].visible = false;

                                if nodes[child_idx].expanded {
                                    stack.push(child_idx);
                                }
                            }
                        }
                    }
                }
            } else {
                nodes[parent_idx].expanded = true;
                let mut children_indices = Vec::new();

                for (edge_idx, edge) in edges.iter().enumerate() {
                    if edge.source == parent_idx {
                        children_indices.push((edge_idx, edge.target));
                    } else if edge.target == parent_idx {
                        children_indices.push((edge_idx, edge.source));
                    }
                }

                let total_children = children_indices.len();
                let mut angle: f32 = 0.0;
                let angle_step = std::f32::consts::TAU / (total_children.max(1) as f32);
                let spawn_radius = 240.0;

                for (edge_idx, target_idx) in children_indices {
                    let target_pos = nodes[parent_idx].pos + egui::vec2(angle.cos() * spawn_radius, angle.sin() * spawn_radius);
                    angle += angle_step;

                    if !nodes[target_idx].visible {
                        nodes[target_idx].pos = target_pos;
                    }
                    nodes[target_idx].visible = true;
                    edges[edge_idx].visible = true;
                }
            }
        }
    }
}
