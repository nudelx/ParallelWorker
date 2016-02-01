class ParallelWorker

    require 'pp'
    attr_accessor :data
    attr_accessor :callback


    private

    def isProcessAlive?
        puts "The que : #{@proc_queue.inspect}"

        @proc_queue.each do |pid, state|

            debugPrint("Looking for #{pid}")
            begin
                is_running = Process::kill 0, pid
            rescue
                is_running = false
            end

            debugPrint("The result is #{is_running} for #{pid}")

            unless is_running
                debugPrint "Process => #{pid} is not running"
                deleteProcess(pid:pid)
            end
        end
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
                puts "Child: Time to die !!!"
                exit(55)
            else
                puts " no callback found #{$$} "
            end


        end
        debugPrint("Hi I am your father => listening to #{pid}")

        @counter+=1
        @proc_queue[pid] = 1
    end

    def waitJob
        debugPrint(" The dog is on shift ")
        while(true) do
            allprocs = Process.waitall
            pp allprocs.inspect
            sleep 1
        end
    end

    def waitForLast
        debugPrint("For loop is done , waiting for last to finish ")
        puts "length:  #{Process.waitall().length}"

        while(@proc_queue.length> 0) do
            debugPrint("waiting for last #{@proc_queue.length}")
            isProcessAlive?()
            sleep 1
        end

        @watch_dog.terminate
    end

    def wakeUpWatchDog
        debugPrint("Waking up the watchdog ")
        @watch_dog = Thread.new{waitJob()}
    end

    def is_data_exist
        unless @data.length
            raise " No data found  "
            exit()
        end
    end

    def is_callback_exist
        unless @callback.class == Proc
            raise " callback is not valid  "
            exit()
        end
    end

    def validate
        is_data_exist()
        is_callback_exist()
    end

    public

    def initialize(data:nil, callback: nil)

        @counter = 0
        @debug_mode = true
        @max_proc = 3
        @watch_dog = nil
        @proc_queue = {}

        @use_log  = false
        @log_path = '/tmp/'
        @log_name = 'ParallelWorker.log'

        @callback = callback
        @data     = data
        @ex_obj   = nil
        @proc_out = 'pid.out'
        @keep_proc_out = false
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

    def run

        validate()
        debugPrint("main process online #{Process.pid}")
        debugPrint("Data set:  #{@data.inspect}")
        wakeUpWatchDog()

        @data.each do |item|
            while @proc_queue.length >= @max_proc do
                debugPrint(" ### Queue is full (limit is: #{@max_proc}) please wait ... #{@proc_queue.length} ### ")
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
PW.setCallback(callback:lambda {|item,ext_obj| sleep 5*item ; puts "Done ,,, I am dead my Pid is #{Process.pid}"})
PW.setData(data: (1..10).to_a)
PW.run()
