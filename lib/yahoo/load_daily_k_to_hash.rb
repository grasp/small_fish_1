require "pathname"
require "json"
lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"utility","get_all_stock_name_table.rb")


#600345.ss,2013-09-30,15.26,15.76,15.25,15.66,1604700,15.66
#开盘，最高，最低，收盘，成交量
def yahoo_get_raw_data_from_file(symbol)
 h_data_path=File.join(Pathname.new(__FILE__).parent.parent.parent,"history_daily_data")
 data_hash=Hash.new
 stock_file_path=File.join(h_data_path,symbol+".txt")
 #puts  stock_file_path
 open(stock_file_path).each do |line|
   
 	daily_data = line.split(",")
 	next if daily_data[2].nil?
 	data_hash[daily_data[1]]=[daily_data[2],daily_data[3],daily_data[4],daily_data[5],daily_data[6],daily_data[7].strip]
 	 #$redis.hset("k_raw_d:#{symbol}",daily_data[1],[daily_data[2],daily_data[3],daily_data[4],daily_data[5],daily_data[6],daily_data[7].strip].to_json)
 end
data_hash
end


#not used , write into redis , cost 1G memory , it just 150M file!
def load_all_raw_data_into_redis
	$all_stock_list.each do |symbol,name|
		puts "#{symbol} start"
		yahoo_get_raw_data_from_file(symbol)
	end

end

if $0==__FILE__

	start = Time.now
  #This file is search from TongHuaShun software installed folder
  table_file=File.join(Pathname.new(__FILE__).parent.parent.parent,"info","stock_table_2013_10_01.txt")
  assert(File.exist?(table_file),"#{table_file} not exist!")

  stock_list=load_stock_list_file_into_redis(table_file)
  assert(stock_list.size>2400,"some stock is omitted, less 7500!")
	load_all_raw_data_into_redis

	puts "cost time=#{Time.now - start}"
#end
end