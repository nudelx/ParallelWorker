#!/usr/bin/env ruby
require './ParallelWorker'

PW = ParallelWorker.new()
PW.setCallback(callback: lambda { |item , ext_obj|
    File.open("#{Process.pid}.txt", "w") { |file|
        file.write("Hello from child process #{Process.pid}\nwait time: #{sleep 5*item}(s)\nbye bye ...")
    }
})
PW.setData(data: (1..10).to_a)
PW.run()