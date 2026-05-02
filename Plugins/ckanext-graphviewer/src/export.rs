use crate::graph_processor::{Edge, Node};
use crate::theme::Theme;
use eframe::egui::Color32;

// Helper to convert egui::Color32 to a web-friendly hex string
fn color_to_hex(color: Color32) -> String {
    format!("#{:02X}{:02X}{:02X}", color.r(), color.g(), color.b())
}

/// Generates an SVG string containing the graph and an external information panel
pub fn generate_svg(nodes: &[Node], edges: &[Edge], theme: &Theme) -> String {
    // 1. Calculate the bounding box of the visible graph
    let mut min_x = f32::MAX;
    let mut max_x = f32::MIN;
    let mut min_y = f32::MAX;
    let mut max_y = f32::MIN;
    let mut visible_node_count = 0;

    for n in nodes {
        if !n.visible {
            continue;
        }
        visible_node_count += 1;
        if n.pos.x < min_x {
            min_x = n.pos.x;
        }
        if n.pos.x > max_x {
            max_x = n.pos.x;
        }
        if n.pos.y < min_y {
            min_y = n.pos.y;
        }
        if n.pos.y > max_y {
            max_y = n.pos.y;
        }
    }

    // Fallback if the graph is completely empty
    if visible_node_count == 0 {
        min_x = 0.0;
        max_x = 800.0;
        min_y = 0.0;
        max_y = 600.0;
    }

    // 2. Define Canvas Dimensions
    let padding = 60.0;
    let graph_width = (max_x - min_x) + (padding * 2.0);
    let graph_height = (max_y - min_y) + (padding * 2.0);

    let panel_width = 300.0;
    let total_width = graph_width + panel_width;
    let total_height = graph_height.max(600.0); // Ensure it's at least 600px tall for the sidebar

    let bg_color = color_to_hex(theme.master_bg);
    let text_color = color_to_hex(theme.text_fg);
    let edge_color = color_to_hex(theme.edge_fg);

    let mut svg = String::new();
    svg.push_str(&format!(
        "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 {} {}\" width=\"{}\" height=\"{}\" style=\"background-color: {}; font-family: sans-serif;\">\n",
        total_width, total_height, total_width, total_height, bg_color
    ));

    // ==========================================
    // --- GRAPH AREA (Left Side) ---
    // ==========================================
    svg.push_str("  <g id=\"graph_area\">\n");

    // Draw Edges First (so they appear underneath nodes)
    for edge in edges {
        if !edge.visible {
            continue;
        }
        let source_pos = nodes[edge.source].pos;
        let target_pos = nodes[edge.target].pos;

        // Shift positions by min bounds + padding so everything is strictly positive in the SVG
        let x1 = source_pos.x - min_x + padding;
        let y1 = source_pos.y - min_y + padding;
        let x2 = target_pos.x - min_x + padding;
        let y2 = target_pos.y - min_y + padding;

        svg.push_str(&format!(
            "    <line x1=\"{:.1}\" y1=\"{:.1}\" x2=\"{:.1}\" y2=\"{:.1}\" stroke=\"{}\" stroke-width=\"1.5\" opacity=\"0.6\" />\n",
            x1, y1, x2, y2, edge_color
        ));
    }

    // Draw Nodes
    for node in nodes {
        if !node.visible {
            continue;
        }
        let x = node.pos.x - min_x + padding;
        let y = node.pos.y - min_y + padding;

        let node_color = theme.get_node_colors(&node.rdf_type).normal;
        let fill_hex = color_to_hex(node_color);
        let radius = if node.is_root { 18.0 } else { 12.0 };

        svg.push_str(&format!(
            "    <circle cx=\"{:.1}\" cy=\"{:.1}\" r=\"{:.1}\" fill=\"{}\" stroke=\"{}\" stroke-width=\"2\" />\n",
            x, y, radius, fill_hex, bg_color
        ));

        // Node Label
        svg.push_str(&format!(
            "    <text x=\"{:.1}\" y=\"{:.1}\" fill=\"{}\" font-size=\"12\" text-anchor=\"middle\">{}</text>\n",
            x,
            y + radius + 14.0,
            text_color,
            node.label
        ));
    }
    svg.push_str("  </g>\n");

    // ==========================================
    // --- EXTERNAL INFO PANEL (Right Side) ---
    // ==========================================
    svg.push_str(&format!("  <g id=\"info_panel\" transform=\"translate({}, 0)\">\n", graph_width));

    // Panel Background (Slightly darker/lighter than master_bg to separate it)
    let panel_bg = color_to_hex(theme.button_bg);
    svg.push_str(&format!(
        "    <rect x=\"0\" y=\"0\" width=\"{}\" height=\"{}\" fill=\"{}\" />\n",
        panel_width, total_height, panel_bg
    ));

    // Panel Title
    svg.push_str(&format!(
        "    <text x=\"20\" y=\"40\" fill=\"{}\" font-size=\"22\" font-weight=\"bold\">Graph Analytics</text>\n",
        text_color
    ));

    // Stats
    svg.push_str(&format!(
        "    <text x=\"20\" y=\"80\" fill=\"{}\" font-size=\"14\">Total Nodes Loaded: {}</text>\n",
        text_color,
        nodes.len()
    ));
    svg.push_str(&format!(
        "    <text x=\"20\" y=\"105\" fill=\"{}\" font-size=\"14\">Visible Nodes: {}</text>\n",
        text_color, visible_node_count
    ));

    // Legend Header
    svg.push_str(&format!(
        "    <text x=\"20\" y=\"155\" fill=\"{}\" font-size=\"18\" font-weight=\"bold\">Legend</text>\n",
        text_color
    ));

    // Render Legend entries from the theme dynamically
    let mut current_y = 190.0;
    for (rdf_type, colors) in &theme.node_map {
        let clean_name = rdf_type.split('/').last().unwrap_or(rdf_type).split('#').last().unwrap_or(rdf_type);

        svg.push_str(&format!(
            "    <circle cx=\"30\" cy=\"{:.1}\" r=\"8\" fill=\"{}\" />\n",
            current_y - 4.0,
            color_to_hex(colors.normal)
        ));
        svg.push_str(&format!(
            "    <text x=\"50\" y=\"{:.1}\" fill=\"{}\" font-size=\"14\">{}</text>\n",
            current_y, text_color, clean_name
        ));
        current_y += 30.0;
    }

    svg.push_str("  </g>\n");
    svg.push_str("</svg>");

    svg
}

// ---------------------------------------------------------
// Placeholders for future implementations
// ---------------------------------------------------------

pub fn generate_n3(_nodes: &[Node], _edges: &[Edge]) -> String {
    String::from("# N3 Export not yet implemented.\n")
}

pub fn generate_json(_nodes: &[Node], _edges: &[Edge]) -> String {
    String::from("{\n  \"status\": \"JSON Export not yet implemented\"\n}")
}
