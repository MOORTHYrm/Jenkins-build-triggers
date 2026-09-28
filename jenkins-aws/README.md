# Jenkins AWS Credentials Demo

## What it is
An "AWS Credentials" entry stores an IAM access key ID and secret key in
Jenkins. A job binds them to `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` at build time, so keys never appear in scripts
or the repo.

## Files
- `aws-demo.sh`: prints the bound values (secret is masked) and runs
  `aws sts get-caller-identity` if the AWS CLI is installed.

## Expected console output
    Access key: AKIA...
    Secret key: ****
    Secret key length: 40
    (identity JSON if AWS CLI is installed and keys are real)

## Notes
- Use a dedicated IAM user with minimal permissions (for example
  read-only), never root or admin keys.
- Never commit keys or paste them into chat or tickets. Rotate any key
  that is exposed.
- Prefer IAM roles or OIDC for production. Keys are for demos.
