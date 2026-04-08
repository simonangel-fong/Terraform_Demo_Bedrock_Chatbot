```sh
terraform -chdir=infra init --backend-config=state.config -reconfigure
terraform -chdir=infra init --backend-config=state.config -migrate-state
terraform -chdir=infra fmt && terraform -chdir=infra validate
terraform -chdir=infra apply -auto-approve
```

```sh
python -m venv .venv
python.exe -m pip install --upgrade pip

pip install boto3

```

```txt
who are you?

what is the sum of 1 + 1?

What is AWS Lambda in one sentence?
```