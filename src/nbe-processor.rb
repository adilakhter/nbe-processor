#!/usr/bin/env ruby
%w{rubygems time redis csv json}.each{|r| require r}


# Key name for primary index. 
# Using this key, the list of available reports are stored as set in REDIS
NBE_REPORTS_KEY = "reports"

# REDIS Host 
REDIS_HOST = ENV["REDIS_PORT_6379_TCP_ADDR"].nil? ? "127.0.0.1" : ENV["REDIS_PORT_6379_TCP_ADDR"]

# REDIS PORT 
REDIS_PORT_NO = ENV["REDIS_PORT_6379_TCP_PORT"].nil? ? "6379" : ENV["REDIS_PORT_6379_TCP_PORT"]

# Returns the timestamp, which we utilize as the key for the issues 
# stored in the current run. 
def current_report_id(srcFilePath) 
  return File.mtime(srcFilePath).strftime("%d-%m-%Y-%H-%M-%S")
end

def index_report(report_id)
  # Adding it to REDIS SET of available reports indexed by report_id
  # In order to get all the members: use <smembers reports>.
  # Example:
  # 127.0.0.1:6379> SMEMBERS add_reports_index_with
  # 1) "20-08-2015-20-47-20"
  # 2) "20-08-2015-20-47-22"
  $redis.sadd(NBE_REPORTS_KEY , report_id) 
end

def output_missing_arguments_error
    $stderr.puts "\n\nnbe-processor: ERROR\n"
    $stderr.puts "  Usage:"
    $stderr.puts "    Please specify file path of source input file "
    $stderr.puts "    and whether to cleanup existing Redis storage (if desired):\n" 
    $stderr.puts "  Options:"
    $stderr.puts "    -c #cleans up Redis by invoking flushall"
    $stderr.puts "  Example:"
    $stderr.puts "    ./nbe-processor.rb resources/input.nbe  -c"
    $stderr.puts "  Note: ensure chmod a+x on nbe-processor"      
end


def process_nbe
  if ARGV.empty?
    output_missing_arguments_error
  else     
    # Parsing arguments 
    nbe_file_name = ARGV[0]
    should_clean_db = (ARGV[1].nil? or ARGV[1] != '-c') ? false :  true

    # Initializing the processor 
    report_id = current_report_id(nbe_file_name)
    
    # Connecting to REDIS
    $stdout.puts "Connecting to Redis at host: "+ REDIS_HOST + " and port: "+ REDIS_PORT_NO + "..."
    $redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT_NO) 
    if should_clean_db 
      $stdout.puts "Cleaning Radis storage ..."  
      $redis.flushall
    end

    $stdout.puts "Processing '"+ nbe_file_name  + "' with REPORT_ID: '"+ report_id + "' ...\n"
    CSV.foreach(nbe_file_name, col_sep: '|', headers:true) { |nbeIssue| 
        $stdout.puts nbeIssue.to_hash.to_json
        $redis.sadd(report_id, nbeIssue.to_hash.to_json)
    }

    # Updating Reports index with the current report. 
    index_report(report_id) 

    $stdout.puts("\nProcessing  completed with REPORT_ID: "+report_id + "...\nUse <SMEMBERS "+report_id +"> to retrieve the issues as JSON.")
  end 
end


begin 
  process_nbe
rescue Exception => e
  $stderr.puts "Uncaught exception while processing nbe file. Detalis: #{e.message}"
  exit
end   




