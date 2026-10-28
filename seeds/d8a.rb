# Website analytics on the events d8a writes to ClickHouse (data source "d8a", from
# BLAZER_DATABASE_URL_D8A): one dashboard with the date-range picker, plus the same
# queries to copy from. Run once by the entrypoint while Blazer has no queries.
range = "timestamp_utc >= {start_time} AND timestamp_utc < {end_time}"
queries = [
  ["Visitors, sessions and pageviews by day", <<~SQL],
    SELECT date_utc AS day, uniq(client_id) AS visitors, uniq(session_id) AS sessions,
      countIf(name = 'page_view') AS pageviews
    FROM events WHERE #{range}
    GROUP BY day ORDER BY day
  SQL
  ["Top pages", <<~SQL],
    SELECT page_path AS page, countIf(name = 'page_view') AS pageviews, uniq(client_id) AS visitors
    FROM events WHERE #{range} AND name = 'page_view'
    GROUP BY page ORDER BY pageviews DESC LIMIT 25
  SQL
  ["Sources", <<~SQL],
    SELECT concat(if(session_source = '', '(direct)', session_source), ' / ',
      if(session_medium = '', '(none)', session_medium)) AS source_medium,
      uniq(session_id) AS sessions, uniq(client_id) AS visitors
    FROM events WHERE #{range}
    GROUP BY source_medium ORDER BY sessions DESC LIMIT 25
  SQL
  ["Landing pages", <<~SQL],
    SELECT session_entry_page_location AS landing_page, uniq(session_id) AS sessions,
      round(avg(session_duration)) AS avg_session_seconds
    FROM events WHERE #{range} AND session_is_entry_page
    GROUP BY landing_page ORDER BY sessions DESC LIMIT 25
  SQL
  ["Countries", <<~SQL],
    SELECT if(session_geo_country = '', '(unknown)', session_geo_country) AS country,
      uniq(session_id) AS sessions, uniq(client_id) AS visitors
    FROM events WHERE #{range}
    GROUP BY country ORDER BY sessions DESC LIMIT 25
  SQL
  ["Devices and browsers", <<~SQL],
    SELECT session_device_category AS device, device_web_browser AS browser,
      uniq(session_id) AS sessions
    FROM events WHERE #{range}
    GROUP BY device, browser ORDER BY sessions DESC LIMIT 25
  SQL
]

dashboard = Blazer::Dashboard.create!(name: "Website analytics")
queries.each_with_index do |(name, sql), i|
  query = Blazer::Query.create!(name: name, statement: sql, data_source: "d8a", status: "active")
  Blazer::DashboardQuery.create!(dashboard: dashboard, query: query, position: i)
end
puts "railway: added the Website analytics dashboard (#{queries.size} queries on d8a)"
