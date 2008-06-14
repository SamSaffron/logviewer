require 'sqlite3'

module RemoteLogger::DataStore

  # log implementation using sqlite as a backend
  class Log

    def initialize(filename)
      @count = 0 
      @filename = File.expand_path(filename)
      @db = SQLite3::Database.new(@filename)
      init_db
    end

    def <<(data)
      if data.class == Array 
        @db.transaction 
        data.each {|m| add_message(m)}
        @db.commit
      else 
        add_message(data) 
      end 
    end

    def [](item)
      rval = nil 
      if item.class == Range
        # sqlite is 1 based ruby is zero based 
        @select.bind_params((item.begin+1),(item.end+1))
        rval = [] 
        @select.execute! do |row|
          rval << RemoteLogger::Message.new(Time.at(row[1].to_f),row[2].to_i,row[3],(row[0].to_i-1))
        end
      else
        @select_1.bind_params(item+1) 
        @select_1.execute! do |row|
          rval = RemoteLogger::Message.new(Time.at(row[1].to_f),row[2].to_i,row[3],(row[0].to_i-1))
        end
      end 
      rval 
    end 

    def count
      return @count 
    end 

    def clear
      @db.execute('delete from log')
      @count = 0
    end 

    private 

    def add_message(msg)
      @insert.bind_params(msg.time.to_f.to_s,msg.severity.to_s,msg.message) 
      @insert.execute
      @count += 1
    end

    def init_db
      columns = "time,severity,message"
      begin 
        @db.execute("create table log(#{columns})") 
      rescue SQLite3::SQLException
        @count = @db.get_first_value("select count(*) from log")
      end 
      @insert = @db.prepare "insert into log(#{columns}) values(?,?,?)" 
      @select_1 = @db.prepare "select ROWID, #{columns} from log where ROWID = ?"
      @select = @db.prepare "select ROWID, #{columns} from log where ROWID >= ? and ROWID <= ?"
    end

  end
end 
