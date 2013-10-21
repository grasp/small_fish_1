
require File.expand_path("../raw_process_daily_k.rb",__FILE__)
require File.expand_path("../../../init/config_load.rb",__FILE__)

#依次为开盘，最高，最低，收盘，成交量
#TBD：有几天成交量为0，因为没有开市，需要特殊处理
def volume_analysis(raw_hash)

   #raw_hash=get_raw_data_from_file(symbol)
   raw_array=raw_hash.to_a

   day_array=[] #存储
  

   volume_hash=Hash.new
 

   [1,2,3,4,5,10,20,30,60,100,120].each do |i|
     day_array<<AppSettings.send("volume_#{i}_day")
   end

   #puts  macd_day_array

   raw_array.each_index do |daily_k_index|

   volume_array=[]


   #计算每一日的各个均值
   day_array.each do |number_day|
   	sum=0
   	count=0
   	number_day.downto(1).each do |j|
   		next if daily_k_index+j>raw_array.size-1#忽略
        sum+=raw_array[daily_k_index+j][1][4].to_f
        count+=1
   	end  #end of macd_day sum  
    average_volume=(sum.to_f/count.to_f).round(2)
    volume_array << average_volume
 
   	end #end of one of macd day
   	#puts raw_array[daily_k_index][0]+" "+macd_array.to_s
   	volume_hash[raw_array[daily_k_index][0]]=volume_array

end#end of one day index

volume_hash

end

if $0==__FILE__
	start=Time.now
	raw_hash=get_raw_data_from_file("000009.sz")
	volume_analysis(raw_hash)
	puts "cost #{Time.now-start} second"
end