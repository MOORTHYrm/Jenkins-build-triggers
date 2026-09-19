#!/usr/bin/env bash
# Execute shell build step for the Freestyle job: demo-build-job
echo "Building artifact..."
mkdir -p output
echo "build-$(date +%s)" > output/artifact.txt

