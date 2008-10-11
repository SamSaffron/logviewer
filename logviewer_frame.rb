
# This class was automatically generated from XRC source. It is not
# recommended that this file is edited directly; instead, inherit from
# this class and extend its behaviour there.  
#
# Source file: logviewer.xrc 
# Generated at: Sat May 24 16:43:51 +1000 2008

class LogviewerFrame < Wx::Frame
	
	attr_reader :main_splitter_window, :top_panel, :bottom_panel,
              :log_text
	
	def initialize(*params)
	#	super(*params)
		
    position = Point.new(100, 100)
    size = Size.new(200, 200)
    super(nil, -1, "Title", position, size)
		
		xml = Wx::XmlResource.get
		xml.flags = 2 # Wx::XRC_NO_SUBCLASSING
		xml.init_all_handlers
		xml.load("logviewer.xrc")
		xml.load_frame_subclass(self, parent, "main_frame")

		finder = lambda do | x | 
			int_id = Wx::xrcid(x)
			begin
				Wx::Window.find_window_by_id(int_id, self) || int_id
			# Temporary hack to work around regression in 1.9.2; remove
			# begin/rescue clause in later versions
			rescue RuntimeError
				int_id
			end
		end
		
		@main_splitter_window = finder.call("main_splitter_window")
		@top_panel = finder.call("top_panel")
		@bottom_panel = finder.call("bottom_panel")
		@log_text = finder.call("log_text")
		if self.class.method_defined? "on_init"
			self.on_init()
		end
	end
end


