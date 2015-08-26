#!/usr/bin/env ruby
%w{rubygems time csv json}.each{|r| require r}

# Returns the timestamp, which we utilize as the key for the issues 
# stored in the current run. 
def report_generation_time(srcFilePath) 
  return File.mtime(srcFilePath).strftime("%d-%m-%Y-%H-%M-%S")
end


def report_file_base_name(srcFilePath) 
  return File.basename(srcFilePath, ".nbe")
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
  if ARGV.empty? || ARGV.length < 1
    output_missing_arguments_error
  else     
    # Parsing arguments 
    nbe_file_path = ARGV[0]
    should_clean_db = (ARGV[1].nil? or ARGV[1] != '-c') ? false :  true

    # Initializing the processor 
    nbe_timestamp = report_generation_time(nbe_file_path)

    nbe_report_file_base_name = report_file_base_name(nbe_file_path)
    nbe_host_name = nbe_report_file_base_name.split("-")[1].tr("_", ".")
    nbe_scanner_id = ''

    $stdout.puts "Processing '"+ nbe_file_path  + "' and converting it to the following JSON file: '"+ nbe_report_file_base_name + ".json' ...\n"

    csv_issues = CSV.read(nbe_file_path, col_sep: '|')
    
    is_nbe_header = true
    nbe_issues = Array.new

    

    csv_issues.each { |nbe_issue|
        if is_nbe_header
          nbe_scanner_id = nbe_issue[6]
          is_nbe_header = false
        else 
          nbe_issue_hash         = {}
          nbe_issue_hash[:timestamp]  = nbe_timestamp
          nbe_issue_hash[:scanner] = nbe_scanner_id
          nbe_issue_hash[:host] = nbe_host_name
          nbe_issue_hash[:port] = nbe_issue[3]
          nbe_issue_hash[:id] = nbe_issue[4]
          nbe_issue_hash[:severity] = nbe_issue[5]
          nbe_issue_hash[:description] = nbe_issue[6]

          nbe_issues.push(nbe_issue_hash)
        end
    }
    
    File.open(nbe_report_file_base_name+'.json', 'w') do |f|  
      nbe_issues.each { |nbe_issue| 
        f << nbe_issue.to_json
        f << "\n"
      }  
    end      
    
    $stdout.puts "\nProcessing  completed and following JSON file has been generated: '"+ nbe_report_file_base_name + ".json' ...\n"
  end 
end


begin 
  process_nbe
rescue Exception => e
  $stderr.puts "Uncaught exception while processing nbe file. Detalis: #{e.message}"
  exit
end   




