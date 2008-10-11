path = File.join(File.dirname(__FILE__), '.')

require 'spec'
require "#{path}/../lib/prefs" 

include LogViewer

describe Prefs do
  
  before :each do
    @prefs = Prefs.load('test.prefs',1,2,3,4)
  end 
  
  after :each do
    File.delete('test.prefs')
  end 

  it "should persist the size and position" do
    @prefs.position = Prefs::Point.new(100,200)
    @prefs.size = Prefs::Size.new(300,400)
    @prefs.save!

    @prefs = Prefs.load('test.prefs',1,2,3,4)

    @prefs.position.x.should == 100
    @prefs.position.y.should == 200
    @prefs.size.width.should == 300
    @prefs.size.height.should == 400

  end

 end 