# service for logging all the info into a db. 
# this should get spawned by the logviewer.

require 'lib/remote_logger.rb'
include RemoteLogger::Concurrency 
include RemoteLogger::DataStore
include RemoteLogger

logger_service = LoggerService.new('test.db', @server) 
logger_service.start
getc

