
#  这个文件里，我们想实现的是，可以模拟验证某一个时间区间操作策略的的操作结果

require "pathname"
require "json"

lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"init","stock_list_init.rb")
require File.join(lib_path,"yahoo","load_daily_k_to_hash.rb")
require File.join(lib_path,"back_test","policy.rb")
require File.join(lib_path,"analysis","K_daily_MACD_analysis.rb")
require File.join(lib_path,"analysis","price_analysis.rb")

def get_today_buy_list

  today=Time.now.to_s[0,10]

end


#计算day1和day2相差的天数，可以得到我们的backdays， 为计算某个区间的盈利测试
def get_diff_day(day1,day2)

	day_array1=day1.split("-")	
	day1_time= Time.new(day_array1[0],day_array1[1],day_array1[2])

	day_array2=day2.split("-")
	day2_time= Time.new(day_array2[0],day_array2[1],day_array2[2])
	
    diff_time=day2_time-day1_time

    puts (diff_time/(60*60*24)).to_i
    
end

# 从原始数据中获取Hash列表，key 日期数据， value为一个数组， #开盘，最高，最低，收盘，成交量
#{"2013-10-02"=>["13.67", "13.67", "13.67", "13.67", "000", "13.67"], "2013-10-01"=>["13.67", "13.67", "13.67", "13.67", "000", "13.67"],
def daily_k_get_one_stock_raw_hash(symbol)
	data_hash = yahoo_get_raw_data_from_file(symbol)
	return  data_hash
end

def daily_k_get_one_stock_raw_array(symbol)
	data_hash = yahoo_get_raw_data_from_file(symbol)
	data_array=data_hash.to_a
	return  data_array
end

def get_day_index(raw_data_array,day)
	raw_data_array.each_index do |index|
		return index if raw_data_array[index][0]==day
	end

	return nil

end

#获取某一日的MACD均线值
#day的格式必须为20120101这种形式的字符串
def get_macd_on_day(raw_data_hash,back_day,duration_days)
    
  data_array = raw_data_hash.to_a
 # average_price_array=Array.new
  return [] if data_array.size ==0
  sum=0.0
  average_price=0.0
  last_price=[[0],[0],[0],[0],[0]]
  #把最新日期改为，后退的几天，这样可以知道后退天的MACD盘口信息
  back_day.upto(duration_days+back_day-1).each do |j|
     data_array[j] = last_price if data_array[j].nil? #if no data coming, then use the last one
     open_price=data_array[j][1][0]||0
     close_price=data_array[j][1][3]||0
  	# sum+=((open_price.to_f+close_price.to_f)/2).to_f.round(2) 
    #sum+=(close_price.to_f).to_f.round(2) 
    sum+=(open_price.to_f).to_f.round(2)     	
    last_price = data_array[j]
end
 average_price=(sum/duration_days).round(2) #注意，我们的均价为算数平均值，这个暂时这样了
# average_price_array<<average_price
#返回均价数组
return average_price
end

##
#获得后退天的，一个5日，10日，20日，30日，60日价格均值的数组
#这个应该作为信号的输入源头
#用6日均线和12日均线，能够获得很理想的结果
def get_macd_array(raw_data_hash,back_day)

   return [] if raw_data_hash.size ==0 #to avoid 
   current_macd_array=Array.new
   current_macd_array<<get_macd_on_day(raw_data_hash,back_day,6)
   current_macd_array<<get_macd_on_day(raw_data_hash,back_day,12)
   current_macd_array<<get_macd_on_day(raw_data_hash,back_day,20)
   current_macd_array<<get_macd_on_day(raw_data_hash,back_day,30)
   current_macd_array<<get_macd_on_day(raw_data_hash,back_day,60)
   return current_macd_array
end

