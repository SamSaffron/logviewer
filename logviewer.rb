require 'rubygems'
require 'wx'
require 'logviewer_frame.rb'
require 'logger_service.rb'
require 'remote_logger.rb'

module LogViewer

  MAX_MESSAGES = 1000
  SERVICE_DRB = 'druby://127.0.0.1:73442'

  class MyLoggerService < LoggerService
    attr_reader :data
    
    def initialize(virtual_list)
      super()  
      @virtual_list = virtual_list
      @data = [] 
    end

    def log(time,severity,message) 
     # puts "." 
      @data << [time,severity,message]  
      @virtual_list.set_item_count(data.length)
    end 
  end 

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

      # todo cleanup - move to its own class
      pid = fork
      if pid.nil?
        c = PollChannel.new(SERVICE_DRB, true) 
        s = MyLoggerService.new(c)
        while c.alive? do 
          sleep(0.1) 
        end
        exit 
      end 

      @channel = PollChannel.new(SERVICE_DRB, false) 
      # TODO cleanup let the service start  
      sleep(0.1) 
      @channel<<:get_item_count

      @service = MyLoggerService.new(self) 
      @service.start

    end

    def on_get_item_text(item, col)
      return @service.data[item][col].to_s 
    end

    def on_get_item_column_image(item, col) 
      -1 
    end

    def on_get_item_attr(item)
      nil
    end

    def refresh
      while msg = @service.receive
        process_message(msg) 
      end
    end 

    def process_message(msg) 
    
    end

  end

  class MainFrame < LogviewerFrame 
    
    def initialize(parent = nil)
      super()
    
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
      f = MainFrame.new
      f.show
      t = Wx::Timer.new(self, 55)
      evt_timer(55) { Thread.pass }
      t.start(100)
    end
  end
  MyApp.new.main_loop

end
