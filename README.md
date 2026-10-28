# Deploy and Host Blazer on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/blazer?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=blazer)

[Blazer](https://github.com/ankane/blazer) is a business intelligence tool for people who know SQL: write a query, get a table, a line or bar chart, a map or a forecast, put queries on dashboards with a shared date-range picker, and turn any query into a check that emails or posts to Slack when it starts failing or spots an anomaly. It connects to Postgres, MySQL, ClickHouse, SQL Server, BigQuery, Snowflake and more. A lightweight Metabase or Redash alternative, and this template runs it on Railway behind a password.

## About Hosting Blazer

Two services:

- **Blazer**: the official `ankane/blazer` image, pinned to a release, on your Railway domain.
- **Postgres**: Blazer's own database for queries, dashboards, checks and the audit log. Private, with a generated password and its own volume.

What the template adds:

- **Password from the first second.** Basic auth with a generated password; only `/health` is open.
- **Databases are variables.** `BLAZER_DATABASE_URL` is the data source called "main"; each `BLAZER_DATABASE_URL_<NAME>` adds a data source called `<name>`. `clickhouse://user:pass@host:8123/db` URLs use Blazer's ClickHouse adapter. No config file to edit, no rebuild.
- **Checks that actually run.** Blazer's checks need a scheduler; here it runs inside the web server ("5 minutes", "1 hour" and "1 day" schedules, plus the daily failing-checks email), so there is no second service to pay for.
- **Forecasts and anomaly detection in the box.** Prophet forecasting and anomaly checks run locally, no data goes to an outside API.

## Common Use Cases

- SQL dashboards on your production database or a read replica
- Alerts when a metric drops, a queue backs up or a number looks wrong
- Sharing saved queries with a team instead of pasting SQL in chat

## Dependencies for Blazer Hosting

- Postgres 17 (included, private network only) for Blazer's own data
- The databases you want to query, reachable from Railway

### Deployment Dependencies

- [Blazer documentation](https://github.com/ankane/blazer#readme)
- [Template source on GitHub](https://github.com/two-workspaces/blazer)

### Implementation Details

**Sign in** at the Blazer service's domain with `BLAZER_USERNAME` and `BLAZER_PASSWORD` from its Variables tab.

**Add a database.** Set `BLAZER_DATABASE_URL` on the Blazer service to your database's URL, for example `${{Postgres-App.DATABASE_URL}}` for another Railway database in the same project. Use a read-only user: Blazer runs whatever SQL its users type. Until you set one, "main" is Blazer's own database, a place to try it out. More databases: `BLAZER_DATABASE_URL_ANALYTICS`, `BLAZER_DATABASE_URL_BILLING` and so on. `BLAZER_TIMEOUT` (seconds) caps every query.

**Variables in queries.** `{start_time}` and `{end_time}` in a query give it a date-range picker, any other `{name}` gives it a text box.

**Check emails.** Set `SMTP_URL` (`smtp://user:password@host:587`, or `smtps://` for port 465) and `BLAZER_FROM_EMAIL`. For Slack, set `BLAZER_SLACK_WEBHOOK_URL`.

**Time zone.** `BLAZER_TIME_ZONE` (default `Etc/UTC`), for example `Europe/Warsaw`.

**Memory.** About 0.15 GB for Blazer and 0.05 GB for Postgres at rest.

**Upgrades.** The template's repository pins the Blazer release in its Dockerfile; a new release there reaches your service on its next redeploy, and migrations run on start.

## Why Deploy Blazer on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Blazer on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
