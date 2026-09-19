#!/usr/bin/env bash
# Execute shell build step for the Freestyle job: demo-consumer-job
# Run this AFTER the "Copy artifacts from another project" build step
echo "Using dependency:"
cat dependencies/output/artifact.txt

