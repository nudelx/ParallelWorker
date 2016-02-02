#!/usr/bin/env ruby
require './ParallelWorker'

PW = ParallelWorker.new()
PW.max_proc = 10

PW.set_callback(callback: lambda { |ip_address , ext_obj|

  out  = `sudo nmap -O -A --script snmp-interfaces #{ip_address} -oN ./data-files/#{ip_address}.txt`

})
PW.set_data(data: 255.times.map{|i| "192.168.1.#{i}"})
PW.run()