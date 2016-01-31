class ParallelWorker
  
  require 'pp'
  attr_accessor :data
  attr_accessor :callback

  def initialize
  
    @counter = 0
    @debug_mode = true  
    @max_proc = 500
    @watch_dog = nil
    @proc_queue = {}

    @use_log  = false
    @log_path = '/tmp/'
    @log_name = 'ParallelWorker.log'

    @callback = nil
    @data     = nil
    @ex_obj   = nil
    @proc_out = 'pid.out'
    @keep_proc_out = false
  end
 
  def debugPrint(str)
    if @debug_mode
      puts "#{Time.new.inspect}: #{str}"
    end
  end

  def dumpData(data: [])
    puts "========"   
    pp data
    puts "========"   
  end

  def setData(data: [])
    if data.class == Array
      @data = data
    else
      raise "data is not array"
    end
  end
  
  def setCallback(callback: lambda{})
    if callback.class == Proc
      @callback = callback
    else
      raise "callback is not a function"
    end
  end

  def is_processAlive?
    @proc_queue.each do |pid|
      is_running = Process::kill 0, pid
      unless is_running
        debugPrint "Process => #{pid} is not running"
        deleteProcess pid
      end
    end
  end

  def deleteProcess(pid: 0)
      if pid
          debugPrint("Trying to delete process pid[#{pid}]")
          @proc_queue.delete(pid)
      end
  end
  
  def createProcess(item: 0)

    debugPrint("starting new process")
    pid = fork

    if pid # Darth Vader 
        debugPrint("Hi I am your father ")
        @counter+=1
        @proc_queue[pid] = 1
        

    elsif pid == 0 # Luke
        debugPrint("Hi I am child ")
        if @callback.class == Proc
            @callback.call(item, @ex_obj)  
        else
            puts " no callback found  "
        end
        
    else
        raise "Can't create new process "
    end

  end


  def run
      
      unless @data.length
          raise " No data found  "
          exit()
      end

      @data.each do |item|
        puts "running on data item #{item}"
        sleep 1   
        createProcess(item:item)    
      end
  
  end

end



PW = ParallelWorker.new()

PW.callback(lambda {|item| sleep 2*item ; puts "Done ,,, I am dead"})
PW.setData(data: (0..10).to_a)
PW.run()





