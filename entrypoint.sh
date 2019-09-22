#!/bin/bash
rails db:migrate
rm -f /vitasa/vitasa-web/tmp/pids/server.pid
exec "$@"

