#!/bin/bash
rm -f /vitasa/vitasa-web/tmp/pids/server.pid

# Wait for the database
echo -n "Waiting for database server $DB_HOST:$DB_PORT to accept connections"
./wait-for-it.sh $DB_HOST:$DB_PORT
echo "Database is up."

rails db:migrate

exec "$@"

