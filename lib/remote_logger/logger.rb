# based of the rails logger with a drb twist 
# written by: sam.saffron@gmail.com 

module RemoteLogger

  # Inspired by the buffered logger idea by Ezra
  class Logger
    module Severity
      DEBUG   = 0
      INFO    = 1
      WARN    = 2
      ERROR   = 3
      FATAL   = 4
      UNKNOWN = 5
    end
    include Severity

    MAX_BUFFER_SIZE = 1000
      
    def self.silencer= (val) 
      @@silencer = val 
    end

    def self.silencer
      @@silencer
    end

    # Set to false to disable the silencer
    self.silencer = true

    # Silences the logger for the duration of the block.
    def silence(temporary_level = ERROR)
      if silencer
        begin
          old_logger_level, self.level = level, temporary_level
          yield self
        ensure
          self.level = old_logger_level
        end
      else
        yield self
      end
    end

    attr_accessor :level
    attr_reader :auto_flushing
    attr_reader :buffer

    def initialize(level = DEBUG, channel = nil)
      @level         = level
      @buffer        = SizedQueue.new(MAX_BUFFER_SIZE) 
      @channel = channel 
      @channel ||= default_channel
      @terminate = false 

      @flush_thread = Thread.new do 
        while !@terminate
          internal_flush
          sleep 0.05 
        end 
      end 
    end

   
    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s
      buffer.enq Message.new(Time.now, severity, message)
      message
    end

    for severity in Severity.constants
      class_eval <<-EOT, __FILE__, __LINE__
        def #{severity.downcase}(message = nil, progname = nil, &block)
          add(#{severity}, message, progname, &block)
        end

        def #{severity.downcase}?
          #{severity} >= @level
        end
      EOT
    end

    def flush
      while !@buffer.empty? 
        sleep 0.001
      end 
    end
   
    def close
      flush 
      @terminate = true
      @flush_thread.join
      @channel.close
    end

    protected

    # runs in the worker thread 
    def internal_flush
      ary = [] 
      while !buffer.empty?
        ary << buffer.deq
      end
      @channel << [:add_messages, ary] if ary.length > 0 
    end

    private

    def default_channel 
      Concurrency::PollChannel.new(DEFAULT_DRB_CONNECTION, false) 
    end
    
  end
end 

