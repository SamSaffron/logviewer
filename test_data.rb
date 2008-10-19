require 'lib/remote_logger.rb'
include RemoteLogger::Concurrency 
include RemoteLogger::DataStore
include RemoteLogger


logger = Logger.new
10.times do |i|
  logger.warn "This is a warning"
  logger.error "This is an error"
end
logger.flush
getc
