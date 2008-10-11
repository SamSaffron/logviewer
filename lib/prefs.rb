require 'yaml'

module LogViewer 
  class Prefs

    attr_accessor :filename

    class Point
      attr_accessor :x 
      attr_accessor :y

      def initialize(x,y)
        @x = x
        @y = y
      end
    end
    
    class Size
      attr_accessor :width
      attr_accessor :height

      def initialize(width,height)
        @width = width
        @height = height
      end
    end


    def initialize(filename,x,y,width,height)
      # init default position
      @size = Prefs::Size.new(x,y)
      @position = Prefs::Point.new(width,height)
      @filename = filename
    end
    
    def size=(val)
      @size.width = val.width
      @size.height = val.height
    end

    def size
      @size
    end

    def position=(val)
      @position.x = val.x
      @position.y = val.y
    end

    def position
      @position
    end

    def Prefs.load(filename,x,y,width,height)
      prefs = YAML::load_file(filename) rescue nil 
      
      unless prefs and prefs.position and prefs.size
        prefs = Prefs.new(filename,x,y,width,height)
      else 
        prefs.filename = filename
      end

      prefs
    end

    def save!
      File.open(@filename, 'w') do |prefs_file|
        prefs_file << self.to_yaml
      end
    end
  end
end