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

pub fn parse_dynamic_api_json(json_text: &str) -> Vec<RawTriple> {
    let mut triples = Vec::new();

    if let Ok(json) = serde_json::from_str::<Value>(json_text) {
        if let Some(results_obj) = json.get("results").and_then(|r| r.as_object()) {
            for (entity_uri, properties) in results_obj {
                triples.push(RawTriple {
                    subject: format!("<{}>", entity_uri),
                    predicate: "<http://app.local/isRootNode>".to_string(),
                    object: "\"true\"".to_string(),
                    is_object_literal: true,
                });

                if let Some(props_map) = properties.as_object() {
                    parse_nested_properties(entity_uri, props_map, &mut triples);
                }
            }
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

// helper function for dynamic json
fn parse_nested_properties(
    subject: &str,
    properties: &serde_json::Map<String, Value>,
    triples: &mut Vec<RawTriple>,
) {
    let subj_str = format!("<{}>", subject);

    for (predicate, value) in properties {
        let pred_str = format!("<{}>", predicate);

        match value {
            // case 1 a single leaf object
            Value::Object(obj) => {
                parse_leaf_value(&subj_str, &pred_str, obj, triples);
            }
            // case 2 array of items
            Value::Array(arr) => {
                for item in arr {
                    match item {
                        // case 2a an array of uri
                        Value::String(s) => {
                            triples.push(RawTriple {
                                subject: subj_str.clone(),
                                predicate: pred_str.clone(),
                                object: format!("<{}>", s),
                                is_object_literal: false,
                            });
                        }
                        // case 2b complex case
                        Value::Object(obj) => {
                            if obj.contains_key("type") && obj.contains_key("value") {
                                parse_leaf_value(&subj_str, &pred_str, obj, triples);
                            } else if let (
                                Some(Value::String(uri)),
                                Some(Value::Object(nested_props)),
                            ) = (obj.get("uri"), obj.get("properties"))
                            {
                                triples.push(RawTriple {
                                    subject: subj_str.clone(),
                                    predicate: pred_str.clone(),
                                    object: format!("<{}>", uri),
                                    is_object_literal: false,
                                });

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
