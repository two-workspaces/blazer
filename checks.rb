# Runs Blazer checks on their schedules in one long-lived process, so each run
# doesn't boot Rails again. Daily: the "1 day" checks and the failing-checks digest.
STDOUT.sync = true
ticks = 0
loop do
  sleep 300
  ticks += 1
  [["5 minutes", 1], ["1 hour", 12], ["1 day", 288]].each do |schedule, every|
    next unless ticks % every == 0
    begin
      Blazer.run_checks(schedule: schedule)
      Blazer.send_failing_checks if schedule == "1 day"
    rescue => e
      puts "railway: #{schedule} checks failed: #{e.class}: #{e.message}"
    end
  end
  ActiveRecord::Base.connection_handler.clear_active_connections!
end
