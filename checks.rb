# Runs Blazer checks on their schedules in a thread of the web server, so they cost
# no second copy of Rails. Daily: the "1 day" checks and the failing-checks digest.
# Started from config/initializers/railway.rb in the server process only.
ticks = 0
loop do
  sleep 300
  ticks += 1
  [["5 minutes", 1], ["1 hour", 12], ["1 day", 288]].each do |schedule, every|
    next unless ticks % every == 0
    begin
      # The executor checks database connections out and back in for this thread.
      Rails.application.executor.wrap do
        Blazer.run_checks(schedule: schedule)
        Blazer.send_failing_checks if schedule == "1 day"
      end
    rescue => e
      puts "railway: #{schedule} checks failed: #{e.class}: #{e.message}"
    end
  end
end
