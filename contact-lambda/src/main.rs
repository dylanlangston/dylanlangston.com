#![allow(non_snake_case)]

use lambda_http::{run, service_fn, Body, Error, Request, Response};
use regex::Regex;
use rusoto_core::Region;
use rusoto_ses::{Body as SesBody, Content, Destination, Message, SendEmailRequest, Ses};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
struct ContactRequest {
    #[serde(rename = "firstName")]
    first_name: String,
    #[serde(rename = "lastName")]
    last_name: String,
    email: String,
    message: String,
    phone: Option<String>,
}

impl ContactRequest {
    fn validate(&self) -> Result<(), String> {
        if self.first_name.is_empty() {
            return Err("First name is required.".to_string());
        }
        if self.last_name.is_empty() {
            return Err("Last name is required.".to_string());
        }
        if self.email.is_empty() {
            return Err("Email address is required.".to_string());
        }
        if !self.is_valid_email() {
            return Err("Invalid email address.".to_string());
        }
        if self.message.is_empty() {
            return Err("Message is required.".to_string());
        }
        Ok(())
    }

    fn is_valid_email(&self) -> bool {
        // Regular expression to validate email format
        let re = Regex::new(r"^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$").unwrap();
        re.is_match(&self.email)
    }
}

async fn function_handler(event: Request) -> Result<Response<Body>, Error> {
    match event.method().as_str() {
        "POST" => handle_post(event).await,
        "OPTIONS" => handle_options(),
        _ => {
            // Method not allowed
            Ok(Response::builder()
                .status(405)
                .body(Body::Empty)
                .unwrap())
        }
    }
}

async fn handle_post(event: Request) -> Result<Response<Body>, Error> {
    // Deserialize JSON into ContactRequest struct
    let contact_request: ContactRequest = match serde_json::from_slice(event.body()) {
        Ok(req) => req,
        Err(_) => {
            return Ok(Response::builder()
                .status(400)
                .body(Body::Text("Invalid JSON data".to_string()))
                .unwrap())
        }
    };

    // Validate the input
    if let Err(error) = contact_request.validate() {
        return Ok(Response::builder()
            .status(400)
            .body(Body::Text(error))
            .unwrap());
    }

    // Send email using AWS SES
    send_email(&contact_request).await?;

    // Return HTTP response
    let resp = Response::builder()
        .status(200)
        .header("Access-Control-Allow-Origin", "*")
        .header("Access-Control-Allow-Methods", "POST, OPTIONS")
        .header("Access-Control-Allow-Headers", "Content-Type")
        .body(Body::Empty)
        .expect("Failed to build response");

    Ok(resp)
}

fn handle_options() -> Result<Response<Body>, Error> {
    // Return CORS headers for OPTIONS request
    Ok(Response::builder()
        .status(200)
        .header("Access-Control-Allow-Origin", "*")
        .header("Access-Control-Allow-Methods", "POST, OPTIONS")
        .header("Access-Control-Allow-Headers", "Content-Type")
        .body(Body::Empty)
        .unwrap())
}

async fn send_email(contact_request: &ContactRequest) -> Result<(), Error> {
    // Initialize SES client
    let ses_client = rusoto_ses::SesClient::new(Region::default());

    // Construct email message
    let subject = format!(
        "Contact Request - {} {}",
        contact_request.first_name, contact_request.last_name
    );

    let body_text = format!(
        "{}\nEmail: {}\nMessage: {}",
        if let Some(phone) = &contact_request.phone {
            format!("Phone: {}", phone)
        } else {
            "".to_string()
        },
        contact_request.email,
        contact_request.message
    );
    
    let html_message = encode_special_characters(&contact_request.message);
    let body_html = format!(
        "{}<br/><b>Email:</b> {}<br/><b>Message:</b> {}",
        if let Some(phone) = &contact_request.phone {
            format!("<b>Phone:</b> {}", phone)
        } else {
            "".to_string()
        },
        contact_request.email,
        html_message
    );
    
    // Construct SES request
    let request = SendEmailRequest {
        destination: Destination {
            to_addresses: Some(vec!["dylanlangston@gmail.com".to_string()]),
            ..Default::default()
        },
        message: Message {
            body: SesBody {
                text: Some(Content {
                    data: body_text,
                    charset: Some("UTF-8".to_string()),
                }),
                html: Some(Content {
                    data: body_html,
                    charset: Some("UTF-8".to_string()),
                }),
            },
            subject: Content {
                data: subject,
                charset: Some("UTF-8".to_string()),
            },
        },
        source: "mail@dylanlangston.com".to_string(),
        reply_to_addresses: Some(vec![contact_request.email.clone()]),
        ..Default::default()
    };

    if contact_request.email == "test" {
        // Don't send an email if this is a test
    } else {
        // Send email
        ses_client.send_email(request).await?;
    }

    Ok(())
}

fn encode_special_characters(input: &str) -> String {
    let mut encoded = String::new();
    for ch in input.chars() {
        match ch {
            '<' => encoded.push_str("&lt;"),
            '>' => encoded.push_str("&gt;"),
            '&' => encoded.push_str("&amp;"),
            '"' => encoded.push_str("&quot;"),
            '\'' => encoded.push_str("&apos;"),
            _ => encoded.push(ch),
        }
    }
    encoded
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    run(service_fn(function_handler)).await
}
