use aws_config::meta::region::RegionProviderChain;
use aws_config::BehaviorVersion;
use aws_sdk_s3::{primitives::Blob, Client as S3Client};
use aws_sdk_sesv2::types::{Destination, EmailContent, RawMessage};
use aws_sdk_sesv2::Client as SesClient;
use email::{Header, MimeMessage};
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
async fn main() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
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

    let from_address = std::env::var("FromEmail").expect("FromEmail environment variable not set");
    let to_address = std::env::var("ToEmail").expect("ToEmail environment variable not set");
    let bucket =
        std::env::var("AwsS3BucketName").expect("AwsS3BucketName environment variable not set");

    let func = service_fn(|event: LambdaEvent<Value>| {
        my_handler(event, &clients, &from_address, &to_address, &bucket)
    });
    lambda_runtime::run(func).await?;
    Ok(())
}

async fn my_handler(
    event: LambdaEvent<Value>,
    clients: &Clients,
    from_email: &String,
    to_email: &String,
    bucket: &String,
) -> Result<(), Box<dyn std::error::Error>> {
    // Get email details from SES event
    info!("Extracting email details from the event");
    let email = event
        .payload
        .get("Records")
        .and_then(|records| records.get(0))
        .and_then(|record| record.get("ses").and_then(|ses| ses.get("mail")));
    let message_id = email
        .and_then(|mail| mail.get("messageId"))
        .and_then(|message_id| message_id.as_str());
    info!("Message ID: {:?}", message_id);

    // Fetch raw email from S3
    let raw_email = match message_id {
        Some(message_id) => {
            info!("Fetching raw email from S3 for message ID: {}", message_id);
            let key = format!("{}", message_id);
            info!("S3 Bucket: {}, Key: {}", bucket, key);

            let response = clients
                .s3_client
                .get_object()
                .bucket(bucket)
                .key(&key)
                .send()
                .await;

            match response {
                Ok(resp) => {
                    info!("Successfully fetched email from S3");
                    let mut reader = resp.body.into_async_read();
                    let mut buffer = Vec::new();
                    reader.read_to_end(&mut buffer).await?;
                    let email = String::from_utf8(buffer)?;

                    match MimeMessage::parse(&email) {
                        Ok(mime_msg) => {
                            info!("Email parsed successfully");

                            let original_from: String =
                                mime_msg.headers.get_value("From".to_owned())?;

                            let mut builder = email::rfc5322::Rfc5322Builder::new();
                            builder.emit_folded(&Header::new("To".to_owned(), to_email.clone()).to_string()[..]);
                            builder.emit_raw("\r\n");
                            builder.emit_folded(&Header::new("From".to_owned(), from_email.clone()).to_string()[..]);
                            builder.emit_raw("\r\n");
                            builder.emit_folded(&Header::new("Reply-To".to_owned(), original_from).to_string()[..]);
                            builder.emit_raw("\r\n");
                            for header in mime_msg.headers.iter() {
                                if header.name.to_lowercase() != "To"
                                    && header.name.to_lowercase() != "from"
                                    && header.name.to_lowercase() != "to"
                                    && header.name.to_lowercase() != "reply-to"
                                    && header.name.to_lowercase() != "return-path"
                                    && header.name.to_lowercase() != "message-id"
                                    && header.name.to_lowercase() != "dkim-signature"
                                {
                                    let header_value = header.to_string();
                                    info!("{}", header_value);
                                    builder.emit_folded(&header_value[..]);
                                    builder.emit_raw("\r\n");
                                }
                            }
                            builder.emit_raw("\r\n");
                            builder.emit_raw(&mime_msg.as_string_without_headers());

                            let sanitized_msg = builder.result().clone();

                            info!("Email sanitized successfully");

                            Some(Blob::new(sanitized_msg.into_bytes()))
                        }
                        Err(e) => {
                            warn!("Failed to parse email: {:?}", e);
                            return Err(Box::new(e));
                        }
                    }
                }
                Err(e) => {
                    warn!("Failed to fetch email from S3: {:?}", e);
                    return Err(Box::new(e));
                }
            }
        }
        None => {
            warn!("Message ID is missing in the SES event");
            None
        }
    };

    // Forward email using SES
    if let Some(raw_email) = raw_email {
        info!("Forwarding email using SES");
        match clients
            .ses_client
            .send_email()
            .content(
                EmailContent::builder()
                    .raw(RawMessage::builder().data(raw_email.clone()).build()?)
                    .build(),
            )
            .destination(
                Destination::builder()
                    .to_addresses(to_email.clone())
                    .build(),
            )
            .from_email_address(from_email.clone())
            .send()
            .await
        {
            Ok(_) => info!("Email forwarded successfully"),
            Err(e) => {
                warn!("Failed to forward email: {:?}", e);
                return Err(Box::new(e));
            }
        }
        Ok(())
    } else {
        // Handle missing message_id
        Err("Missing messageId in SES event".into())
    }
}
