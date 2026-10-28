# Check emails over SMTP_URL (smtp://user:password@host:587, or smtps:// for
# implicit TLS on 465), with links that point at this service's public address.
if ENV["SMTP_URL"].to_s != ""
  uri = URI.parse(ENV["SMTP_URL"])
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: uri.host,
    port: uri.port || (uri.scheme == "smtps" ? 465 : 587),
    user_name: uri.user && URI.decode_www_form_component(uri.user),
    password: uri.password && URI.decode_www_form_component(uri.password),
    authentication: uri.user ? :plain : nil,
    tls: uri.scheme == "smtps",
    enable_starttls_auto: uri.scheme != "smtps"
  }
end
host = ENV["BLAZER_HOST"].to_s.empty? ? ENV["RAILWAY_PUBLIC_DOMAIN"] : ENV["BLAZER_HOST"]
ActionMailer::Base.default_url_options = {host: host, protocol: "https"} if host.to_s != ""

# The check scheduler, in the web server only (not in `rails runner` or migrations).
if ENV["RAILWAY_CHECKS"] == "1"
  Rails.application.config.after_initialize do
    Thread.new { load "/app/railway/checks.rb" }
  end
end
