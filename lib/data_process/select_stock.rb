require "pathname"
require "json"
lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"init","stock_list_init.rb")
require File.join(lib_path,"yahoo","load_daily_k_to_hash.rb")
require File.join(lib_path,"utility","get_all_stock_name_table.rb")
require File.join(lib_path,"analysis","K_daily_MACD_analysis.rb")



def select_stock_by_MACD
  start=Time.now
  best_stock_array=Array.new
  count=0
  $all_stock_list.each do |symbol,name|
  	count+=1
  	puts "progress=#{(count/2471.00)*100}%"
  temp_array=Array.new
    data_hash = yahoo_get_raw_data_from_file(symbol)
   #get_macd_array(data_hash,100,60)
   temp_array=get_current_macd_array(data_hash,symbol)
   next if temp_array.size==0
puts   "temp_array=#{temp_array}"
   if (temp_array[0][0]>temp_array[1][0] && temp_array[1][0]>temp_array[2][0] \
   	&& temp_array[2][0]>temp_array[3][0] && temp_array[3][0]>temp_array[4][0])
   temp_array_2=get_diff_array_from_array(temp_array)
   best_stock_array<<symbol   if (temp_array_2[0]<2 && temp_array_2[1]<2 && temp_array_2[2]<2 && temp_array_2[3]<2)
    end

  end
  puts best_stock_array
  puts best_stock_array.size
  puts "cost time=#{Time.now - start}"

end


if $0==__FILE__

	select_stock_by_MACD
end