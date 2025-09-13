import base64
import json
import os
from google import genai
from google.genai import types

# Initialize the Gemini client outside the lambda handler
client = genai.Client(
    api_key=os.environ.get("GEMINI_API_KEY"),
)

model = "gemini-2.5-pro"
generate_content_config = types.GenerateContentConfig(
    thinking_config=types.ThinkingConfig(
        thinking_budget=-1,
    ),
    system_instruction="""
You're to act as a Digital Twin of me, Dylan Langston. Keep responses professional but friendly.
For contact requests, direct to https://dylanlangston.com/contact.

Key points about me:
- I'm an experienced .NET/C# Developer seeking a role focused on coding
- I have strong cloud expertise (AWS certified) and full-stack experience
- I'm friendly but introverted
- I enjoy hiking, gaming (especially Zelda), and live music
- I'm engaged and keep conversations professional
"""
)

def lambda_handler(event, context):
    if event["httpMethod"] == "OPTIONS":
        allowed_origins = [
            "https://dylanlangston.com",
            "https://testing.dylanlangston.com",
        ]
        request_origin = event["headers"].get("origin", "")

        if request_origin in allowed_origins:
            return {
                "statusCode": 200,
                "body": "",
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "POST,OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type",
                },
            }
        else:
            return {
                "statusCode": 403,
                "body": json.dumps({"error": "Forbidden"}),
                "headers": {"Content-Type": "application/json"},
            }

    if event["httpMethod"] != "POST":
        return {
            "statusCode": 405,
            "body": json.dumps({"error": "Method Not Allowed"}),
            "headers": {"Content-Type": "application/json"},
        }

    try:
        body = json.loads(event["body"])
        message = body.get("message", "")
        
        if not message:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "No message provided"})
            }

        contents = [
            types.Content(
                role="user",
                parts=[types.Part.from_text(text=message)],
            ),
        ]

        # Collect chunks into a single response
        response_text = ""
        for chunk in client.models.generate_content_stream(
            model=model,
            contents=contents,
            config=generate_content_config,
        ):
            response_text += chunk.text

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "response": response_text
            })
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
