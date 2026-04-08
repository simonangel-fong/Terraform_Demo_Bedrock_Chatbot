```sh
terraform -chdir=infra init --backend-config=state.config -reconfigure
terraform -chdir=infra fmt && terraform -chdir=infra validate
terraform -chdir=infra apply -auto-approve
```

```sh
python -m venv .venv
python.exe -m pip install --upgrade pip

pip install boto3

```

## ToDo

- [x] lambda
- [x] bedrock
- [x] api
- [x] web
- [ ] cognito

```json
{
  "prompt": "Is this country in Asia?",
  "history": [
    {
      "role": "user",
      "content": "what is the capital of Japan?",
      "timestamp": 1712345678901
    },
    {
      "role": "assistant",
      "content": "The capital of Japan is Tokyo.",
      "timestamp": 1712345679900
    }
  ]
}
```

```json
{
  "prompt": "Make sure the songs are by artists from the United Kingdom.",
  "history": [
    {
      "role": "user",
      "content": [
        {
          "text": "Create a list of 3 pop songs."
        }
      ]
    },
    {
      "role": "assistant",
      "content": [
        {
          "text": "Here is a list of 3 pop songs by artists from the United Kingdom:\n\n1. \"As It Was\" by Harry Styles\n2. \"Easy On Me\" by Adele\n3. \"Unholy\" by Sam Smith and Kim Petras"
        }
      ]
    }
  ]
}
```
