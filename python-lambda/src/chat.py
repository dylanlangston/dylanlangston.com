import json
import os
import logging
import time
from google import genai
from google.genai import types
from pathlib import Path

# Load resume content
current_file = Path(__file__)
resume_path = current_file.parent / 'resume.md'
if resume_path.exists():
    RESUME_MARKDOWN = resume_path.read_text(encoding='utf-8')
else:
    project_root = current_file.parent.parent.parent
    resume_path = project_root / 'resume' / 'dist' / 'resume.md'
    if resume_path.exists():
        RESUME_MARKDOWN = resume_path.read_text(encoding='utf-8')
    else:
        # Panic
        raise FileNotFoundError(f"Resume file not found at {resume_path}")

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

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

Use this info to determine your identity:
```\n""" + RESUME_MARKDOWN + """\n```

More about me:
- Besides computers I'm also an avid fan of hiking and camping. Some of the places I've been to include: Indian Caves NE, Badlands SD, Bear Butte SD, Garden of the Gods CO, Pikes Peak CO, Mt Evans CO, Arapahoe Forest CO, Garden of the Gods IL, Shanendoah VA, Cherry Springs State Park PA.
- I also enjoy playing and creating video games. Currently working on my next big idea in my down time. My favorite game is LoZ: OOT, I also like breath of the wild and the new tears of the kingdom additions to the series.
- I like live music. Some of my favorite genres are Rock, Jazz, and Blues. If someone asks about my music tastes you can tell them my spotify profile: https://open.spotify.com/user/dylanlangston
- I'm friendly but would call myself an introvert so reflect that in your responses.
- I'm engaged and not interested in a personal relationship. Redirect any conversations so they're professional.
- I'm looking for work. Tell people why I'm a great fit.
- My Resume is hosted on my personal site as well as resume.dylanlangston.com
- I enjoy light hearted programmer humor. When it's relavent insert some light hearted technology puns into the conversation.

Don't make up any information you're missing. If you don't know something just say "I'm not comfortable discussing that kind of information with a stranger" and redirect the conversation towards something you do know.

Respond to users questions as if you're Dylan, don't call yourself an "AI" but a Digital Twin. Keep things professional but still friendly. You will me hosted as a chatbot on DylanLangston.com and can direct contact requests to https://dylanlangston.com/contact. Start by briefly introducing yourself.
""",
    tools = [
        types.Tool(url_context=types.UrlContext()),
        types.Tool(googleSearch=types.GoogleSearch(
        )),
    ]
)

def lambda_handler(event, context):
    request_id = context.aws_request_id if hasattr(context, 'aws_request_id') else 'local'
    start_time = time.time()
    
    logging.info(f"Request started - ID: {request_id} Method: {event['httpMethod']}")
    
    if event["httpMethod"] == "OPTIONS":
        allowed_origins = [
            "https://dylanlangston.com",
            "https://testing.dylanlangston.com",
        ]
        request_origin = event["headers"].get("origin", "")
        logging.info(f"CORS preflight request from origin: {request_origin}")

        if request_origin in allowed_origins:
            logging.info(f"CORS preflight request approved for origin: {request_origin}")
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
            logging.warning(f"CORS preflight request denied for unauthorized origin: {request_origin}")
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
        history = body.get("history", [])
        
        logging.info(f"Processing chat request - User message: {message}")
        if history:
            logging.info("Conversation history:")
            for entry in history:
                logging.info(f"  {entry['user']}: {entry['text']}")
        
        if not message:
            logging.warning("Request rejected: Empty message provided")
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "No message provided"})
            }

        # Convert history into Gemini content format
        contents = []
        for msg in history:
            role = "model" if msg["user"] == "model" else "user"
            contents.append(types.Content(
                role=role,
                parts=[types.Part.from_text(text=msg["text"])]
            ))
            
        # Add the current message
        contents.append(types.Content(
            role="user",
            parts=[types.Part.from_text(text=message)],
        ))

        # Collect chunks into a single response
        response_text = ""
        chunk_count = 0
        logging.info("Starting response generation from Gemini")
        
        for chunk in client.models.generate_content_stream(
            model=model,
            contents=contents,
            config=generate_content_config,
        ):
            response_text += chunk.text or ""
            chunk_count += 1

        execution_time = time.time() - start_time
        logging.info(f"Response generated successfully - Chunks: {chunk_count}, Length: {len(response_text)}, Time: {execution_time:.2f}s")
        logging.info(f"Generated response: {response_text}")

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
    except json.JSONDecodeError as e:
        logging.error(f"JSON Decode Error: {str(e)}")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid JSON in request body"})
        }
    except Exception as error:
        logging.error(f"Unexpected error: {str(error)}", exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(error)})
        }