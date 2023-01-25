#!/bin/bash
for i in {1..10}
do
  randomNumber=$(($RANDOM % 10))
  timestamp=$(date +%s)
  curl -X POST https://us-central1-task-cf-370710.cloudfunctions.net/task-cf-function -H "Content-Type: application/json" \
  -d "{\"raw\":\"message-$i\", \"timestamp\":\"$timestamp\"}"
done

# https://us-central1-task-cf-370710.cloudfunctions.net/task-cf-function