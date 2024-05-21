#![allow(non_snake_case)]

use aws_config::meta::region::RegionProviderChain;
use aws_config::BehaviorVersion;
use aws_sdk_sesv2::{
    types::{Body as ses_Body, Content, Destination, EmailContent, Message},
    Client,
};
use lambda_http::{run, service_fn, Body, Error, Request, Response};
use regex::Regex;
use serde::{Deserialize, Serialize};
use std::env;

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
        if &self.email == "test" {
            return true;
        }
        // Regular expression to validate email format
        let re = Regex::new(r"^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$").unwrap();
        re.is_match(&self.email)
    }
}

async fn function_handler(event: Request, client: &Client, from_address: &String, to_address: &String) -> Result<Response<Body>, Error> {
    match event.method().as_str() {
        "POST" => handle_post(event, &client, &from_address, &to_address).await,
        "OPTIONS" => handle_options(),
        _ => {
            // Method not allowed
            Ok(Response::builder().status(405).body(Body::Empty).unwrap())
        }
    }
}

async fn handle_post(event: Request, client: &Client, from_address: &String, to_address: &String) -> Result<Response<Body>, Error> {
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
    send_email(&contact_request, &client, &from_address, &to_address).await?;

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

async fn send_email(contact_request: &ContactRequest, client: &Client, from_address: &String, to_address: &String) -> Result<(), Error> {
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

    if contact_request.email == "test" {
        // Don't send an email if this is a test
    } else {
        client
            .send_email()
            .content(
                EmailContent::builder()
                    .simple(
                        Message::builder()
                            .subject(Content::builder().data(subject).build()?)
                            .body(
                                ses_Body::builder()
                                    .text(Content::builder().data(body_text).build()?)
                                    .html(Content::builder().data(body_html).build()?)
                                    .build(),
                            )
                            .build(),
                    )
                    .build(),
            )
            .destination(Destination::builder().to_addresses(to_address).build())
            .from_email_address(from_address)
            .reply_to_addresses(contact_request.email.clone())
            .send()
            .await?;
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
    // Initialize SES client
    let region_provider = RegionProviderChain::default_provider().or_else("us-east-1");
    let config = aws_config::defaults(BehaviorVersion::latest())
        .region(region_provider)
        .load()
        .await;
    let ses_client = Client::new(&config);

    let from_address = env::var("FromEmail").expect("FromEmail environment variable not set");
    let to_address = env::var("ToEmail").expect("ToEmail environment variable not set");

    run(service_fn(|req: Request| function_handler(req, &ses_client, &from_address, &to_address))).await
}
