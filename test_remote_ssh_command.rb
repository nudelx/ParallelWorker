#!/usr/bin/env ruby
require './ParallelWorker'

PW = ParallelWorker.new()
PW.max_proc = 10
PW.set_callback(callback: lambda { |ip_address , ext_obj|
  puts "ssh command to  root@#{ip_address}"
  out  = ` ssh root@#{ip_address} netstat -an | grep -i listen`
  puts out
})
PW.set_data(data: 255.times.map{|i| "192.168.0.#{i}"})
PW.run()