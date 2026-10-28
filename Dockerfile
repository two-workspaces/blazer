# Blazer, configured from Railway variables: data sources, basic auth, checks with
# email or Slack alerts, and migrations on boot.
# upgrade: dockerhub ankane/blazer
FROM ankane/blazer:v3.5.2
COPY blazer.yml /app/config/blazer.yml
COPY config/initializers/ /app/config/initializers/
COPY checks.rb seeds/ /app/railway/
COPY railway-entrypoint.sh /railway-entrypoint.sh
# One Puma process with 16 threads: queries wait on the database, not on Ruby.
ENV RAILS_ENV=production PUMA_WORKERS=0 MAX_THREADS=16
CMD ["/railway-entrypoint.sh"]
