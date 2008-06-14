path = File.join(File.dirname(__FILE__), '.')

require 'spec'
require "#{path}/../lib/remote_logger" 

describe RemoteLogger::Helpers::Cache do
  
  before :each do 
    @cache = RemoteLogger::Helpers::Cache.new(:max_elements =>5) 
  end

  after :each do
  end 

  it "should drop off items once the limit is reached" do
    [*1..6].each{|c| @cache[c] = c}

    @cache[1].should == nil
    [*2..6].each{|c| @cache[c].should == c}
  end 

  it "should operate as an LRU cache, and push accessed items to the front" do 
    [*1..5].each{|c| @cache[c] = c}
    [*1..5].reverse.each{|c| @cache[c]}

    @cache[:bob] = "bob" 
    [*1..4].each{|c| @cache[c].should == c}
    @cache[5].should == nil
    @cache[:bob].should == "bob" 

  end
end
