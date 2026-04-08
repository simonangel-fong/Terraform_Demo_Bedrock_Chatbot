import boto3
import json

# model id
MODEL_ID = "us.amazon.nova-2-lite-v1:0"

# bedrock client
client = boto3.client(
    "bedrock-runtime",
    region_name="us-east-1"
)


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")

        prompt = body.get("prompt", "").strip()

        request_body = {
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {"text": prompt}
                    ]
                }
            ]
        }

        response = client.invoke_model(
            modelId=MODEL_ID,
            body=json.dumps(request_body),
            contentType="application/json",
            accept="application/json",
            trace="ENABLED",
            performanceConfigLatency="standard"
        )

        response_body = json.loads(response["body"].read())
        completion = response_body["output"]["message"]["content"][0]["text"]

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "reply": completion
            })
        }

    except Exception as e:
        print("Lambda error:", str(e))
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "error": str(e)
            })
        }
