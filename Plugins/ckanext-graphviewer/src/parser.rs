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
