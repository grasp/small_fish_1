
require "pathname"
require "json"
lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"init","stock_list_init.rb")
require File.join(lib_path,"yahoo","load_daily_k_to_hash.rb")
require File.join(lib_path,"policy","policy.rb")
require File.join(lib_path,"analysis","K_daily_MACD_analysis.rb")
require File.join(lib_path,"analysis","price_analysis.rb")


##
#MACD买卖算法测试
# backdays,从现在开始倒数多少个交易日开始来模拟测试
#policy, 还没有想好，感觉应该是一个函数，或者几个函数的组合，实际上就是交易信号
#symbol Yahoo股票代码

#
def back_test(backdays,policy,symbol)

   #记录买卖点
	buy_hash=Hash.new
	sell_hash=Hash.new
   #记录盈利
	total_win=0
   #已经买卖的标志
	last_buy_flag=false
    last_sell_flag=true

   #上一次买卖的价格
    last_buy_price=0
    last_sell_price=0
    
    #上一个MACD的差别
    last_macd_diff=0

    #当前最新价格
    latest_price=0

   last_macd_signal=Hash.new

 #从倒数的那天开始，计算每天的MACD数组，放发生MACD翻转时候，可以作为买卖信号
  backdays.downto(0).each do |back_days|
  data_hash = yahoo_get_raw_data_from_file(symbol)
  data_array=data_hash.to_a

  latest_price=data_array[0][1][0]
  #get_macd_array(data_hash,100,60)
  macd_array=get_back_days_macd_array(back_days,data_hash,symbol)

  #获取买卖信号
  macd_signal=generate_macd_sinal(macd_array)
  price_singal=price_signal(data_hash,20)#20 days price signal

 if macd_signal["5_days_cross_20_days"] ==true && last_macd_signal["5_days_cross_20_days"] ==false \
 	&& macd_signal["10_days_down_20_days"] ==true &&  macd_signal["20_days_down_30_days"] ==true \
 	&& macd_signal["30_days_down_60_days"] ==true
  #	if (macd_diff_array[0]+macd_diff_array[1]+macd_diff_array[2] >0 && macd_diff_array[3]<0)  	
 	
  	if last_sell_flag==true
  	 buy_hash[data_array[back_days][0]]=data_array[back_days][1][0]
  	 last_buy_price=data_array[back_days][1][0]
  	 last_buy_flag=true
    end
  end


  if macd_signal["5_days_down_10_days"]==true && last_macd_signal["5_days_down_10_days"] ==false
     #puts 	data_array[back_days][0]
  	
   	if last_buy_flag==true
  		sell_hash[data_array[back_days][0]]=data_array[back_days][1][0]
  		total_win+=data_array[back_days][1][0].to_f-last_buy_price.to_f
  		last_buy_flag==false
  		last_sell_flag=true
  	end

  end

    last_macd_signal=macd_signal

end

#puts buy_hash
#puts sell_hash

if last_buy_flag==true
	total_win+=latest_price.to_f-last_buy_price.to_f
end

#puts "total_win=#{total_win}"
 return [symbol,total_win,last_buy_price.to_f]
end

if $0==__FILE__

	win_array=Array.new
	win_hash=Hash.new
    start = Time.now
    win_file=File.new("win_list.txt","w")
    count =0
    $all_stock_list.each do |symbol,name|
	# result=back_test(60,"","000031.sz")
	count+=1
if count >600 && count <620
 puts count
	 result=back_test(200,"",symbol)

    percent=((result[1]/result[2])*100).to_f.round(2).to_f
	 unless result[2]==0
	   win_array<<  percent 

	   win_hash[symbol]=percent
      end
	 win_file << result[0].to_s+ " " + ((result[1]/result[2])*100).to_f.round(2).to_s+"\r\n"
	end
end
	win_file.close

	puts "cost Time =#{Time.now - start}"
	print   win_array.sort.to_s+"\n"
	print win_hash.to_s+"\n"

	win_count=0
	win_array.each do |item|
      if item.to_f >3.5
      	win_count+=1
      end
	end
	puts "win chance =#{(win_count.to_f/win_array.size).to_f.round(2)*100}%"

end