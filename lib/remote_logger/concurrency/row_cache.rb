module RemoteLogger::Concurrency 
  
  class RowCache

    MAX_SIZE = 1000
    FETCH_SIZE = 50 


    def initialize(channel) 
      @row_count = 0 
      @channel = channel
      @channel<< :get_row_count
      @cache = Cache::LRU.new(MAX_SIZE)
    end 

    # for now lets block later on we will not 
    def get_data(row_num)
      row = @cache[row_num]
      if row.nil? 
        @channel << [:get_rows, row_num, FETCH_SIZE]
      end
      row
    end

    def get_row_count
      @row_count 
    end

    private 
    def process_messages
      while i = @channel.receive 
        type, p1 = i
        case type 
        when :row_count
          @row_count = p1
        when :data
          p1.each do |row| 
            @cache[row.index] = row 
          end
        end
      end 
    end

  end

end
