use aws_config::meta::region::RegionProviderChain;
use aws_config::BehaviorVersion;
use aws_sdk_s3::{primitives::Blob, Client as S3Client};
use aws_sdk_sesv2::types::{Destination, EmailContent, RawMessage};
use aws_sdk_sesv2::Client as SesClient;
use email::MimeMessage;
use env_logger;
use lambda_runtime::{service_fn, LambdaEvent};
use log::{info, warn};
use serde_json::Value;
use tokio::io::AsyncReadExt;

struct Clients {
    s3_client: S3Client,
    ses_client: SesClient,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize the logger
    env_logger::init();

    // Initialize SES and S3 clients
    info!("Initializing AWS clients");
    let region_provider = RegionProviderChain::default_provider().or_else("us-east-1");
    let config = aws_config::defaults(BehaviorVersion::latest())
        .region(region_provider)
        .load()
        .await;
    let clients = Clients {
        s3_client: S3Client::new(&config),
        ses_client: SesClient::new(&config),
    };

    let func = service_fn(|event: LambdaEvent<Value>| my_handler(event, &clients));
    let _ = lambda_runtime::run(func).await;
    Ok(())
}

async fn my_handler(event: LambdaEvent<Value>, clients: &Clients) -> Result<(), Box<dyn std::error::Error>> {
    // Get email details from SES event
    info!("Extracting email details from the event");
    let email = event
        .payload
        .get("Records")
        .and_then(|records| records.get(0))
        .and_then(|record| record.get("ses").and_then(|ses| ses.get("mail")));
    let _recipients = event
        .payload
        .get("Records")
        .and_then(|records| records.get(0))
        .and_then(|record| {
            record.get("ses").and_then(|ses| {
                ses.get("receipt")
                    .and_then(|receipt| receipt.get("recipients"))
            })
        });
    let message_id = email
        .and_then(|mail| mail.get("messageId"))
        .and_then(|message_id| message_id.as_str());
    info!("Message ID: {:?}", message_id);

    // Get environment variables
    info!("Retrieving environment variables");
    let to_email = std::env::var("ToEmail").expect("ToEmail environment variable is not set");
    let from_email = std::env::var("FromEmail").expect("FromEmail environment variable is not set");
    info!("ToEmail: {}, FromEmail: {}", to_email, from_email);

    // Fetch raw email from S3
    let raw_email = match message_id {
        Some(message_id) => {
            info!("Fetching raw email from S3 for message ID: {}", message_id);
            let bucket = std::env::var("AwsS3BucketName")
                .expect("AwsS3BucketName environment variable is not set");
            let key = format!("{}/{}", bucket, message_id);
            info!("S3 Bucket: {}, Key: {}", bucket, key);

            let response = clients.s3_client
                .get_object()
                .bucket(bucket)
                .key(key)
                .send()
                .await?;
            info!("Successfully fetched email from S3");

            let mut reader = response.body.into_async_read();
            let mut buffer = Vec::new();
            reader.read_to_end(&mut buffer).await?;
            info!("Email read from S3 into buffer");

            let email = String::from_utf8(buffer)?;
            let mime_msg = MimeMessage::parse(&email)?;
            info!("Email parsed successfully");

            let sanitized_msg = mime_msg.as_string_without_headers();

            info!("{}", sanitized_msg);

            Some(Blob::new(sanitized_msg.into_bytes()))
        }
        None => {
            warn!("Message ID is missing in the SES event");
            None
        }
    };

    // Forward email using SES
    if let Some(raw_email) = raw_email {
        info!("Forwarding email using SES");
        clients.ses_client
            .send_email()
            .content(
                EmailContent::builder()
                    .raw(RawMessage::builder().data(raw_email).build()?)
                    .build(),
            )
            .destination(Destination::builder().to_addresses(to_email).build())
            .from_email_address(from_email)
            .send()
            .await?;
        info!("Email forwarded successfully");

        Ok(())
    } else {
        // Handle missing message_id
        Err("Missing messageId in SES event".into())
    }
}
