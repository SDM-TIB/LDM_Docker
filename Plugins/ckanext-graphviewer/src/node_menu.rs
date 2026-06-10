use crate::AppState;
use crate::constants::{TYPE_AUTHOR, TYPE_DATASERVICE, TYPE_DATASET};
use crate::graph_processor::{Edge, Node};
use crate::theme::Theme;
use eframe::egui;
use std::sync::{Arc, Mutex};

#[allow(clippy::too_many_arguments)]
pub fn draw_radial_menu(
    ui: &mut egui::Ui,
    ctx: &egui::Context,
    painter: &egui::Painter,
    menu_idx: usize,
    screen_pos: egui::Pos2,
    zoom: f32,
    theme: &Theme,
    nodes: &mut [Node],
    edges: &mut [Edge],
    api_url: &str,
    state: Arc<Mutex<AppState>>,
    show_menu: &mut bool,
    selected_node: &mut Option<usize>,
    clicked_to_expand: &mut Option<usize>,
) {
    let menu_radius = 45.0 * zoom;
    let btn_radius = 12.0 * zoom;

    let current_type = nodes[menu_idx].rdf_type.clone();
    let fetchable_types = vec![TYPE_AUTHOR, TYPE_DATASERVICE, TYPE_DATASET];

    // determine if we need to fetch data
    let is_fetchable = fetchable_types.iter().any(|&t| current_type.contains(t));
    let needs_fetch = is_fetchable && !nodes[menu_idx].api_fetched;

    // determine if any connected edges or nodes are hidden
    let has_hidden_connections = edges.iter().any(|e| {
        if e.source == menu_idx {
            !e.visible || !nodes[e.target].visible
        } else if e.target == menu_idx {
            !e.visible || !nodes[e.source].visible
        } else {
            false
        }
    });

    // show a + if ta node has partially shown edges
    let show_plus = needs_fetch || has_hidden_connections;

    // Angles for the 4 buttons (Top, Top-Right, Right, Bottom-Right)
    let angles = [
        std::f32::consts::PI / -2.0, // Top (-90 deg)
        std::f32::consts::PI / -4.0, // Top-Right (-45 deg)
        0.0,                         // Right (0 deg)
        std::f32::consts::PI / 4.0,  // Bottom-Right (+45 deg)
    ];

    // button 1 expand collapse logic
    let btn1_pos = screen_pos + egui::vec2(angles[0].cos() * menu_radius, angles[0].sin() * menu_radius);
    let btn1_rect = egui::Rect::from_center_size(btn1_pos, egui::vec2(btn_radius * 2.0, btn_radius * 2.0));
    let btn1_resp = ui.interact(btn1_rect, ui.id().with(format!("btn_exp_{}", menu_idx)), egui::Sense::click());

    painter.circle_filled(btn1_pos, btn_radius, theme.menu_expand_bg);
    let icon1 = if show_plus { "+" } else { "-" };
    let galley1 = painter.layout_no_wrap(icon1.into(), egui::FontId::proportional(16.0 * zoom), egui::Color32::WHITE);
    painter.galley(btn1_pos - galley1.size() / 2.0, galley1, egui::Color32::WHITE);

    if btn1_resp.clicked() {
        if needs_fetch {
            // Execute API Fetch
            *show_menu = false;
            *selected_node = None;
            let clicked_node_id = nodes[menu_idx].id.clone();

            if current_type.contains("http://purl.org/spar/pro/Author") {
                crate::api_client::fetch_author_information(
                    ctx.clone(),
                    state.clone(),
                    clicked_node_id.clone(),
                    clicked_node_id.clone(),
                    api_url,
                );
            }

            if current_type.contains("http://www.w3.org/ns/dcat#DataService") || current_type.contains("http://www.w3.org/ns/dcat#Dataset") {
                crate::api_client::fetch_dataset_information(ctx.clone(), state, clicked_node_id.clone(), clicked_node_id, api_url);
            }
        } else {
            // Execute Standard Expand/Collapse
            nodes[menu_idx].expanded = !show_plus;
            *clicked_to_expand = Some(menu_idx);
            *selected_node = None;
        }
    }

    // button 2 info box
    let btn2_pos = screen_pos + egui::vec2(angles[1].cos() * menu_radius, angles[1].sin() * menu_radius);
    let btn2_rect = egui::Rect::from_center_size(btn2_pos, egui::vec2(btn_radius * 2.0, btn_radius * 2.0));
    let btn2_resp = ui.interact(btn2_rect, ui.id().with(format!("btn_info_{}", menu_idx)), egui::Sense::click());

    painter.circle_filled(btn2_pos, btn_radius, theme.menu_info_bg);
    let galley2 = painter.layout_no_wrap("i".into(), egui::FontId::proportional(14.0 * zoom), egui::Color32::WHITE);
    painter.galley(btn2_pos - galley2.size() / 2.0, galley2, egui::Color32::WHITE);

    if btn2_resp.clicked() {
        *show_menu = false;
    }

    // button 3 copy node id
    let btn3_pos = screen_pos + egui::vec2(angles[2].cos() * menu_radius, angles[2].sin() * menu_radius);
    let btn3_rect = egui::Rect::from_center_size(btn3_pos, egui::vec2(btn_radius * 2.0, btn_radius * 2.0));
    let btn3_resp = ui.interact(btn3_rect, ui.id().with(format!("btn_copy_{}", menu_idx)), egui::Sense::click());

    painter.circle_filled(btn3_pos, btn_radius, theme.menu_api_bg);
    let galley3 = painter.layout_no_wrap("C".into(), egui::FontId::proportional(14.0 * zoom), egui::Color32::WHITE);
    painter.galley(btn3_pos - galley3.size() / 2.0, galley3, egui::Color32::WHITE);

    if btn3_resp.clicked() {
        // Send Node ID to the system clipboard
        ctx.copy_text(nodes[menu_idx].id.clone());
        *show_menu = false;
        *selected_node = None;
    }

    // button 4 hide node
    let btn4_pos = screen_pos + egui::vec2(angles[3].cos() * menu_radius, angles[3].sin() * menu_radius);
    let btn4_rect = egui::Rect::from_center_size(btn4_pos, egui::vec2(btn_radius * 2.0, btn_radius * 2.0));
    let btn4_resp = ui.interact(btn4_rect, ui.id().with(format!("btn_hide_{}", menu_idx)), egui::Sense::click());

    // Standard red tone for hide/delete context
    painter.circle_filled(btn4_pos, btn_radius, theme.menu_hide_bg);
    let galley4 = painter.layout_no_wrap("x".into(), egui::FontId::proportional(14.0 * zoom), egui::Color32::WHITE);
    painter.galley(btn4_pos - galley4.size() / 2.0, galley4, egui::Color32::WHITE);

    if btn4_resp.clicked() {
        // 1. Hide the node itself
        nodes[menu_idx].visible = false;

        // 2. Hide all edges connecting to it
        for edge in edges.iter_mut() {
            if edge.source == menu_idx || edge.target == menu_idx {
                edge.visible = false;
            }
        }

        *show_menu = false;
        *selected_node = None;
    }
}
