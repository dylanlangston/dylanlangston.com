use lambda_runtime::{service_fn, LambdaEvent};
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

    Ok(())
}