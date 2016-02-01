#!/usr/bin/env ruby

require './ParallelWorker'

 PW = ParallelWorker.new()
 PW.debug_mode = true
 PW.setCallback(callback:lambda {|item,ext_obj| sleep 5*item ; puts "Done ,,, I am dead my Pid is #{Process.pid}"})
 PW.setData(data: (1..10).to_a)
 PW.run()

