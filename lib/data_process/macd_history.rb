
require File.expand_path("../raw_process_daily_k.rb",__FILE__)
require File.expand_path("../../../init/config_load.rb",__FILE__)

#依次为开盘，最高，最低，收盘，成交量
def generate_one_stock_macd(raw_hash)

   #raw_hash=get_raw_data_from_file(symbol)
   raw_array=raw_hash.to_a
   macd_day_array=[]
   result_macd_hash=Hash.new
   price_hash=Hash.new


   [1,2,3,4,5,10,20,30,60,100,120].each do |i|
     macd_day_array<<AppSettings.send("macd_#{i}_day")
   end

   #puts  macd_day_array

   raw_array.each_index do |daily_k_index|

    macd_array=[]
    #保存价格信息
   price_hash[raw_array[daily_k_index][0]]=raw_array[daily_k_index][1]
  
   #计算每一日的各个均值
   macd_day_array.each do |macd_day|
   sum=0
   #算术求和
    real_day_count=0
   	macd_day.downto(1).each do |j|
   		next if daily_k_index+j>raw_array.size-1#忽略
   		new_index=daily_k_index+j
        sum+=raw_array[daily_k_index+j][1][3].to_f
        real_day_count+=1
   	end  #end of macd_day sum  

   	average=(sum.to_f/real_day_count.to_f).round(2)
   	macd_array<<average
 
   	end #end of one of macd day
   	#puts raw_array[daily_k_index][0]+" "+macd_array.to_s
   	result_macd_hash[raw_array[daily_k_index][0]]=macd_array.to_s #unless macd_array[0]== "NaN"
end#end of one day index

[result_macd_hash,price_hash]
end

if $0==__FILE__
	start=Time.now
  raw_hash=get_raw_data_from_file("000009.sz")
	generate_one_stock_macd(raw_hash)
	puts "cost #{Time.now-start} second"
end