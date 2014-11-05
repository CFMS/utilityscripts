require 'httparty'
require 'addressable/uri'

# bytes_in url
uri_bytesin = Addressable::URI.escape "http://172.20.5.20/ganglia/graph.php?r=hour&title=&vl=&x=&n=&hreg[]=compute&mreg[]=bytes_in&gtype=stack&glegend=hide&json=1"

# bytes_out url
uri_bytesout = Addressable::URI.escape "http://172.20.5.20/ganglia/graph.php?r=hour&title=&vl=&x=&n=&hreg[]=compute&mreg[]=bytes_out&gtype=stack&glegend=hide&json=1"

SCHEDULER.every '15s', :first_in => 0 do |job|
  #bytes in
  mbitotal = 0.0
  response = HTTParty.get(uri_bytesin)
  response.each do |host| 
    data = host["datapoints"][-3][1]
        if data == "NaN"
         data = 0
    	end
   	mbitotal += data
  	end
  mbitotal = mbitotal / 1024 / 1024
  mbitotal = mbitotal.round(2)
  send_event('ganglia_bytesin', { value: mbitotal })

  #bytes out
  mbototal = 0.0
  response = HTTParty.get(uri_bytesout)
  response.each do |host|
    data = host["datapoints"][-3][1]
        if data == "NaN"
         data = 0
    	end
   	mbototal += data
  	end
  mbototal = mbototal / 1024 / 1024
  mbototal = mbototal.round(2)
  send_event('ganglia_bytesout', { value: mbototal })

  # throughput, bytes total
  mbps = mbitotal + mbototal
  mbps = mbps.round(2)
  send_event('ganglia_throughput', { value: mbps})
end









