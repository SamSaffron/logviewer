
class Channel 

  def initialize(remote_drb,local_drb) 
    @queue = SizedQueue.new(1000)  
    @remote_drb = remote_drb 
    DRb.start_service(local_drb, MessagePump.new(self)) 
  end 

  # send a message to endpoint 
  def <<(message)
    # make non-blocking ? 
    remote_pump.deliver(message) 
  end 

  # receive the next message or nil
  def receive
    return @queue.deq
  end 

  private

  def remote_pump
    @remote_pump or @remote_pump = DRbObject.new(nil, @remote_drb) 
  end 

  def add_message(message) 
    @queue.enq message
  end 

end 

