module RemoteLogger::DataStore

  # Represents a caching remote instance of a log. 
  # Allows for signalling when changes happen
  # Caches a portion of the log in memory 
  class RemoteLog

    # cache_size is the max number of items to keep in memory
    # the threshold is the amount we need in front/back of the 
    # previous lookup 
    def initialize(channel = nil, cache_size=800, fetch_threshold=200)
      @channel = channel
      @channel ||= default_channel
      @cache_size = cache_size
      @fetch_threshold = fetch_threshold

      fetch(0...cache_size)
    end

    def [](item)
    end

    def count
    end

    # takes in a proc that should be called if the underlying data changes 
    def on_data_change(change_data_proc)
    end

    # takes in a proc that should be called if the row count changes
    def on_count_change(count_count_proc)
    end
    

    private 

    def fetch(items)
      # fatch the items in the range required
      
    end

    def process_backlog

    end 

    # TODO refactor to a helper
    def default_channel 
      Concurrency::PollChannel.new(DEFAULT_DRB_CONNECTION, false) 
    end


  end 

end
