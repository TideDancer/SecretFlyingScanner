#! /usr/bin/ruby

require 'open-uri'
require 'rufus-scheduler'
require 'gmail'
require 'getoptlong'
require 'to_regexp'

opts = GetoptLong.new(
		['--number','-n', GetoptLong::REQUIRED_ARGUMENT],
		['--keyword','-k', GetoptLong::REQUIRED_ARGUMENT],
		['--website','-w', GetoptLong::OPTIONAL_ARGUMENT],
		['--pattern','-p', GetoptLong::OPTIONAL_ARGUMENT],
		['--help','-h', GetoptLong::NO_ARGUMENT],
)

key_word = Array.new
pattern = ''
phone_num = ''
website = ''

opts.each do |opt, arg|
  case opt
    when '--number'
	  phone_num = arg # phone_num is a string instead of a int
	when '--keyword'
	  key_word.push(arg)
	when '--website'
	  if arg == ''
	    website = "http://www.secretflying.com/usa-deals/"
	  else
	    website = arg
	  end
	when '--pattern'
	  if arg == ''
	    pattern = /class=\"blogpost_title\".*<\/a>/
	  else
	    pattern = arg.to_regexp
      end
	when '--help'
	  puts <<-EOF
nohup ruby SecretFlyingReminder_v2.rb -n [number] -k [keyword] -w [website] -p [pattern] &
      EOF
	end
end

last_match = Array.new
target_list = Array.new

scheduler = Rufus::Scheduler.new
scheduler.every '5m' do

  page = nil
  open(website) {|f| page = f.read }
  match = page.scan(pattern)
  
  target_list.clear
  new_items = match - last_match
  new_items.each do |item|
    key_word.each do |key|
      if item.include? key
	    target_list.push item
	  end
	end
  end
	
  puts "newly got " + target_list.size.to_s + " error fares"
  
  if target_list.size > 0
	cmd = 'curl -X POST http://textbelt.com/text -d number='+phone_num+' -d "message='+target_list.join(" ")+'"'
	puts "cmd is : "+cmd
	puts system(cmd)
	  	  
    File.open("logfile.txt","a+") do |file|
	  file.puts Time.new
	  target_list.each {|item| file.puts item}
    end
  end

  last_match = match

end
scheduler.join
