path = File.join(File.dirname(__FILE__), '.')

require 'spec'
require "#{path}/../lib/remote_logger" 

include RemoteLogger::DataStore
include RemoteLogger

describe Log do
  
  before :each do 
    @log = Log.new('test.db')
  end

  after :each do
    File.delete('test.db')
  end 

  it "should be able to add messages to the log" do
    d = Time.now

    [*0..9].each do |n| 
      @log << Message.new(d,Logger::Severity::INFO,"hello") 
    end 

    messages = @log[0..9] 
    messages.length.should == 10 

    [*0..9].each do |n| 
      messages[n].severity.should == Logger::Severity::INFO 
      messages[n].message.should == "hello"
      # dates are a little funny ... 
      messages[n].time.to_f.to_s.should == d.to_f.to_s 
      messages[n].id.should == n
    end 
  end 

  it "should be able to insert multiple rows efficiently" do 
    @log.count.should == 0
    chunk = [] 
    100.times{chunk << Message.new(Time.now,Logger::Severity::INFO,'testtest'*1000)}
    10.times{@log << chunk}
    @log.count.should == 1000
  end 

  it "should clear the log when asked to" do 
    @log << Message.new(nil,Logger::Severity::INFO,"hello") 
    @log.count.should == 1 
    @log.clear 
    @log.count.should == 0 
    @log[0].should == nil 
  end

 end 
