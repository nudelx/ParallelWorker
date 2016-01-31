#!/usr/bin/env ruby

pid = fork do 
  puts "I am child"
  sleep 3 
  puts "child done"
  exit

end
 
puts "I am  father  and I am waiting for the child "
Process.wait(pid)
puts "Father done " 



