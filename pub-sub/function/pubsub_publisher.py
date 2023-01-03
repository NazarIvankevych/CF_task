import logging
from google.cloud.pubsub_v1 import PublisherClient

logger = logging.getLogger(__name__)


class PubSubPublisher:
    def __init__(self, publisher: PublisherClient,
                 project_id: str,
                 topic_id: str, ):
        self._publisher = publisher
        self._topic_path = publisher.topic_path(project_id, topic_id)

    def publish(self, data: bytes) -> bool:
        try:
            future = self._publisher.publish(self._topic_path,
                                             data)
            try:
                future.result()
                logging.info("Successfully published to topic")
                return True
            except RuntimeError as err:
                logging.error("An error occurred during "  # pylint: disable=E1205
                              "publishing the message",
                              str(err))
                return False
        except Exception as err:  # pylint: disable=broad-except
            logging.error(f"Unexpected error: {str(err)}")  # pylint: disable=E1205
            return False


def main():
    PubSubPublisher().publish()