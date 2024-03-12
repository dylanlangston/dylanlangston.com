use lambda_runtime::{service_fn, LambdaEvent};
use rusoto_core::Region;
use rusoto_s3::{S3, S3Client};
use rusoto_ses::{Ses, SesClient, SendRawEmailRequest, RawMessage};
use std::env;
use tokio::io::AsyncReadExt;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let func = service_fn(my_handler);
    let _ = lambda_runtime::run(func).await;
    Ok(())
}

async fn my_handler(event: LambdaEvent<serde_json::Value>) -> Result<(), Box<dyn std::error::Error>> {
    // Extract S3 bucket and key from the event
    let s3_bucket = event.payload["Records"][0]["s3"]["bucket"]["name"]
        .as_str()
        .expect("S3 bucket name missing")
        .to_owned();
    let s3_key = event.payload["Records"][0]["s3"]["object"]["key"]
        .as_str()
        .expect("S3 object key missing")
        .to_owned();

    // Fetch the email content from S3
    let email_content = fetch_email_from_s3(&s3_bucket, &s3_key).await?;

    // Get sender and recipient email addresses from environment variables
    let from_address = env::var("FromEmail").expect("FromEmail environment variable not set");
    let to_address = env::var("ToEmail").expect("ToEmail environment variable not set");

    // Send the email using SES
    send_email(&email_content, &from_address, &to_address).await?;

    Ok(())
}

async fn fetch_email_from_s3(bucket: &str, key: &str) -> Result<String, Box<dyn std::error::Error>> {
    let s3_client = S3Client::new(Region::default());
    let get_object_request = rusoto_s3::GetObjectRequest {
        bucket: bucket.to_owned(),
        key: key.to_owned(),
        ..Default::default()
    };
    let result = s3_client.get_object(get_object_request).await?;
    let body = result.body.ok_or("S3 response missing body")?;
    let mut bytes = Vec::new();
    body.into_async_read().read_to_end(&mut bytes).await?;
    let email_content = String::from_utf8(bytes.into())?;
    Ok(email_content)
}

async fn send_email(email_content: &str, from_address: &str, to_address: &str) -> Result<(), Box<dyn std::error::Error>> {
    let ses_client = SesClient::new(Region::default());
    let raw_email = RawMessage {
        data: email_content.as_bytes().to_vec().into(),
    };
    let send_raw_email_request = SendRawEmailRequest {
        raw_message: raw_email,
        source: Some(from_address.to_owned()),
        destinations: Some(vec![to_address.to_owned()]),
        ..Default::default()
    };
    ses_client.send_raw_email(send_raw_email_request).await?;
    Ok(())
}
