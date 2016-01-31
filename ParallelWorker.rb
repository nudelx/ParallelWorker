class ParallelWorker

    require 'pp'
    attr_accessor :data
    attr_accessor :callback

    def initialize

        @counter = 0
        @debug_mode = true
        @max_proc = 3
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
            sleep 1
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

    def isProcessAlive?
        puts "The que : #{@proc_queue.inspect}"
        @proc_queue.each do |pid, state|
            is_running = false
            debugPrint("Looking for #{pid}")
            begin
                is_running = Process::kill 0, pid
            rescue
                deleteProcess(pid:pid)
            end

            debugPrint("The result is #{is_running} for #{pid}")

            unless is_running
                debugPrint "Process => #{pid} is not running"
                deleteProcess(pid:pid)
            end
        end
    end

    def deleteProcess(pid: 0)
        if pid
            debugPrint("Trying to delete process pid[#{pid}]")
            @proc_queue.delete(pid)
            debugPrint("pid[#{pid}] was deleted")
        end
    end

    def createProcess(item: 0)

        debugPrint("starting new process with Item : #{item}" )
        pid = fork do

            debugPrint("Hi I am child")
            if @callback.class == Proc
                @callback.call(item, @ex_obj)
                exit()
            else
                puts " no callback found #{$$} "
            end


        end
        debugPrint("Hi I am your father => listening to #{pid}")
        @counter+=1
        @proc_queue[pid] = 1
    end

    def waitJob
        debugPrint("waiting dog is online #{Process.pid}")

        while(true) do

            begin
                allprocs = Process.waitall
                pp allprocs.inspect
            rescue

            end

            sleep 1

        end

    end

    def waitForLast
        puts "length:  #{Process.waitall().length}"
        begin
            while(Process.waitall().length > 0) do
                debugPrint("waiting for last #{Process.waitall().length}")
                sleep 1
                isProcessAlive?()

            end
        rescue
        end
        @watch_dog.join
    end

    def wakeUpWatchDog
        debugPrint("Waking up the watchdog ")
        @watch_dog = Thread.new{waitJob()}
    end

    def run
        unless @data.length
            raise " No data found  "
            exit()
        end


        debugPrint("main online #{Process.pid}")
        debugPrint("Data set:  #{@data.inspect}")
        wakeUpWatchDog()

        @data.each do |item|
            while @proc_queue.length >= @max_proc do
                debugPrint("Queue is full please wait ... #{@proc_queue.length}")
                isProcessAlive?()
                break if @proc_queue.length < @max_proc
            end

            debugPrint("running on data item #{item}")
            createProcess(item:item)
            @counter+=1
        end
        waitForLast()
        puts "Father is Done "
    end

end



PW = ParallelWorker.new()
PW.setCallback(callback:lambda {|item,ext_obj| sleep 5*item ; puts "Done ,,, I am dead my Pid is #{item}"})
PW.setData(data: (0..3).to_a)
PW.run()
