path = File.join(File.dirname(__FILE__), '.')

require 'rubygems'
require 'spec'
require "#{path}/../lib/remote_logger" 
require 'timeout'

include RemoteLogger::Concurrency 

describe PollChannel do 
  before :each do 
    drb = 'druby://127.0.0.1:56445'
    @server = PollChannel.new(drb,true)
    @client = PollChannel.new(drb, false) 
  end 
  
  after :each do 
    @server.close
  end 

  it "should be able to send a message to the server" do 
    @client<<'hello' 
    @server.receive.should == 'hello' 
  end 

  it "should be able to send a message to the client" do 
    @server<<'hello'
    @client.receive.should == 'hello'
  end 

end


