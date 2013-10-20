
require File.expand_path("../raw_process_daily_k.rb",__FILE__)
require File.expand_path("../../../init/config_load.rb",__FILE__)

#依次为开盘，最高，最低，收盘，成交量
def low_high_price_analysis(raw_hash)

   #raw_hash=get_raw_data_from_file(symbol)
   raw_array=raw_hash.to_a

   day_array=[] #存储
  

   low_price_hash=Hash.new
   high_price_hash=Hash.new


   [1,2,3,4,5,10,20,30,60,100,120].each do |i|
     day_array<<AppSettings.send("price_#{i}_day")
   end

   #puts  macd_day_array

   raw_array.each_index do |daily_k_index|

   low_price_array=[]
   high_price_array=[]


   #计算每一日的各个均值
   day_array.each do |number_day|
    lowest_price=10000000
    highest_price=-1
   	number_day.downto(1).each do |j|
   		next if daily_k_index+j>raw_array.size-1#忽略
        lowest_price=raw_array[daily_k_index+j][1][3] if raw_array[daily_k_index+j][1][3].to_f < lowest_price.to_f
        highest_price= raw_array[daily_k_index+j][1][3]  if highest_price.to_f<raw_array[daily_k_index+j][1][3].to_f
   	end  #end of macd_day sum  

   	low_price_array<<lowest_price
   	high_price_array<<highest_price
 
   	end #end of one of macd day
   	#puts raw_array[daily_k_index][0]+" "+macd_array.to_s
   	low_price_hash[raw_array[daily_k_index][0]]=low_price_array.to_s 
   	high_price_hash[raw_array[daily_k_index][0]]=high_price_array.to_s 
end#end of one day index

[low_price_hash,high_price_hash]

end

if $0==__FILE__
	start=Time.now
	raw_hash=get_raw_data_from_file("000009.sz")
	low_high_price_analysis(raw_hash)
	puts "cost #{Time.now-start} second"
end