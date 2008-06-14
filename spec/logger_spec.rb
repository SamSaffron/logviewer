path = File.join(File.dirname(__FILE__), '.')

require 'spec'
require "#{path}/../lib/remote_logger" 
require 'timeout'

include RemoteLogger


describe Logger do
  
  before :each do 
    @logger = Logger.new
    @logger_service = LoggerService.new('test.db') 
    @logger_service.log.clear
    @logger_service.start 
  end

  after :each do
    @logger_service.stop
  end 

  it "should recieve a message if a message is sent" do
    
    @logger.info "hello"

    Timeout.timeout(2) do 
      while true do 
        sleep 0.01  
        break if @logger_service.log.count == 1  
      end 
    end 

    @logger_service.log[0].message.should == "hello"

  end 
 
  it "should flush messages if asked to and it should be fast" do 
    1000.times do  
      @logger.info "hello" 
    end 
    @logger.flush
    Timeout.timeout(2) do
      while true
        break if @logger_service.log.count == 1000
      end
    end
    @logger_service.log.count.should == 1000
  end 
  
end 
