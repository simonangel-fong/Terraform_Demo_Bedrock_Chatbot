import boto3
import json

# model id
MODEL_ID = "us.amazon.nova-2-lite-v1:0"

# bedrock client
client = boto3.client(
    "bedrock-runtime",
    region_name="us-east-1"
)

system_list = [
    {
        "text": "You are a Bedrock AI asis."
    }
]

inf_params = {"maxTokens": 500, "topP": 0.9, "topK": 20, "temperature": 0.7}


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")
        prompt = body.get("prompt", "").strip()

        message_list = [{"role": "user", "content": [{"text": prompt}]}]

        request_body = {
            "schemaVersion": "messages-v1",
            "messages": message_list,
            "system": system_list,
            "inferenceConfig": inf_params,
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
