# simple wrapper for a log message

module RemoteLogger
  class Message
    attr_accessor :time
    attr_accessor :severity
    attr_accessor :message
    attr_accessor :id 

    def initialize(time,severity,message,id=nil)
      @time = time
      @severity = severity 
      @message = message
      @id = id
    end

  end
end
