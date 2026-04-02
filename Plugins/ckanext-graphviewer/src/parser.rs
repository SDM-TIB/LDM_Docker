use log::{debug, error};
use oxttl::N3Parser;
use serde_json::Value;

#[derive(Debug, Clone)]
pub struct RawTriple {
    pub subject: String,
    pub predicate: String,
    pub object: String,
    pub is_object_literal: bool,
}

pub fn parse_n3_file(file_content: &str) -> Vec<RawTriple> {
    let mut triples = Vec::new();
    let parser = N3Parser::new().for_slice(file_content.as_bytes());

    for result in parser {
        match result {
            Ok(quad) => {
                let subject = quad.subject.to_string();
                let predicate = quad.predicate.to_string();
                let object_str = quad.object.to_string();

                let is_object_literal = object_str.starts_with('"');

                triples.push(RawTriple {
                    subject,
                    predicate,
                    object: object_str,
                    is_object_literal,
                });
            }
            Err(e) => error!("Parse error: {}", e),
        }
    }

    triples
}

pub fn parse_author_datasets_json(json_text: &str) -> Vec<RawTriple> {
    let mut triples = Vec::new();

    if let Ok(json) = serde_json::from_str::<serde_json::Value>(json_text) {
        if let Some(results) = json.get("results").and_then(|r| r.as_array()) {
            for item in results {
                let dataset = item
                    .get("dataset")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();
                let author = item
                    .get("author")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();
                let author_label = item
                    .get("author_label")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();
                let title = item
                    .get("title")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();
                let license = item
                    .get("license")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();

                if !dataset.is_empty() {
                    triples.push(RawTriple {
                        subject: format!("<{}>", dataset),
                        predicate: "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>".to_string(),
                        object: "<http://www.w3.org/ns/dcat#Dataset>".to_string(),
                        is_object_literal: false,
                    });

                    if !title.is_empty() {
                        triples.push(RawTriple {
                            subject: format!("<{}>", dataset),
                            predicate: "<http://purl.org/dc/terms/title>".to_string(),
                            object: format!("\"{}\"", title),
                            is_object_literal: true,
                        });
                    }

                    if !license.is_empty() {
                        triples.push(RawTriple {
                            subject: format!("<{}>", dataset),
                            predicate: "<http://purl.org/dc/terms/license>".to_string(),
                            object: format!("<{}>", license),
                            is_object_literal: false,
                        });
                    }

                    if !author.is_empty() {
                        triples.push(RawTriple {
                            subject: format!("<{}>", dataset),
                            predicate: "<http://purl.org/dc/terms/creator>".to_string(),
                            object: format!("<{}>", author),
                            is_object_literal: false,
                        });

                        triples.push(RawTriple {
                            subject: format!("<{}>", author),
                            predicate: "<http://purl.org/spar/pro/authorOf>".to_string(),
                            object: format!("<{}>", dataset),
                            is_object_literal: false,
                        });

                        if !author_label.is_empty() {
                            triples.push(RawTriple {
                                subject: format!("<{}>", author),
                                predicate: "<http://www.w3.org/2000/01/rdf-schema#label>"
                                    .to_string(),
                                object: format!("\"{}\"", author_label),
                                is_object_literal: true,
                            });
                        }
                    }
                }
            }
        }
    }

    triples
}

// parse a the api response for dataset id call
pub fn parse_dataset_details_json(json_text: &str, dataset_id: &str) -> Vec<RawTriple> {
    let mut triples = Vec::new();

    if let Ok(json) = serde_json::from_str::<Value>(json_text) {
        if let Some(results_obj) = json.get("results").and_then(|r| r.as_object()) {
            parse_nested_properties(dataset_id, results_obj, &mut triples);
        }
    }

    if triples.is_empty() {
        println!(
            "WARNING: Parser returned 0 triples! Raw API response was:\n{}",
            json_text
        );
    }

    triples
}

// Helper function that Recursively extracts properties
fn parse_nested_properties(
    subject: &str,
    properties: &serde_json::Map<String, Value>,
    triples: &mut Vec<RawTriple>,
) {
    let subj_str = format!("<{}>", subject);

    for (predicate, value) in properties {
        let pred_str = format!("<{}>", predicate);

        match value {
            // CASE 1: A single leaf object (e.g., {"type": "literal", "value": "EDTA"})
            Value::Object(obj) => {
                parse_leaf_value(&subj_str, &pred_str, obj, triples);
            }
            // CASE 2: An array of items (e.g., Multiple distributions, or array of types)
            Value::Array(arr) => {
                for item in arr {
                    match item {
                        // 2A: An array of direct URI strings (like the 'type' array)
                        Value::String(s) => {
                            triples.push(RawTriple {
                                subject: subj_str.clone(),
                                predicate: pred_str.clone(),
                                object: format!("<{}>", s),
                                is_object_literal: false,
                            });
                        }
                        // 2B: An array of complex Objects
                        Value::Object(obj) => {
                            // Is it a simple leaf value inside an array?
                            if obj.contains_key("type") && obj.contains_key("value") {
                                parse_leaf_value(&subj_str, &pred_str, obj, triples);
                            }
                            // Or is it a deeply nested node? (e.g., {"uri": "...", "properties": {...}})
                            else if let (
                                Some(Value::String(uri)),
                                Some(Value::Object(nested_props)),
                            ) = (obj.get("uri"), obj.get("properties"))
                            {
                                // 1. Create a Triple connecting the parent to this new sub-node
                                triples.push(RawTriple {
                                    subject: subj_str.clone(),
                                    predicate: pred_str.clone(),
                                    object: format!("<{}>", uri),
                                    is_object_literal: false,
                                });

                                // 2. RECURSION: Dive into the sub-node and parse its properties!
                                parse_nested_properties(uri, nested_props, triples);
                            }
                        }
                        _ => {}
                    }
                }
            }
            _ => {}
        }
    }
}

// Helper function to extract {"type": "...", "value": "..."} blocks
fn parse_leaf_value(
    subj_str: &str,
    pred_str: &str,
    obj: &serde_json::Map<String, Value>,
    triples: &mut Vec<RawTriple>,
) {
    if let (Some(t_val), Some(v_val)) = (
        obj.get("type").and_then(|v| v.as_str()),
        obj.get("value").and_then(|v| v.as_str()),
    ) {
        let is_literal = t_val == "literal" || t_val == "typed-literal";
        let obj_str = if is_literal {
            format!("\"{}\"", v_val)
        } else {
            format!("<{}>", v_val)
        };

        triples.push(RawTriple {
            subject: subj_str.to_string(),
            predicate: pred_str.to_string(),
            object: obj_str,
            is_object_literal: is_literal,
        });
    }
}
