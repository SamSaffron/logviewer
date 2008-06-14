# public drb interfaces that interact with the channel
# only 2 drb endpoints are used, deliver and poll

module RemoteLogger::Concurrency
  class MessagePump
    def initialize(channel,max_size) 
      @channel = channel
      @queue = SizedQueue.new(max_size) 
    end

    # will send a message to a channel
    def deliver(message) 
      @channel.send(:add_message, message)
    end 

    # will return a queue of all pending messages 
    def poll
      # can be optimised to swap out the queue 
      # will require a mutex 
      rval = Queue.new
      while @queue.length > 0  
        begin 
          rval.enq @queue.deq(true) 
        rescue ThreadError
          break 
        end
      end
      rval 
    end

    private 
    
    def queue(message) 
      unless message.nil? 
        @queue.enq message
      end
    end 
  end 
end 
