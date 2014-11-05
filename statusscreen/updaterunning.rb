#require 'date'
#require 'net/http'
#require 'time'
#require 'csv'

#starttime_str = DateTime.parse(starttime.to_s).strftime('%Y-%m-%d_%H:%M:%S')

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|

  # time - 1 hour
  #t = Time.now.utc - 900

  # yesterday at the same time period
  #last_start = Time.now.utc - 86400-3600
  #last_end = Time.now.utc - 86400

  total_cores = `./cores-today.sh`
  last_cores = `./cores-yesterday.sh`

  if total_cores > 0 and last_cores > 0
    send_event('CFMSrunning', { current:  total_cores, last: last_cores, last_period: 'last week'})
  end
end