def generate_macd_sinal(macd_array)

  macd_signal_hash=Hash.new{false}
  macd_signal_hash["5_days_cross_10_days"] =true if macd_array[0] > macd_array[1]
  macd_signal_hash["5_days_cross_20_days"] =true if macd_array[0] > macd_array[2]
  macd_signal_hash["5_days_cross_30_days"] =true if macd_array[0] > macd_array[3]
  macd_signal_hash["5_days_cross_60_days"] =true if macd_array[0]> macd_array[4]
  macd_signal_hash["10_days_cross_20_days"] =true if macd_array[1]> macd_array[2]
  macd_signal_hash["10_days_cross_30_days"] =true if macd_array[1]> macd_array[3]
  macd_signal_hash["10_days_cross_60_days"] =true if macd_array[1]> macd_array[4]
  macd_signal_hash["20_days_cross_30_days"] =true if macd_array[2]> macd_array[3]
  macd_signal_hash["20_days_cross_60_days"] =true if macd_array[2]> macd_array[4]
  macd_signal_hash["30_days_cross_60_days"] =true if macd_array[3]> macd_array[4]
  #macd_signal_hash["5_days_down_10_days"] =true if macd_array[0]<= macd_array[1]
  #macd_signal_hash["5_days_down_20_days"] =true if macd_array[0]<= macd_array[2]
  #macd_signal_hash["5_days_down_30_days"] =true if macd_array[0]<= macd_array[3]
  #macd_signal_hash["5_days_down_60_days"] =true if macd_array[0]<= macd_array[4]
  #macd_signal_hash["10_days_down_20_days"] =true if macd_array[1]<= macd_array[2]
  #macd_signal_hash["10_days_down_30_days"] =true if macd_array[1]<= macd_array[3]
  #macd_signal_hash["10_days_down_60_days"] =true if macd_array[1]<= macd_array[4]
  #macd_signal_hash["20_days_down_30_days"] =true if macd_array[2]<= macd_array[3]
  #macd_signal_hash["20_days_down_60_days"] =true if macd_array[2]<= macd_array[4]
  #macd_signal_hash["30_days_down_60_days"] =true if macd_array[3]<= macd_array[4]

return  macd_signal_hash
end

#计算这一天是否可以买入
#today,previous_day，这两个的格式必须要为2012-09-09这种格式
def get_buy_signal_on_day(raw_data_hash,today,previous_day)
 	current_macd_array=get_macd_array(raw_data_hash,today)
    previous_macd_array=get_macd_array(raw_data_hash,previous_day)

   # puts "diff=#{current_macd_array[0]-previous_macd_array[1]}" 
    current_macd_singal_hash=generate_macd_sinal(current_macd_array)
    previous_macd_signal= generate_macd_sinal(previous_macd_array)

    #lowest price in 120 day
    lowest_price=get_lowest_price(raw_data_hash,60)
    today_price=raw_data_hash[today][3].to_f

    #突破300天均价
    over_300_days=get_macd_on_day(raw_data_hash,today,300)

    #return macd_singal_hash["5_days_cross_10_days"]==true #&& raw_data_hash[day][3].to_f<lowest_price.to_f
    signal = current_macd_singal_hash["5_days_cross_10_days"]==true
    signal &&= previous_macd_signal["5_days_cross_10_days"]==false
    signal &&=(today_price.to_f<=lowest_price.to_f)
    signal &&=(today_price.to_f<over_300_days.to_f)
    #if signal==true
  	   #puts "diff=#{current_macd_array[0]-current_macd_array[1]}" 
    #end
    return signal
end

#计算这一天是否可以卖出
def get_sell_signal_on_day(raw_data_hash,today,previous_day)

 	current_macd_array=get_macd_array(raw_data_hash,today)
    previous_macd_array=get_macd_array(raw_data_hash,previous_day)

    current_macd_singal_hash=generate_macd_sinal(current_macd_array)
    previous_macd_signal= generate_macd_sinal(previous_macd_array)

    #lowest price in 120 day
    #lowest_price=get_lowest_price(raw_data_hash,120)

    #return macd_singal_hash["5_days_cross_10_days"]==true #&& raw_data_hash[day][3].to_f<lowest_price.to_f
   
    return current_macd_singal_hash["5_days_cross_10_days"]==false && previous_macd_signal["5_days_cross_10_days"]==true
end

