use eframe::egui::Color32;
use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct NodeColors {
    pub normal: Color32,
    pub hovered: Color32,
}

pub struct Theme {
    // debug
    pub debug: Color32,

    // background and button color
    pub master_bg: Color32,
    pub painter_bg: Color32,
    pub button_bg: Color32,
    pub button_active_bg: Color32,

    pub menu_expand_bg: Color32,
    pub menu_info_bg: Color32,
    pub menu_api_bg: Color32,
    pub menu_api_fetched_bg: Color32,

    // text color
    pub text_fg: Color32,

    // edge color
    pub edge_fg: Color32,

    // node color
    pub default_node: NodeColors,
    pub node_map: HashMap<String, NodeColors>,
}

impl Theme {
    pub fn get_node_colors(&self, rdf_type: &str) -> NodeColors {
        // this loop is not realy needed but is still in here because a thing can have multiple types
        for single_type in rdf_type.split(", ") {
            if let Some(colors) = self.node_map.get(single_type) {
                return colors.clone();
            }
        }

        // fallback
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
            text_fg: Color32::from_rgb(240, 240, 245),
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
            button_bg: Color32::from_rgb(220, 220, 225),
            button_active_bg: Color32::from_rgb(255, 255, 255),
            menu_expand_bg: Color32::from_rgb(70, 130, 200),
            menu_info_bg: Color32::from_rgb(100, 180, 100),
            menu_api_bg: Color32::from_rgb(220, 140, 50),
            menu_api_fetched_bg: Color32::from_rgb(150, 150, 150),
            painter_bg: Color32::from_rgb(255, 255, 255),
            text_fg: Color32::from_rgb(30, 30, 35),
            edge_fg: Color32::from_rgb(170, 170, 180),
            default_node: NodeColors {
                normal: Color32::from_rgb(150, 150, 150),
                hovered: Color32::from_rgb(110, 110, 110),
            },
            node_map: Self::node_color_map(),
        }
    }
}
