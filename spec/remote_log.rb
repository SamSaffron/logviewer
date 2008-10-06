path = File.join(File.dirname(__FILE__), '.')

require 'spec'
require "#{path}/../lib/remote_logger" 

include RemoteLogger::Concurrency 
include RemoteLogger::DataStore
include RemoteLogger

describe RemoteLog do
  
  before :each do 
    drb = 'druby://127.0.0.1:56445'
    @server = PollChannel.new(drb,true)
    @client = PollChannel.new(drb,false) 
    @logger_service = LoggerService.new('test.db', @server) 
    @logger_service.start
    @remote_log = RemoteLog.new(@client) 
  end 
  
  after :each do 
    @logger_service.stop
    File.delete('test.db')
  end 

  it "should be able to look up data in the log" do
     @remote_log.count.should == 0 
     @client << [:add_message, Message.new(Time.now,Logger::Severity::INFO,"hello")] 
     Timeout::timeout(5) do 
       while (!@remote_log[0])
         sleep 0.001 
       end
     end
     @remote_log[0].message.should == "hello"
  end

 end 
