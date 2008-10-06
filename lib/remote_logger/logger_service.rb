module RemoteLogger

  # provides 2 services 
  # 1. Store log messages in the db 
  # 2. Return the count and list of messages in the DB 

  class LoggerService

    attr_reader :log

    def initialize (log_file = DEFAULT_LOG_FILE, channel = nil) 
      @channel = channel
      @channel ||= default_channel
      @log = DataStore::Log.new(log_file)
    end 

    def start
      @thread = Thread.new do 
        while !@quit 
          # process messages 20 times a sec 
          sleep(0.05)
          messages = [] 
          while (msg = @channel.receive) 
            messages << msg
          end
          process(messages) 
        end
      end
    end 

    def stop
      if @thread 
        @quit = true
        @thread.join 
        @thread = nil 
        @channel.close
      end
    end

    private 

    def default_channel 
      Concurrency::PollChannel.new(DEFAULT_DRB_CONNECTION, true) 
    end

    def process(messages) 
      messages.each do |msg| 
        type, p1, p2, p3 = msg
        case type
          when :request_count
            @channel << [:count, @log.count]
          when :add_messages
            @log << p1
          when :add_message
            @log << p1
            # note: we have no seperate message for requesting the count
            #   instead we piggy back a count on request_messages
            #   the reason is that this will be called much more often and 
            #   it simplifies the protocol. 
          when :request_messages
            @channel << [:data, @log[p1], @log.count] 
        end
      end
    end

  end # end class
end # end module