#模拟和打印所有的买入和卖出点
def simulate_buy_and_sell(day,back_days,symbol)
    
    raw_data_hash=daily_k_get_one_stock_raw_hash(symbol)
    raw_data_array=raw_data_hash.to_a

    # first_day_index,最新的一天
    first_day_index=get_day_index(raw_data_array,day)
    #last_day_index，最后的一天
    last_day_index=first_day_index+back_days
   
    #first_day_index274,last_day_index=474
    #puts "first_day_index#{first_day_index},last_day_index=#{last_day_index}"

    buy_flag=false
    sell_flag=true

    buy_price=0.0
    sell_price=0.0

    last_buy_price=0

    buy_index=0

    op_record=Array.new
    one_buy_sell_record=Hash.new

    last_day_index.downto(first_day_index) do |i| 
      
      that_day=raw_data_array[i][0]
      previous_that_day=raw_data_array[i+1][0]

      if get_buy_signal_on_day(raw_data_hash,that_day,previous_that_day)==true && sell_flag==true && buy_flag==false
      
     	#puts "buy on #{that_day} with price=#{raw_data_hash[that_day][3]}"
        buy_flag=true
        sell_flag=false
        one_buy_sell_record["buy_date"]=that_day
        one_buy_sell_record["buy_price"]=(raw_data_hash[that_day][3].to_f+0.01).round(2)#买入价为收盘价加1分
        buy_index= i
        last_buy_price= one_buy_sell_record["buy_price"]
      end

  #设置止损位
      prevent_lost=(raw_data_hash[that_day][3].to_f-last_buy_price.to_f) <-0.05

      if (get_sell_signal_on_day(raw_data_hash,that_day,previous_that_day)==true || prevent_lost) && sell_flag==false && buy_flag==true
     	#puts "sell on #{that_day} with price=#{raw_data_hash[that_day][3]}"
     	buy_flag=false
        sell_flag=true
        one_buy_sell_record["sell_date"]=that_day
        one_buy_sell_record["sell_price"]=(raw_data_hash[that_day][3].to_f-0.01).round(2)#卖出价为收盘价加1分
        one_buy_sell_record["profit"]=one_buy_sell_record["sell_price"].to_f.round(2)-one_buy_sell_record["buy_price"].to_f.round(2)
        one_buy_sell_record["percent"]=((one_buy_sell_record["profit"]/one_buy_sell_record["buy_price"].to_f)*100).to_f.round(2)
        one_buy_sell_record["hold_time"]=buy_index-i
        op_record << one_buy_sell_record #卖掉的时候记录交易记录
         one_buy_sell_record=Hash.new#re init
         last_buy_price=0
      end

      #如果没有卖掉，按照最后一日的价格交割,目前选择不结算，这样算利润合理一点
      #if i==0 && sell_flag==false&& buy_flag==true
      #	one_buy_sell_record["sell_date"]=that_day
      #  one_buy_sell_record["sell_price"]=(raw_data_hash[that_day][3].to_f-0.01).round(2)#卖出价为收盘价加1分
      #  one_buy_sell_record["profit"]=one_buy_sell_record["sell_price"].to_f.round(2)-one_buy_sell_record["buy_price"].to_f.round(2)
      #  one_buy_sell_record["percent"]=((one_buy_sell_record["profit"]/one_buy_sell_record["buy_price"].to_f)*100).to_f.round(2)
      #  one_buy_sell_record["hold_time"]=buy_index-i
      #  op_record << one_buy_sell_record #卖掉的时候记录交易记录
      #end
      end

      #如果没有卖掉的话

      return op_record
   end
 #可以用于打印或者写入文件
 def report_op_record(op_record)
 	return if op_record.size==0
 	#puts op_record
 	total_win_pecent=0
 	op_record.each do |one_buy_sell_record|
 		puts "#{one_buy_sell_record["buy_date"]} #{one_buy_sell_record["buy_price"]}/#{one_buy_sell_record["sell_date"]} #{one_buy_sell_record["sell_price"]}, hold=#{one_buy_sell_record["hold_time"]} day,profit= #{one_buy_sell_record["percent"]}%"
 	total_win_pecent+=one_buy_sell_record["percent"]
 	end
  puts "total win=#{total_win_pecent.round(1)}%"
 end


if $0==__FILE__
#get_diff_day("2012-10-8",Time.now.to_s[0,10])

#print daily_k_get_one_stock_raw_hash("601566.ss")
#raw_data_array=daily_k_get_one_stock_raw_array("601566.ss")

#get_macd_on_day(raw_data_array,"2013-06-05",5,"601566.ss")
start=Time.now
report_op_record(simulate_buy_and_sell("2013-07-30",300,"000014.sz"))
puts "cost time=#{Time.now-start}"

end
