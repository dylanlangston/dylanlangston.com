use aws_config::meta::region::RegionProviderChain;
use aws_config::BehaviorVersion;
use aws_sdk_s3::{primitives::Blob, Client as S3Client};
use aws_sdk_sesv2::types::{Destination, EmailContent, RawMessage};
use aws_sdk_sesv2::Client as SesClient;
use email::MimeMessage;
use lambda_runtime::{service_fn, LambdaEvent};
use serde_json::Value;
use tokio::io::AsyncReadExt;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let func = service_fn(my_handler);
    let _ = lambda_runtime::run(func).await;
    Ok(())
}

async fn my_handler(event: LambdaEvent<Value>) -> Result<(), Box<dyn std::error::Error>> {
    // Initialize SES and S3 clients
    let region_provider = RegionProviderChain::default_provider().or_else("us-east-1");
    let config = aws_config::defaults(BehaviorVersion::latest())
        .region(region_provider)
        .load()
        .await;
    let ses_client = SesClient::new(&config);
    let s3_client = S3Client::new(&config);

    // Get email details from SES event
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

    // Get environment variables
    let to_email = std::env::var("ToEmail").unwrap();
    let from_email = std::env::var("FromEmail").unwrap();

    // Fetch raw email from S3
    let raw_email = match message_id {
        Some(message_id) => {
            let bucket = std::env::var("AwsS3BucketName").unwrap();
            let key = format!(
                "{}/{}",
                std::env::var("AwsS3BucketName").unwrap(),
                message_id
            );
            let response = s3_client
                .get_object()
                .bucket(bucket)
                .key(key)
                .send()
                .await?;
            let mut reader = response.body.into_async_read();
            let mut buffer = Vec::new();
            reader.read_to_end(&mut buffer).await?;

            let email = String::from_utf8(buffer)?;
            let mime_msg = MimeMessage::parse(&email)?;

            Some(Blob::new(mime_msg.as_string_without_headers().into_bytes()))
        }
        None => None,
    };

    // Forward email using SES
    if let Some(raw_email) = raw_email {
        ses_client
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

        Ok(())
    } else {
        // Handle missing message_id
        Err("Missing messageId in SES event".into())
    }
}
