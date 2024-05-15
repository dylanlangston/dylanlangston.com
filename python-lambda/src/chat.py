import json


def lambda_handler(event, context):
    if event["httpMethod"] == "OPTIONS":
        allowed_origins = [
            "http://dylanlangston.com",
            "http://testing.dylanlangston.com",
        ]
        request_origin = event["headers"].get("Origin", "")

        if request_origin in allowed_origins:
            return {
                "statusCode": 200,
                "body": "",
                "headers": {
                    "Access-Control-Allow-Origin": request_origin,
                    "Access-Control-Allow-Methods": "POST,OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type",
                },
            }
        else:
            return {
                "statusCode": 403,
                "body": json.dumps({"Error": "Forbidden"}),
                "headers": {"Content-Type": "application/json"},
            }

    if event["httpMethod"] != "POST":
        return {
            "statusCode": 405,
            "body": json.dumps({"Error": "Method Not Allowed"}),
            "headers": {"Content-Type": "application/json"},
        }

    try:
        body = json.loads(event["body"])
    except json.decoder.JSONDecodeError:
        return {
            "statusCode": 400,
            "body": json.dumps({"Error": "Invalid JSON"}),
            "headers": {"Content-Type": "application/json"},
        }

    if "Message" not in body:
        return {
            "statusCode": 400,
            "body": json.dumps({"Error": "Message key not found in JSON"}),
            "headers": {"Content-Type": "application/json"},
        }

    message = body["Message"]

    response = {"Message": message}

    return {
        "statusCode": 200,
        "body": json.dumps(response),
        "headers": {"Content-Type": "application/json"},
    }
