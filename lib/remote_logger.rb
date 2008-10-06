require 'time' 
require 'drb'

dir = File.dirname(__FILE__) 
$LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir) 


# Library used for logging events to a remote server
#
# All transport is over drb, meant as a replacement for the standard
# Logging service
module RemoteLogger
  require 'remote_logger/constants'
  require 'remote_logger/concurrency/constants'
  require 'remote_logger/message'

  autoload :Logger, 'remote_logger/logger'
  autoload :LoggerService, 'remote_logger/logger_service'
  module Helpers
    autoload :Cache, 'remote_logger/helpers/cache'
  end
  module Concurrency
    autoload :PollChannel, 'remote_logger/concurrency/poll_channel'  
    autoload :MessagePump, 'remote_logger/concurrency/message_pump'  
  end 
  module DataStore
    autoload :Log, 'remote_logger/data_store/log'
    autoload :RemoteLog, 'remote_logger/data_store/remote_log'
  end
end 
