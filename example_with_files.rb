#!/usr/bin/env ruby
require './ParallelWorker'

PW = ParallelWorker.new()
PW.set_ext_obj(ext_obj: {
      'function_a' =>  lambda{ puts "hello I am extra function"},
      'array' => [0,1,2,3,4,5,6,7],
      'hash' => {  'A' => 1, 'B' => 1, 'C' => 1,  },
      'value' => 'some value'
    }
  )
PW.set_callback(callback: lambda { |item , ext_obj|
    File.open("#{Process.pid}.txt", "w") { |file|
        file.write("Hello from child process #{Process.pid}\nwait time: #{sleep 5*item}(s)\n #{pp ext_obj} bye bye ...")
    }
})
PW.set_data(data: (1..10).to_a)
PW.run()