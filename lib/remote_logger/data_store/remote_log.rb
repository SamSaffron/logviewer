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
      @count = 0 
      @data_ready_procs = [] 
      @count_changed_procs = [] 

      @cache = RemoteLogger::Helpers::Cache.new(:max_elements => cache_size)

      fetch(0...cache_size)
      process_backlog
    end

    def [](id)
      @half_t ||= @fetch_threshold / 2
      fetch(id-@half_t...id+@half_t) unless r = @cache[id]
      return r 
    end

    def count
      @count
    end

    # called when new data is ready 
    def on_new_data_ready(data_ready_proc)
      @data_ready_procs << data_ready_proc
    end

    # takes in a proc that should be called if the row count changes
    def on_count_changed(count_change_proc)
      @count_changed_procs << count_change_proc 
    end
    
    # terminate the remote logger, do we need a start? 
    def stop
    end


    private 

    def fetch(items)
      # fatch the items in the range required
      @channel << [:request_messages, items] 
    end

    def process_backlog
      Thread.new do 
        while true 
          msg_type, p0, p1 = @channel.receive

          if msg_type == :data or msg_type == :count
            count = p1 if msg_type == :data 
            count = p0 if msg_type == :count
            if @count != count 
              @count = count
              @count_changed_procs.each {|p| p.call} 
            end
            if (msg_type == :data) 
              p0.each do |row|
                @cache[row.id] = row
              end
              @data_ready_procs.each {|p| p.call}
            end
          end
          
          sleep 0.1 
          
          # refresh our count n times per sec 
          @channel << [:request_count]
        end
      end
    end 

    # TODO refactor to a helper
    def default_channel 
      Concurrency::PollChannel.new(DEFAULT_DRB_CONNECTION, false) 
    end


  end 

end
