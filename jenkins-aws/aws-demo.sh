#!/bin/bash
echo "Build started at $(date)"
echo "Access key: $AWS_ACCESS_KEY_ID"
echo "Secret key: $AWS_SECRET_ACCESS_KEY"
echo "Secret key length: ${#AWS_SECRET_ACCESS_KEY}"
if command -v aws >/dev/null 2>&1; then
  aws sts get-caller-identity
else
  echo "AWS CLI not installed, skipping identity check"
fi
