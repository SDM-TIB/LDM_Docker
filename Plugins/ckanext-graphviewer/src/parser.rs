use log::error;
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

pub fn parse_dataset_details_json(json_text: &str, dataset_id: &str) -> Vec<RawTriple> {
    let mut triples = Vec::new();

    if let Ok(json) = serde_json::from_str::<serde_json::Value>(json_text) {
        if let Some(results) = json.get("results").and_then(|r| r.as_array()) {
            for item in results {
                let p = item.get("predicate").and_then(|v| v.as_str()).unwrap_or("");
                let o = item.get("object").and_then(|v| v.as_str()).unwrap_or("");
                let is_literal = item.get("is_literal").and_then(|v| v.as_bool()).unwrap_or(false);

                if !p.is_empty() && !o.is_empty() {
                    let object_str = if is_literal {
                        format!("\"{}\"", o)
                    } else {
                        format!("<{}>", o)
                    };

                    triples.push(RawTriple {
                        subject: format!("<{}>", dataset_id),
                        predicate: format!("<{}>", p),
                        object: object_str,
                        is_object_literal: is_literal,
                    });
                }
            }
        }
    }

    triples
}
