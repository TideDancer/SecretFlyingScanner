#! /usr/bin/ruby

require 'open-uri'
require 'rufus-scheduler'
require 'gmail'

phone_num = ARGV[0]
puts "phone number is "+phone_num.to_s 

last_match = Array.new
error_fares = Array.new

scheduler = Rufus::Scheduler.new
scheduler.every '5m' do

  page = nil
  open("http://www.secretflying.com/usa-deals/") {|f| page = f.read }
  pattern = /class=\"blogpost_title\".*<\/a>/
  match = page.scan(pattern)
  
  error_fares.clear
  new_items = match - last_match
  new_items.each do |item|
    if item.include? "ERROR"
	  error_fares.push item
	end
  end
	
  puts "newly got " + error_fares.size.to_s + " error fares"
  
  if error_fares.size > 0
#    gmail = Gmail.connect(username, password)
#	if gmail.logged_in?
#	  clientList.each do |client_email|
#	    gmail.deliver do
#	      to client_email
#          subject subject_string
#	      body error_fares
#	    end
#	  end
#	  gmail.logout
#	  puts "gmail sent succesfully"
#	else
#      puts "gmail login failed"
#	end
    
	cmd = 'curl -X POST http://textbelt.com/text -d number='+phone_num.to_s+' -d "message='+error_fares.join(" ")+'"'
	puts "cmd is : "+cmd
	puts system(cmd)
	  	  
    File.open("logfile.txt","a+") do |file|
	  file.puts Time.new
	  error_fares.each {|item| file.puts item}
    end
  end

  last_match = match

end
scheduler.join
