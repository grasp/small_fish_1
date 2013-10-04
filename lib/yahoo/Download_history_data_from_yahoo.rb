require "pathname"
require 'test/unit'
include Test::Unit::Assertions

lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"utility","get_all_stock_name_table.rb")
require File.join(lib_path,"init","stock_list_init.rb")



def download_all_history_data_from_file(stock_list_file)
   #stock_list=get_ss_sz_stock_list_from_file(stock_list_file)
  stock_list=$redis.hkeys("stock_name_list")

   stock_list.each do |code|
   begin
   symbole_file_name="G:\\small_fish_0\\history_daily_data\\#{code}.txt"
   if File.exist?(symbole_file_name)
   		puts "#{code} is skip"
   	next
   else
   	download_one_stock_history_data(code)
   	puts "#{code} is done for download!"

    #wait for a while for next as worry about yahoo may disable download
    #actully , Yahoo will stop download after about 800 numbers, we have to reset machine to change IP
       	 sleep 1
   end

   rescue Exception
    puts "Exception meeted"
   raise
   
   end
   end

  
end

def download_one_stock_history_data(symbol)
  lib_path=Pathname.new(__FILE__).parent.parent
	command_run="ruby #{File.join(lib_path,"yahoo","yahoofinance.rb")} -z -d 200 #{symbol}"
	result=`#{command_run}`
	raise if result.size.nil?
	#store to file  
  symbole_file_name=File.join(lib_path.parent,"history_daily_data","#{symbol}.txt")
	symbol_file=File.new(symbole_file_name,"w")
	symbol_file << result
    symbol_file.close

end





#only run if test this file
if $0 == __FILE__
#get_one_stock_history_data("601566.ss")
stock_list_file="G:\\small_fish_0\\info\\stock_table_2013_10_01.txt"
download_all_history_data_from_file(stock_list_file)
end