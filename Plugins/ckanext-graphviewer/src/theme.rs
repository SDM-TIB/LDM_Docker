use eframe::egui::Color32;
use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct NodeColors {
    pub normal: Color32,
    pub hovered: Color32,
}

pub struct Theme {
    // canvas and background
    pub frame_bg: Color32,
    pub canvas_bg: Color32,

    // edges
    pub edge_line: Color32,
    pub edge_text_bg: Color32,
    pub edge_text: Color32,

    // nodes
    pub node_text: Color32,
    pub default_node: NodeColors,
    pub node_map: HashMap<String, NodeColors>,
}

impl Default for Theme {
    fn default() -> Self {
        let mut node_map = HashMap::new();

        // Dataset (Orange)
        node_map.insert(
            "http://www.w3.org/ns/dcat#Dataset".to_string(),
            NodeColors {
                normal: Color32::from_rgb(255, 165, 0),
                hovered: Color32::from_rgb(255, 200, 100),
            },
        );
        // DataService (Orange)
        node_map.insert(
            "http://www.w3.org/ns/dcat#DataService".to_string(),
            NodeColors {
                normal: Color32::from_rgb(255, 165, 0),
                hovered: Color32::from_rgb(255, 200, 100),
            },
        );
        // Author (Red)
        node_map.insert(
            "http://purl.org/spar/pro/Author".to_string(),
            NodeColors {
                normal: Color32::from_rgb(250, 50, 50),
                hovered: Color32::from_rgb(255, 100, 100),
            },
        );
        // Distribution (Blue)
        node_map.insert(
            "http://www.w3.org/ns/dcat#Distribution".to_string(),
            NodeColors {
                normal: Color32::from_rgb(50, 120, 220),
                hovered: Color32::from_rgb(100, 180, 255),
            },
        );
        // Concept (Green)
        node_map.insert(
            "http://www.w3.org/2004/02/skos/core#Concept".to_string(),
            NodeColors {
                normal: Color32::from_rgb(50, 180, 50),
                hovered: Color32::from_rgb(120, 255, 120),
            },
        );
        // Organization (Purple)
        node_map.insert(
            "http://www.w3.org/2006/vcard/ns#Organization".to_string(),
            NodeColors {
                normal: Color32::from_rgb(150, 80, 220),
                hovered: Color32::from_rgb(200, 150, 255),
            },
        );
        // Literal (Yellow)
        node_map.insert(
            "Literal".to_string(),
            NodeColors {
                normal: Color32::from_rgb(220, 200, 0),
                hovered: Color32::from_rgb(255, 240, 100),
            },
        );

        Self {
            frame_bg: Color32::from_rgb(60, 60, 60),
            canvas_bg: Color32::from_rgb(50, 20, 20),

            edge_line: Color32::from_gray(100),
            edge_text_bg: Color32::from_gray(30),
            edge_text: Color32::WHITE,

            node_text: Color32::WHITE,
            default_node: NodeColors {
                normal: Color32::BLUE,
                hovered: Color32::LIGHT_BLUE,
            },

            node_map,
        }
    }
}

impl Theme {
    pub fn get_node_colors(&self, rdf_type: &str) -> &NodeColors {
        for (key, colors) in &self.node_map {
            if rdf_type.contains(key) {
                return colors;
            }
        }
        &self.default_node
    }
}
