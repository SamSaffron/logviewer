require 'rubygems'
require 'wx'
require 'logviewer_frame.rb'
require 'lib/remote_logger.rb'
require 'lib/prefs.rb'
require 'yaml'

include RemoteLogger::Concurrency 
include RemoteLogger::DataStore
include RemoteLogger
include Wx

module LogViewer

  MAX_MESSAGES = 1000

  class VirtualListView < Wx::ListCtrl
    
    EVT_TIMER_ID = 6003

    def initialize(parent) 
      super(parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::LC_REPORT | Wx::LC_VIRTUAL | Wx::LC_HRULES | Wx::LC_VRULES)
     
      insert_column(0,"Severity")
      insert_column(1,"Message")
      insert_column(2,"Time")
      set_column_width(0,175)
      set_column_width(1,175)
      set_column_width(2,175)
      set_item_count(0)
      

      timer = Wx::Timer.new(self, EVT_TIMER_ID)
		  evt_timer(EVT_TIMER_ID) { refresh }
		  timer.start(500)

      # TODO cleanup - move to its own class
   #  pid = fork
   #  if pid.nil?
   #    s = LoggerService.new
   #    while true do 
   #      sleep(0.1) 
   #    end
   #    exit
   #  end 

      # TODO cleanup let the service start  
      
      @remote_log = RemoteLog.new
      @remote_log.on_count_changed proc{self.set_item_count @remote_log.count} 

    end

    def on_get_item_text(item, col)
      data = @remote_log[item] 
      if data 
        case col
        when 0 
          return data.severity.to_s 
        when 1 
          return data.message
        when 2 
          return data.time.to_s
        end
      end 

      return ""
    end

    def on_get_item_column_image(item, col) 
      -1 
    end

    def on_get_item_attr(item)
      nil
    end

    def process_message(msg) 
    
    end

  end

  class MainFrame < LogviewerFrame 
    
    def initialize(*params)
      position = Point.new(100, 100)
      size = Size.new(200, 200)
      super(nil, -1, "Title", position, size)
    
      @log_text.set_value "Hello world"

      sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      vb = VirtualListView.new(@top_panel)
      sizer.add(vb, 1, Wx::GROW|Wx::ALL, 2)
      @top_panel.set_sizer(sizer)


      # @main_splitter_window = finder.call("main_splitter_window")
      # @top_panel = finder.call("top_panel")
      # @main_list = finder.call("main_list")
      # @bottom_panel = finder.call("bottom_panel")
      # @log_text = finder.call("log_text")
    end
  end


 
  class MyApp < Wx::App
    def on_init
      @prefs = Prefs.load('window.prefs',100,200,200,300)
      
      pos = Point.new(@prefs.position.x,@prefs.position.y)
      size = Size.new(@prefs.size.width,@prefs.size.height)

      f = Wx::Frame.new(nil, -1, "Title", pos, size)
      
      splitter = SplitterWindow.new(f, -1)
      
      
      
      p1 = Wx::Panel.new(splitter, -1)
      vb = VirtualListView.new(p1)
      sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      sizer.add(vb, 1, Wx::GROW|Wx::ALL, 2)
      p1.set_sizer(sizer)
      
      p2 = Wx::Panel.new(splitter, -1)
      Wx::StaticText.new(p2, -1, "Log info")
      
      splitter.set_minimum_pane_size(20)
      splitter.split_horizontally(p1, p2, 100)
      f.show
      

      f.evt_close do |event|
        frame = event.get_event_object
        @prefs.size = frame.size
        @prefs.position = frame.position
        @prefs.save!
        event.skip
      end
      
      #t = Wx::Timer.new(self, 55)
      #evt_timer(55) { Thread.pass }
      #t.start(100)
      
    end

  end
  MyApp.new.main_loop

end
