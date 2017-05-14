include:
  - rabbitmq

# restart the queue if rabbitmq service
# was cycled
restart-push-queue:
  supervisord.running:
    - name: civix_push_queue
    - restart: True
    - watch_in:
      - service: rabbitmq-server
