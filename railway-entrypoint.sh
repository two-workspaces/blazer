#!/bin/sh
set -e
cd /app
: "${DATABASE_URL:?DATABASE_URL is not set}"
[ -n "$BLAZER_PASSWORD" ] || echo "railway: BLAZER_PASSWORD is not set, Blazer is open to anyone with the URL"

# On a fresh deploy Postgres may still be starting.
for i in $(seq 30); do rails db:migrate 2>&1 && break; echo "railway: waiting for Postgres"; sleep 3; done
# A seed adds ready-made queries and dashboards once, while Blazer has no queries.
if [ -n "$BLAZER_SEED" ] && [ -f "railway/$BLAZER_SEED.rb" ]; then
  rails runner "exit 1 if Blazer::Query.exists?" 2>/dev/null && rails runner "railway/$BLAZER_SEED.rb"
fi

# [::] takes IPv4 too. RAILWAY_CHECKS starts the check scheduler inside the server.
BIND="tcp://[::]:${PORT:-8080}" RAILWAY_CHECKS=1 exec puma -C config/puma.rb
