FROM docker:stable

COPY entrypoint.sh /entrypoint.sh
COPY secondary_database.sh /secondary_database.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
