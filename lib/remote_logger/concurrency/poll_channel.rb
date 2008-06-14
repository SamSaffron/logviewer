
# A channel is used to communicate between two end points
# PollChannel indicates that all the underlying communication is done via
# A single end point that is polled. 
# One endpoint is considered a server and the other is a client 

module RemoteLogger::Concurrency 
  class PollChannel
    
    def initialize(drb_string, is_server) 
      @queue = SizedQueue.new(MAX_MESSAGES_IN_QUEUE)
      @drb_string = drb_string
      if is_server
        @message_pump = MessagePump.new(self, MAX_MESSAGES_IN_QUEUE) 
        @service = DRb.start_service(drb_string, @message_pump) 
      end 
    end

    def close
      if @service
        @service.stop_service
        @service = nil
      end 
    end

    def <<(message)
      if @service.nil? 
        remote_pump.deliver(message) 
      else 
        @message_pump.send(:queue, message) 
      end
    end 

    def receive
      if @service.nil? && @queue.size == 0
        new_queue = remote_pump.poll 
        while new_queue.length > 0
          @queue.enq new_queue.deq
        end 
      end 

      return nil if @queue.length == 0
      
      begin 
        @queue.deq(true)
      rescue ThreadError
        nil
      end
    end 

    private

    def remote_pump
      @remote_pump or @remote_pump = DRbObject.new(nil, @drb_string) 
    end 

    def add_message(message) 
      @queue.enq message
    end 

  end 
end
