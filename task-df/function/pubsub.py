import json
import time
from datetime import datetime
import random
from google.auth import jwt
from google.cloud import pubsub_v1
import datetime

# --- Base variables and auth path
PROJECT_ID = "task-cf-370710"
TOPIC_ID = "df-pub_sub-topic"
MAX_MESSAGES = 5
MAX_ERRORS = 2


# --- PubSub Utils Classes
class PubSubPublisher:
    def __init__(self, project_id, topic_id):
        self.project_id = project_id
        self.topic_id = topic_id
        self.publisher = pubsub_v1.PublisherClient(transport=None)
        self.topic_path = self.publisher.topic_path(self.project_id, self.topic_id)

    def publish(self, data: str):
        result = self.publisher.publish(self.topic_path, data.encode("utf-8"))
        return result


# --- Main publishing script
def main():
    i = 0
    publisher = PubSubPublisher(PROJECT_ID, TOPIC_ID)

    err_idx = set()

    while len(err_idx) < MAX_ERRORS:
        err_idx.add(random.randint(0, MAX_MESSAGES-1))

    while i < MAX_MESSAGES:
        now = datetime.datetime.utcnow()
        if i in err_idx:
            data = {
                "msg": f"message-{i}",
                "number": "not an int",
                "age": random.random()
            }
        else:
            data = {
                "message": f"message-{i}",
                "number": random.randint(0, 10),
                "age": random.random(),
                "timestamp": now.strftime('%Y-%m-%d %H:%M:%S')
            }
        publisher.publish(json.dumps(data))
        time.sleep(1)
        i += 1


if __name__ == "__main__":
    main()