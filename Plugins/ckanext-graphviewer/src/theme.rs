use eframe::egui::{Color32, Stroke, Visuals};
use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct NodeColors {
    pub normal: Color32,
    pub hovered: Color32,
}

pub struct Theme {
    // Debug
    pub debug: Color32,

    // Backgrounds and Button Colors
    pub master_bg: Color32,
    pub painter_bg: Color32,
    pub button_bg: Color32,
    pub button_active_bg: Color32,

    // Radial Menu Colors
    pub menu_expand_bg: Color32,
    pub menu_info_bg: Color32,
    pub menu_api_bg: Color32,
    pub menu_api_fetched_bg: Color32,
    pub menu_hide_bg: Color32,

    // Text Colors
    pub text_fg: Color32,
    pub dimmed_text_fg: Color32,
    pub error_fg: Color32,

    // Edge Colors
    pub edge_fg: Color32,

    // Node Colors
    pub default_node: NodeColors,
    pub node_map: HashMap<String, NodeColors>,
}

impl Theme {
    pub fn get_node_colors(&self, rdf_type: &str) -> NodeColors {
        // This loop handles items with multiple types separated by commas
        for single_type in rdf_type.split(", ") {
            if let Some(colors) = self.node_map.get(single_type) {
                return colors.clone();
            }
        }

        // Fallback to default if no matching type is found
        self.default_node.clone()
    }

    fn node_color_map() -> HashMap<String, NodeColors> {
        let mut node_map = HashMap::new();
        node_map.insert(
            "http://www.w3.org/ns/dcat#Dataset".to_string(),
            NodeColors {
                normal: Color32::from_rgb(255, 165, 0),
                hovered: Color32::from_rgb(255, 200, 100),
            },
        );
        node_map.insert(
            "http://www.w3.org/ns/dcat#DataService".to_string(),
            NodeColors {
                normal: Color32::from_rgb(255, 165, 0),
                hovered: Color32::from_rgb(255, 200, 100),
            },
        );
        node_map.insert(
            "http://www.w3.org/ns/dcat#Distribution".to_string(),
            NodeColors {
                normal: Color32::from_rgb(50, 150, 255),
                hovered: Color32::from_rgb(100, 200, 255),
            },
        );
        node_map.insert(
            "http://purl.org/spar/pro/Author".to_string(),
            NodeColors {
                normal: Color32::from_rgb(220, 50, 50),
                hovered: Color32::from_rgb(255, 100, 100),
            },
        );
        node_map.insert(
            "http://www.w3.org/2004/02/skos/core#Concept".to_string(),
            NodeColors {
                normal: Color32::from_rgb(50, 180, 50),
                hovered: Color32::from_rgb(120, 255, 120),
            },
        );
        node_map.insert(
            "http://www.w3.org/2006/vcard/ns#Organization".to_string(),
            NodeColors {
                normal: Color32::from_rgb(150, 80, 220),
                hovered: Color32::from_rgb(200, 150, 255),
            },
        );
        node_map.insert(
            "Literal".to_string(),
            NodeColors {
                normal: Color32::from_rgb(220, 200, 0),
                hovered: Color32::from_rgb(255, 240, 100),
            },
        );

        node_map
    }

    pub fn dark() -> Self {
        Self {
            debug: Color32::RED,
            master_bg: Color32::from_rgb(30, 30, 35),
            painter_bg: Color32::from_rgb(50, 50, 55),
            button_bg: Color32::from_rgb(70, 70, 75),
            button_active_bg: Color32::from_rgb(100, 100, 105),
            menu_expand_bg: Color32::from_rgb(70, 130, 200),
            menu_info_bg: Color32::from_rgb(100, 180, 100),
            menu_api_bg: Color32::from_rgb(220, 140, 50),
            menu_api_fetched_bg: Color32::from_rgb(150, 150, 150),
            menu_hide_bg: Color32::from_rgb(200, 70, 70),
            text_fg: Color32::from_rgb(240, 240, 245),
            dimmed_text_fg: Color32::GRAY,
            error_fg: Color32::from_rgb(255, 100, 100),
            edge_fg: Color32::from_rgb(120, 120, 130),
            default_node: NodeColors {
                normal: Color32::from_rgb(140, 140, 140),
                hovered: Color32::from_rgb(180, 180, 180),
            },
            node_map: Self::node_color_map(),
        }
    }

