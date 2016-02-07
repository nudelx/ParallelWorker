#!/usr/bin/env ruby
require './ParallelWorker'

PW = ParallelWorker.new()
PW.max_proc = 10

PW.set_callback(callback: lambda { |ip_address , ext_obj|

  out  = system("ping -c 1 -o -t 1 #{ip_address} > /dev/null ")
  if out
    puts "Host #{ip_address} is alave\n"
  else
    puts "Host #{ip_address} is dead\n"
  end
})
PW.set_data(data: 255.times.map{|i| "192.168.1.#{i}"})
PW.run()