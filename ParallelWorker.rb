class ParallelWorker

    #######
    #  Author:  Alex Nudelman
    #  Project: Parallel Worker Engine
    #  V.1.0 ©  2016
    #####

    require 'pp'
    # attributes available only from functions
    # attr_accessor :data
    # attr_accessor :callback
      attr_accessor :debug_mode
      attr_accessor :max_proc

    public

    def initialize(data:nil, callback: nil)

        @counter = 0
        @debug_mode = false
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

    def set_data(data: [])
        if data.class == Array
            @data = data
        else
            raise "data is not array"
        end
    end

    def set_callback(callback: lambda{})
        if callback.class == Proc
            @callback = callback
        else
            raise "callback is not a function"
        end
    end

    def set_ext_obj(ext_obj:{})
        if callback.class == Hash
            @ex_obj = ext_obj
        else
            raise "external object is not a hash"
        end
    end

    def run

        validate()
        debug_print("main process online #{Process.pid}")
        debug_print("Data set:  #{@data.inspect}")
        wake_up_watch_dog()

        @data.each do |item|
            while @proc_queue.length >= @max_proc do
                debug_print(" ### Queue is full (limit is: #{@max_proc}) please wait ... #{@proc_queue.length} ### ")
                is_process_alive?()
                break if @proc_queue.length < @max_proc
            end

            debug_print("running on data item #{item}")
            create_process(item:item)
            @counter+=1
        end
        wait_for_last()
        puts "Father is Done "
    end

    private

    def is_process_alive?
        debug_print "The queue : #{@proc_queue.inspect}"

        @proc_queue.each do |pid, state|

            debug_print("Looking for #{pid}")
            begin
                is_running = Process::kill 0, pid
            rescue
                is_running = false
            end

            debug_print("The result is #{is_running} for #{pid}")

            unless is_running
                debug_print "Process => #{pid} is not running"
                delete_process(pid:pid)
            end
        end
    end

    def debug_print(str)
        if @debug_mode
            sleep 1
            puts "#{Time.new.inspect}: #{str}"
        end
    end

    def dump_data(data: [])
        puts "========"
        pp data
        puts "========"
    end

    def delete_process(pid: 0)
        if pid
            debug_print("Trying to delete process pid[#{pid}]")
            @proc_queue.delete(pid)
            debug_print("pid[#{pid}] was deleted")
        end
    end

    def create_process(item: 0)

        debug_print("starting new process with Item : #{item}" )
        pid = fork do

            debug_print("Hi I am child")
            if @callback.class == Proc
                @callback.call(item, @ex_obj)
                debug_print "Child: Time to die !!!"
                exit(55)
            else
                puts " no callback found #{$$} "
            end


        end
        debug_print("Hi I am your father => listening to #{pid}")

        @counter+=1
        @proc_queue[pid] = 1
    end

    def wait_job
        debug_print(" The dog is on shift ")
        while(true) do
            allprocs = Process.waitall
             debug_print(allprocs.inspect)
            sleep 1
        end
    end

    def wait_for_last
        debug_print("For loop is done , waiting for last to finish ")
        debug_print("length:  #{Process.waitall().length}")

        while(@proc_queue.length> 0) do
            debug_print("waiting for last #{@proc_queue.length}")
            is_process_alive?()
            sleep 1
        end

        @watch_dog.terminate
    end

    def wake_up_watch_dog
        debug_print("Waking up the watchdog ")
        @watch_dog = Thread.new{wait_job()}
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

end