    pub fn light() -> Self {
        Self {
            debug: Color32::RED,
            master_bg: Color32::from_rgb(240, 240, 245),
            painter_bg: Color32::from_rgb(255, 255, 255),
            button_bg: Color32::from_rgb(220, 220, 225),
            button_active_bg: Color32::from_rgb(255, 255, 255),
            menu_expand_bg: Color32::from_rgb(70, 130, 200),
            menu_info_bg: Color32::from_rgb(100, 180, 100),
            menu_api_bg: Color32::from_rgb(220, 140, 50),
            menu_api_fetched_bg: Color32::from_rgb(150, 150, 150),
            menu_hide_bg: Color32::from_rgb(220, 80, 80),
            text_fg: Color32::from_rgb(30, 30, 35),
            dimmed_text_fg: Color32::from_rgb(120, 120, 120),
            error_fg: Color32::from_rgb(200, 50, 50),
            edge_fg: Color32::from_rgb(170, 170, 180),
            default_node: NodeColors {
                normal: Color32::from_rgb(150, 150, 150),
                hovered: Color32::from_rgb(110, 110, 110),
            },
            node_map: Self::node_color_map(),
        }
    }

    pub fn testing_red() -> Self {
        Self {
            debug: Color32::YELLOW,
            master_bg: Color32::from_rgb(40, 0, 0),
            painter_bg: Color32::from_rgb(20, 0, 0),
            button_bg: Color32::from_rgb(120, 0, 0),
            button_active_bg: Color32::from_rgb(200, 0, 0),
            menu_expand_bg: Color32::from_rgb(160, 0, 0),
            menu_info_bg: Color32::from_rgb(180, 0, 0),
            menu_api_bg: Color32::from_rgb(200, 0, 0),
            menu_api_fetched_bg: Color32::from_rgb(150, 0, 0),
            menu_hide_bg: Color32::from_rgb(255, 50, 50),
            text_fg: Color32::from_rgb(255, 180, 180),
            dimmed_text_fg: Color32::from_rgb(180, 50, 50),
            error_fg: Color32::YELLOW,
            edge_fg: Color32::from_rgb(255, 0, 0),
            default_node: NodeColors {
                normal: Color32::from_rgb(255, 0, 0),
                hovered: Color32::from_rgb(255, 100, 100),
            },
            node_map: std::collections::HashMap::new(), // Makes everything fall back to the red default_node
        }
    }

    pub fn to_egui_visuals(&self) -> Visuals {
        let mut visuals = if self.master_bg == Color32::from_rgb(240, 240, 245) {
            Visuals::light()
        } else {
            Visuals::dark()
        };

        // 1. Sync global window backgrounds
        visuals.window_fill = self.painter_bg;
        visuals.panel_fill = self.master_bg;
        visuals.extreme_bg_color = self.painter_bg;
        visuals.faint_bg_color = self.button_bg; // Used for striped grids

        // 2. Sync widget BACKGROUND states
        visuals.widgets.inactive.bg_fill = self.button_bg;
        visuals.widgets.inactive.weak_bg_fill = self.button_bg;

        visuals.widgets.hovered.bg_fill = self.button_active_bg;
        visuals.widgets.hovered.weak_bg_fill = self.button_active_bg;

        visuals.widgets.active.bg_fill = self.menu_expand_bg;
        visuals.widgets.active.weak_bg_fill = self.menu_expand_bg;

        visuals.widgets.open.bg_fill = self.button_active_bg;
        visuals.widgets.open.weak_bg_fill = self.button_active_bg;

        // 3. Sync widget FOREGROUND (Text) states
        let default_text_stroke = Stroke::new(1.0, self.text_fg);
        visuals.widgets.noninteractive.fg_stroke = default_text_stroke; // Standard ui.label()
        visuals.widgets.inactive.fg_stroke = default_text_stroke; // Standard button text
        visuals.widgets.hovered.fg_stroke = default_text_stroke; // Hovered button text
        visuals.widgets.active.fg_stroke = default_text_stroke; // Clicked button text
        visuals.widgets.open.fg_stroke = default_text_stroke; // Expanded menu text

        // 4. Specialized Colors and Strokes
        visuals.error_fg_color = self.error_fg;
        visuals.warn_fg_color = self.error_fg;
        visuals.window_stroke = Stroke::new(1.0, self.edge_fg);

        // 5. Selection (Highlights & Active Tabs)
        visuals.selection.bg_fill = self.menu_expand_bg;
        visuals.selection.stroke = Stroke::new(1.0, self.text_fg);

        // The blinking cursor in the search bar
        visuals.text_cursor.stroke = eframe::egui::Stroke::new(2.0, self.text_fg);

        // Hyperlinks (We'll borrow your blue/red expand button color as an accent!)
        visuals.hyperlink_color = self.menu_expand_bg;

        // Background for inline code blocks like `this` (if you ever use them)
        visuals.code_bg_color = self.button_bg;

        // Widget Borders (The outline around buttons and the search bar)
        let default_border = eframe::egui::Stroke::new(1.0, self.edge_fg);
        visuals.widgets.noninteractive.bg_stroke = default_border;
        visuals.widgets.inactive.bg_stroke = default_border;
        visuals.widgets.hovered.bg_stroke = default_border;
        visuals.widgets.active.bg_stroke = default_border;
        visuals.widgets.open.bg_stroke = default_border;

        visuals
    }
}
