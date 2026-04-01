use log::{error, debug};
use oxttl::N3Parser;

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
                let dataset = item.get("dataset").and_then(|v| v.as_str()).unwrap_or("").to_string();
                let author = item.get("author").and_then(|v| v.as_str()).unwrap_or("").to_string();
                let author_label = item.get("author_label").and_then(|v| v.as_str()).unwrap_or("").to_string();
                let title = item.get("title").and_then(|v| v.as_str()).unwrap_or("").to_string();
                let license = item.get("license").and_then(|v| v.as_str()).unwrap_or("").to_string();

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
                                predicate: "<http://www.w3.org/2000/01/rdf-schema#label>".to_string(),
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

// --- NEW: Bulletproof Dataset Parser ---
pub fn parse_dataset_details_json(json_text: &str, dataset_id: &str) -> Vec<RawTriple> {
    let mut triples = Vec::new();

    // 1. Check if we can parse the string as JSON
    if let Ok(json) = serde_json::from_str::<serde_json::Value>(json_text) {
        
        // 2. Extract the array regardless of whether it's wrapped in {"results": [...]} or is just [...] directly
        let results_array = if let Some(arr) = json.as_array() {
            Some(arr)
        } else if let Some(arr) = json.get("results").and_then(|r| r.as_array()) {
            Some(arr)
        } else {
            None
        };

        if let Some(results) = results_array {
            for item in results {
                let mut s_val = dataset_id.to_string(); // Default to dataset if subject is missing
                let mut p_val = String::new();
                let mut o_val = String::new();
                let mut is_lit = false;

                // --- NEW: Read the exact Subject from the sub-queries! ---
                if let Some(s) = item.get("subject").and_then(|v| v.as_str()) {
                    s_val = s.to_string();
                }

                // Try structured format
                if let Some(p) = item.get("predicate").and_then(|v| v.as_str()) {
                    p_val = p.to_string();
                }
                if let Some(o) = item.get("object").and_then(|v| v.as_str()) {
                    o_val = o.to_string();
                }
                if let Some(lit) = item.get("is_literal").and_then(|v| v.as_bool()) {
                    is_lit = lit;
                }

                // Try RAW SPARQL format
                if p_val.is_empty() {
                    if let Some(p_data) = item.get("p") {
                        if let Some(p_str) = p_data.as_str() {
                            p_val = p_str.to_string();
                        } else if let Some(p_obj) = p_data.as_object() {
                            p_val = p_obj.get("value").and_then(|v| v.as_str()).unwrap_or("").to_string();
                        }
                    }
                    if let Some(o_data) = item.get("o") {
                        if let Some(o_str) = o_data.as_str() {
                            o_val = o_str.to_string();
                            is_lit = !o_val.starts_with("http");
                        } else if let Some(o_obj) = o_data.as_object() {
                            o_val = o_obj.get("value").and_then(|v| v.as_str()).unwrap_or("").to_string();
                            let o_type = o_obj.get("type").and_then(|v| v.as_str()).unwrap_or("");
                            is_lit = o_type == "literal" || o_type == "typed-literal";
                        }
                    }
                }

                // Build the Triple using the extracted Subject!
                if !p_val.is_empty() && !o_val.is_empty() {
                    let object_str = if is_lit {
                        format!("\"{}\"", o_val)
                    } else {
                        format!("<{}>", o_val)
                    };

                    triples.push(RawTriple {
                        subject: format!("<{}>", s_val), // <--- Uses the specific subject!
                        predicate: format!("<{}>", p_val),
                        object: object_str,
                        is_object_literal: is_lit,
                    });
                }
            }
        }
    }

    // --- NEW: Safety net for debugging! ---
    // If it STILL fails, it will print exactly what Python sent so you can instantly see the problem in your terminal.
    if triples.is_empty() {
        println!("WARNING: Parser returned 0 triples! Raw API response was:\n{}", json_text);
    }

    triples
}
