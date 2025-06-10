#!/bin/bash

# Accept the template ID as the first argument passed to the script
TEMPLATE_ID="$1"

# Add a check to ensure the ID was provided
if [ -z "$TEMPLATE_ID" ]; then
  echo "Error: Experiment template ID was not provided as an argument."
  exit 1
fi

echo "Starting experiment from template $TEMPLATE_ID"
EXPERIMENT_ID=$(aws fis start-experiment \
      --experiment-template-id "$TEMPLATE_ID" \
      --query 'experiment.id' --output text)

# Check if the experiment started successfully
if [ -z "$EXPERIMENT_ID" ]; then
  echo "Error: Failed to start FIS experiment."
  exit 1
fi

echo "Experiment started: $EXPERIMENT_ID"
echo "Waiting 60 seconds for experiment to run..."
sleep 60

echo "Fetching results..."
aws fis get-experiment --id "$EXPERIMENT_ID" --output json  > results.txt
echo "Results saved to results.txt"
