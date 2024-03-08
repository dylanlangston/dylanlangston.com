#![allow(non_snake_case)]

use lambda_http::{run, service_fn, Body, Error, Request, Response};
use rusoto_core::Region;
use rusoto_ses::{Body as SesBody, Content, Destination, Message, SendEmailRequest, Ses};
use serde::Deserialize;

#[derive(Debug, Deserialize)]
struct ContactRequest {
    firstName: String,
    lastName: String,
    phone: String,
    email: String,
    message: String,
}

async fn function_handler(event: Request) -> Result<Response<Body>, Error> {
    // Deserialize JSON into ContactRequest struct
    let contact_request: ContactRequest = serde_json::from_slice(event.body())?;

    // Send email using AWS SES
    send_email(&contact_request).await?;

    // Return HTTP response
    let resp = Response::builder()
        .status(200)
        .body(Body::Empty)
        .expect("Failed to build response");

    Ok(resp)
}

async fn send_email(contact_request: &ContactRequest) -> Result<(), Error> {
    // Initialize SES client
    let ses_client = rusoto_ses::SesClient::new(Region::default());

    // Construct email message
    let subject = format!(
        "Contact Request - {} {}",
        contact_request.firstName, contact_request.lastName
    );
    let body = format!(
        "Phone: {}\nEmail: {}\nMessage: {}",
        contact_request.phone, contact_request.email, contact_request.message
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
                    data: body,
                    charset: Some("UTF-8".to_string()),
                }),
                ..Default::default()
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

#[tokio::main]
async fn main() -> Result<(), Error> {
    run(service_fn(function_handler)).await
}
