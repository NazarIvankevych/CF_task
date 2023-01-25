#!/bin/bash
for i in {1..10}
do
  randomNumber=$(($RANDOM % 50))
  timestamp=$(date +%s)
  curl -X POST https://us-central1-task-cf-370710.cloudfunctions.net/task-cf-function -H "Content-Type: application/json" \
  -d "{\"message\":\"message-$i\", \"number\":\"$randomNumber\", \"age\":\"$randomNumber\", \"timestamp\":\"$timestamp\"}"
done

for i in {1..3}
do
    curl -X POST https://us-central1-task-cf-370710.cloudfunctions.net/task-cf-function -H "Content-Type: application/json" \
  -d "{\"msg\":\"message-$i\", \"timestamp\":\"timestamp\"}"
done

# https://us-central1-task-cf-370710.cloudfunctions.net/task-cf-function