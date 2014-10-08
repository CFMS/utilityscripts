def GetCores(cluster = nil, starttime = nil, endtime = nil)
  require 'date'
  require 'net/http'
  require 'time'
  require 'csv'

  starttime_str = DateTime.parse(starttime.to_s).strftime('%Y-%m-%d%%20%H:%M:%S')

  
	if endtime == nil
    total_cores = `./cores.sh`



  #  url_raw = 'http://hcc-gratia.unl.edu:8100/gratia/csv/status_vo?facility=%{cluster}&starttime=%{starttime}' % { :cluster => cluster, :starttime => starttime_str }
  #else
  #  endtime_str = DateTime.parse(endtime.to_s).strftime('%Y-%m-%d%%20%H:%M:%S')
  #  url_raw = 'http://hcc-gratia.unl.edu:8100/gratia/csv/status_vo?facility=%{cluster}&starttime=%{starttime}&endtime=%{endtime}' % { :cluster => cluster, :starttime => starttime_str, :endtime => endtime_str }
  #end

  #uri = URI(url_raw)
  #response = Net::HTTP.get_response(uri)

  #File.open("/tmp/csv.file", 'w') { |f| f.write(url) }
  #File.open("/tmp/csv.file", 'a') { |f| f.write(response.body) }

  #total_cores = 0.0
  #CSV.parse(response.body, { :headers => :first_row} ) do |row|
  #   total_cores += row[2].to_f
  #end

  return total_cores

end


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '15m', :first_in => 0 do |job|

  # time - 1 hour
  t = Time.now.utc - 3600

  # yesterday at the same time period
  last_start = Time.now.utc - 86400-3600
  last_end = Time.now.utc - 86400

  total_cores = GetCores('', t)
  last_cores = GetCores('', last_start, last_end)
  if total_cores > 0 and last_cores > 0
    send_event('CFMSrunning', { current:  total_cores, last: last_cores, last_period: 'yesterday'})
  end
end



#sge-cores-compa= qstat -u "*" -s r -q all.q,rr.batch.q,fluent.q,rr.interactive.q | awk '$4 !="hyao" {print $9}' + qstat -u "*" -s r -q all.q,rr.batch.q,fluent.q,rr.interactive.q | awk '$4 =="hyao" {print $9*2}'
#sge-cores-compb= qstat -u "*" -s r -q highmem.q | awk '{print $9}'
#sge-cores-compc= qstat -u "*" -s r -q highmem.q | awk '{print $9}'
#
#SLURMCORE=($(ssh login02 squeue -S -D --format=%C))