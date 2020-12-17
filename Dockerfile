FROM docker:stable

COPY entrypoint.sh /entrypoint.sh
COPY secondary_database.sh /initdb.d/secondary_database.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
