
require "pathname"
require "json"

lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"init","stock_list_init.rb")
require File.join(lib_path,"yahoo","load_daily_k_to_hash.rb")
require File.join(lib_path,"analysis","K_daily_MACD_analysis.rb")
require File.join(lib_path,"analysis","price_analysis.rb")
require File.join(lib_path,"analysis","volume_analysis.rb")
require File.join(lib_path,"analysis","wave_analysis.rb")
##
#MACD买卖算法测试
# backdays,从现在开始倒数多少个交易日开始来模拟测试
#policy, 还没有想好，感觉应该是一个函数，或者几个函数的组合，实际上就是交易信号
#symbol Yahoo股票代码

#测试一只股票倒数backdays到今天的盈利情况
def back_test_one_stock_with_policy(backdays,policy,symbol,duration)

   #记录买卖点
	buy_hash=Hash.new
	sell_hash=Hash.new

   #记录盈利
	total_win=0
  total_win_percent=0

   #已经买卖的标志
  last_buy_flag=false
  last_sell_flag=true #初始是卖出状态

  #上一次买卖的价格
  last_buy_price=0
  last_sell_price=0
    
  #上一个MACD的差别
  last_macd_diff=0

  #当前最新价格
  latest_price=0
  last_keeped_backday=0

  first_buy_flag=true
  first_buy_price=0

  last_macd_signal=Hash.new #存储昨天的MACD，用来判断买入和卖出

  #获取原始数据
  data_hash = yahoo_get_raw_data_from_file(symbol)
  data_array=data_hash.to_a

  #操作记录Hash
  oper_hash=Hash.new
  oper_hash["start_date"]=data_array[backdays][0] unless  data_array[backdays].nil?
  oper_hash["symbol"]=symbol
  oper_hash["policy_buy"] =policy.to_s
  oper_hash["back_days"] =backdays
  oper_hash["buy_signal"]=0
  oper_hash["buy_action"]=0

  oper_hash["sell_signal"]=0
  oper_hash["sell_action"]=0
  oper_hash["keep_times"]=0

  volume_signal_file=File.new("volume_signal.txt","w+")

  #last_volume_singal=Hash.new
  #$statistic_on_volume_signal=Hash.new{0} if   $statistic_on_volume_signal.nil?
  last_macd_array=[]

  last_price_array=[]
  #
  buy_date=String.new

    win_signal_array=Array.new
    $last_wave_singal=Array.new
  
  #从倒数的那天开始，计算每天的MACD数组，放发生MACD翻转时候，可以作为买卖信号
  backdays.downto(0).each do |back_days|
  next if data_array[backdays].nil? #it is at the end of backdays

  #获取当天的几个基本价格信息
  open_price=data_array[back_days][1][0]||0
  high_price=data_array[back_days][1][1]||0
  low_price=data_array[back_days][1][2]||0
  close_price=data_array[back_days][1][3]||0
  last_price_array= data_array[back_days] if last_price_array.size==0

  #puts "open_price #{open_price},high#{high_price},low_price=#{low_price},close_price#{close_price}"
  
  #记录操作的文件，用于研究和改进操作点
  #oper_record_file = File.new(File.join(Pathname.new(__FILE__).parent.parent,"report","#{symbol}_oper.txt"),"w") #need record on report folder
  return [symbol,0,nil] if data_array.size ==0 #读不出数据来
  return [symbol,0,nil] if data_array.size<backdays #历史数据还不够测试天数，放弃测试

 #最新价格等于开盘价
  latest_price=close_price

 #按照当日均价来成交，那么均线按照最低价来做是否合理呢？
 # todays_price= (data_array[back_days][1][1].to_f+data_array[back_days][1][2].to_f)/2
 #那就按照最低价来操作
  todays_price= close_price.to_f

 
 #获取最低价，最低价策略
 lowest_prince_one_hundred_day=get_lowest_price(data_hash,120,back_days)[0]
 highest_prince_one_hundred_day=get_lowest_price(data_hash,120,back_days)[1]


 #记录当下最新价格，如果交割日不在当日，需要按照交割日算，交割日也是按照当前后退的日子算
  

  #获取当前backday 的K线数组
  macd_array=get_back_days_macd_array(back_days,data_hash,symbol)

  #sell_macd_array=get_back_days_macd_array(back_days,data_hash,symbol)
  #获取买卖信号

  macd_signal=generate_macd_sinal(macd_array)
  #volume_signal=anaylys_volume_signal(data_array,back_days)
  #sell_macd_signal=generate_macd_sinal(sell_macd_array)

  day_100_average_price=get_macd_value(back_days,data_hash,60)
  day_200_average_price=get_macd_value(back_days,data_hash,120)
  day_300_average_price=get_macd_value(back_days,data_hash,240)

  #均价突破信号
  
  average_price_signal=((todays_price.to_f-day_300_average_price.to_f)/todays_price.to_f)<0
  higher_lowerest_percent=((todays_price.to_f-lowest_prince_one_hundred_day.to_f)/lowest_prince_one_hundred_day.to_f) 

  #average_price_signal=(todays_price.to_f-day_300_average_price.to_f)<=0
  #average_price_signal=(todays_price.to_f-day_300_average_price.to_f)/day_300_average_price<=0
  last_average_price_signal=average_price_signal
#wave singal
  wave_signal=get_highest_lowest(data_array,back_days,14)





  #volume_signal=generate_volume_signal(back_days,data_array)

  #这个地方是买点信号
 
  #if calculate_macd_policy(macd_signal,last_macd_signal,policy)

  #  初始化上一次的MACD值
  last_macd_signal= macd_signal if last_macd_signal.nil?

  buy_signal=true

  buy_signal &&=macd_signal["5_days_cross_10_days"]==true
  #||((wave_signal[0]=="highest") && (wave_signal[1]=="lowest")  &&  (wave_signal[2]=="highest") && (wave_signal[3]=="lowest")  &&  (wave_signal[4]=="lowest")
  #buy_signal &&=((wave_signal[0]=="lowest") && (wave_signal[1]=="lowest") && (wave_signal[2]=="highest")&&(wave_signal[3]=="lowest") &&(wave_signal[4]=="highest"))
  #buy_signal &&=((wave_signal[0]=="lowest") && (wave_signal[1]=="lowest") && (wave_signal[2]=="highest")&&(wave_signal[3]=="highest") &&(wave_signal[4]=="lowest"))
  #buy_signal &&=macd_signal["5_days_cross_20_days"]==true

  #remove ST stock
 # buy_signal &&=!$all_stock_list[symbol].match("ST")
  #buy_signal &&=((macd_array[0]-macd_array[1])/macd_array[1].to_f)>0.03
  #buy_signal &&=((macd_array[1]-macd_array[2])/macd_array[2].to_f)<0
  #buy_signal &&=((macd_array[2]-macd_array[3])/macd_array[3].to_f)<0.03
  #buy_signal &&=((macd_array[3]-macd_array[4])/macd_array[4])<0.03
  #buy_signal &&=todays_price.to_f<lowest_prince_one_hundred_day.to_f
  
  #buy_signal &&=((macd_array[0].to_f-lowest_prince_one_hundred_day.to_f)/lowest_prince_one_hundred_day.to_f)>0.1
  #buy_signal &&=((macd_array[0].to_f-lowest_prince_one_hundred_day.to_f)/lowest_prince_one_hundred_day.to_f)<0.3
  #buy_signal &&=((highest_prince_one_hundred_day.to_f-macd_array[0].to_f)/macd_array[0].to_f)>0.3
  # buy_signal &&=((highest_prince_one_hundred_day.to_f-macd_array[0].to_f)/macd_array[0].to_f)<0.1
  #buy_signal &&=((highest_prince_one_hundred_day.to_f-macd_array[0].to_f)/macd_array[0].to_f)<0.6
  #buy_signal &&=((macd_array[0]-lowest_prince_one_hundred_day.to_f)/lowest_prince_one_hundred_day.to_f)<0.02
  #buy_signal &&=macd_array[1]>macd_array[2]
  #buy_signal &&=macd_array[2]>macd_array[3]
  #buy_signal &&=macd_array[0]>macd_array[1]
  #buy_signal &&=(((todays_price.to_f+last_price_array[3].to_f)/2-macd_array[0])/macd_array[0])>0.1 #突破5日均线
    #buy_signal &&=((todays_price.to_f-macd_array[0])/macd_array[0])>0 #突破5日均线
  #buy_signal &&=((todays_price.to_f-macd_array[1])/macd_array[1])>0 #突破10日均线
  #buy_signal &&=((todays_price.to_f-macd_array[2])/macd_array[2])>0 #突破10日均线

  #buy_signal &&=((todays_price.to_f-macd_array[2])/macd_array[2])>0.2 #突破20日均线
  # buy_signal &&=((macd_array[0]-macd_array[2])/macd_array[2])>0.05 #突破20日均线
  #buy_signal &&=todays_price.to_f>macd_array[3] #突破30日均线
  #buy_signal &&=todays_price.to_f>macd_array[4] #突破30日均线
  #buy_signal &&=(macd_array[4]>day_100_average_price)
  #buy_signal &&=(day_100_average_price>day_200_average_price) && (day_100_average_price >day_300_average_price)
#buy_signal &&=(todays_price>=day_100_average_price && todays_price>=day_200_average_price && todays_price>=day_300_average_price  )
  
  #buy_signal &&=todays_price.to_f>macd_array[4] #突破5日均线
  #buy_signal &&=todays_price.to_f<day_300_average_price.to_f

  #高开高走,都不太好使啊
  #buy_signal &&=open_price.to_f>last_price_array[3].to_f
  #buy_signal &&=close_price.to_f>open_price.to_f

   #buy_signal &&=((open_price.to_f-last_price_array[3].to_f)/last_price_array[3].to_f)>0.03
   #buy_signal &&=((close_price.to_f-open_price.to_f)/open_price.to_f)>0.03
  #跳空高开3%
  #buy_signal &&=((open_price.to_f-last_price_array[3].to_f)/last_price_array[3].to_f)>0.03

  #高开低走
  #buy_signal &&=open_price.to_f>last_price_array[3].to_f
  #buy_signal &&=close_price.to_f<open_price.to_f

   #低开高走
  #buy_signal &&=open_price.to_f<last_price_array[3].to_f
  #buy_signal &&=close_price.to_f>open_price.to_f

  #低开低走
  #buy_signal &&=open_price.to_f<last_price_array[3].to_f
  #buy_signal &&=close_price.to_f<open_price.to_f

  #buy_signal &&=macd_signal["10_days_cross_20_days"]==true
  #buy_signal &&=macd_signal["20_days_cross_30_days"]==false
  #buy_signal &&=macd_signal["30_days_cross_60_days"]==false
  #buy_signal &&= last_macd_signal["5_days_cross_10_days"]==false
  #buy_signal &&= last_macd_signal["10_days_cross_20_days"]==false
  #buy_signal &&= last_macd_signal["20_days_cross_30_days"]==false
  #buy_signal &&= last_macd_signal["30_days_cross_60_days"]==false
  #buy_signal &&= (average_price_signal==true)
  
  
  
if buy_signal
#if macd_signal["5_days_cross_10_days"]==true && last_macd_signal["5_days_cross_10_days"]==false #&& todays_price.to_f<=lowest_prince_one_hundred_day.to_f# && average_price_signal==true
#if macd_signal["5_days_cross_10_days"]==true && last_macd_signal["5_days_cross_10_days"]==false && (todays_price.to_f<lowest_prince_one_hundred_day.to_f && average_price_signal==true)
#if macd_signal["5_days_cross_10_days"]==true && last_macd_signal["5_days_cross_10_days"]==false && (average_price_signal==true)

#if macd_signal["5_days_cross_10_days"]==true && last_macd_signal["5_days_cross_10_days"]==false && (average_price_signal==true && last_average_price_signal==false)
#if average_price_signal==true && last_average_price_signal==false
#if macd_signal["5_days_cross_10_days"]==true && last_macd_signal["5_days_cross_10_days"]==false && (macd_array[0].to_f<lowest_prince_one_hundred_day.to_f)
  
  #puts "#{symbol},lowest=#{lowest_prince_one_hundred_day},today=#{todays_price}"


  oper_hash["buy_signal"]+=1

  #买入操作
  #操作记录，何时买进，
  if last_sell_flag==true && last_buy_flag == false  #&& volume_signal==true#确保当下已经卖出股票了，而不是追加投入

    # print wave_signal.to_s+"\n"
     buy_date = data_array[back_days][0]
     oper_hash["buy_action"]+=1

     if first_buy_flag==true
       first_buy_price= todays_price
       first_buy_flag=false
     end

     #oper_hash["buy_"+"#{data_array[back_days][0]}"]=todays_price
     oper_hash["op"]=String.new if oper_hash["op"].nil?
     oper_hash["op"]+="buy_"+"#{buy_date} "+todays_price.to_s+" "
     #oper_hash["op"]+="volume up:"+volume_signal.to_s + " "

    #买入价格
  	 last_buy_price=todays_price
  	 last_buy_flag=true
     last_sell_flag=false

     last_keeped_backday =back_days
    # last_volume_singal=volume_signal
     last_macd_array=macd_array
     $last_wave_singal=wave_signal
    end #end of if last_sell
  end #end of if macd_signal....

   prevent_lost_signal = ((last_buy_price.to_f-data_array[back_days][1][0].to_f)/last_buy_price.to_f) <=(-0.2)

  #这个地方是卖点信号

  sell_signal=true

  #sell_signal &&=todays_price<macd_array[0]
  sell_signal &&=macd_signal["5_days_cross_10_days"]==false
  #sell_signal ||=prevent_lost_signal==true 

  #if (macd_signal["5_days_down_10_days"]==true && last_macd_signal["5_days_down_10_days"] ==false)
   #if (macd_signal["5_days_cross_10_days"]==false && last_macd_signal["5_days_cross_10_days"]==true)  || prevent_lost_signal==true #&& last_macd_signal["10_days_cross_20_days"] ==false
 #if (macd_signal["5_days_cross_10_days"]==false && last_macd_signal["5_days_cross_10_2ays"]==true) 
  #卖出操作
  #统计持仓时间，何时卖出

  if sell_signal
   oper_hash["sell_signal"]+=1
   
  if last_buy_flag==true && last_sell_flag ==false
      oper_hash["sell_action"]+=1
      keep_day=last_keeped_backday-back_days
      oper_hash["keep_times"]+= keep_day
      oper_hash["keep_percent"]=((oper_hash["keep_times"].to_f/backdays)*100).to_s+"%"

      win_profit=todays_price-last_buy_price.to_f
      win_percent=((win_profit.to_f/last_buy_price.to_f)*100).round(3)
       sell_date = data_array[back_days][0]
      #puts "buy_date=#{buy_date},sell_date=#{sell_date},todays_price=#{todays_price},last_buy_price=#{last_buy_price},#{win_percent}"
      total_win_percent+=win_percent.round(3)
 
      total_win+=win_profit
      oper_hash["op"]+="sell_"+"#{sell_date} " + todays_price.to_s + " keep:#{ keep_day} days,"+ "win #{win_percent}%"+"prevent_lost_signal=#{prevent_lost_signal}"+"\n"
     if win_percent>5
     # puts win_percent.to_s+last_volume_singal.to_s
      puts last_macd_array.to_a.to_s+"=#{win_percent}"
      print  $last_wave_singal.to_s+"\n"
      #win_signal_array<<$last_wave_singal
     # volume_signal_file<<last_volume_singal.to_a.to_s+"#{win_percent}"

    # statistic_on_volume_signal(last_volume_singal,$statistic_on_volume_signal)
    # print $statistic_on_volume_signal.to_a.sort
     end
      #利润计算
 
  	 last_buy_flag=false
  	 last_sell_flag=true

  end# end of if last_buy_flag
  end#end of if macd_signal
  #记录上次的数据，用于判断
  last_macd_signal=macd_signal
  last_price_array=data_array[back_days][1]
  last_average_price_signal=average_price_signal

end

#如果当日交割，那么按照这一日来结算利润，TBD
#if last_buy_flag==true
#	total_win+=latest_price.to_f-last_buy_price.to_f
#  total_win_percent+=(((latest_price.to_f-last_buy_price.to_f)/last_buy_price.to_f)*100).round(3)
#end

total_win_percent=total_win_percent.round(3)

oper_hash["policy_buy"]+=",win_percent:#{total_win_percent}%"

puts "#{policy},win_percent=#{total_win_percent.round(2)}%"

oper_hash["total-win"] = total_win.to_s+" "+"_win percent=#{total_win_percent}%,"+"\n"
oper_hash["total_win_percent"]=total_win_percent

win_flag=total_win_percent>0 ? "win" : "lost"
#不记录那些盈利等于0的股票
unless total_win_percent==0
oper_record_file=File.new(File.join("../","report","#{win_flag}_#{total_win_percent.abs.round(0)}_#{symbol}_oper.txt"),"w+")
oper_hash.each do |key,value|
   #unless value.to_s.match("win percent=0%")
	   oper_record_file << "#{key}"+"  "+"#{value}"+"\n"
   #end
end
oper_record_file.close
end

#return [symbol,total_win_percent,last_buy_price.to_f]
volume_signal_file.close

print win_signal_array
#为了产生报告用
return oper_hash

end
#####################################################
#统计多个股票操作的总结果，计算各种失败概率
def win_array_statistic(win_array)
  puts "win_array=#{win_array}"
    win_array_hash = Hash.new
    temp_array=win_array
    temp_array.delete("NaN")
    temp_array.delete(nil)
    total_size=temp_array.size
    puts ">50%=#{temp_array.select {|count| count>50}.size}"
    puts "total_size=#{total_size}"
    loss_total=0
    puts temp_array.select {|count| count >0}.size

    average_win=0
    temp_array.each { |count| average_win+=count}

    win_array_hash["loss_total"]=(((temp_array.select {|count| count <=4}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["loss_100"]=(((temp_array.select {|count| count <=-100}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["loss_50_100"]=(((temp_array.select {|count| count>-100 && count <=-50}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["loss_30_50"]=(((temp_array.select {|count| count>-50 && count <=-30}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["loss_20_30"]=(((temp_array.select {|count| count>-30 && count <=-20}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["loss_10_20"]=(((temp_array.select {|count| count>-20 && count <=-10}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["loss_0_10"]=(((temp_array.select {|count| count>-10 && count <=0}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["win_0_4"]=(((temp_array.select {|count| count>0 && count <=4}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["win_4_10"]=(((temp_array.select {|count| count>4 && count <=10}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["win_10_20"]=(((temp_array.select {|count| count>10 && count <=20}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["win_20_30"]=(((temp_array.select {|count| count>20 && count <=30}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["win_30_50"]=(((temp_array.select {|count| count>30 && count <=50}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
   
    win_array_hash["win_50"]=(((temp_array.select {|count| count>50}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    win_array_hash["win_total"]=(((temp_array.select {|count| count>=4}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
    
    win_array_hash["average_win"]=((average_win.to_f/total_size.to_f)).round(2).to_s+"%"
   #puts temp_array
  # puts "total stock number=#{temp_array.size}"
   win_array_hash.each do |key,value|
     puts "#{key}=#{value}"
   end
  
   return win_array_hash
end


###############################################################
##   选取开始和结束的股票样本，可以控制测试的时间，最长的200天全部测试大约需要40分钟
##
def back_test_multi_stock(start,stop,policy,duration)
 
  win_array=Array.new
  start_time = Time.now

  #记录每一只股票的盈利记录
  root_path=Pathname.new(__FILE__).parent.parent.parent
  win_file=File.new(File.join(root_path,"report","win_list.txt"),"w+")

  count =0

  $all_stock_list.each do |symbol,name|
   if (count >= start && count < stop)
   oper_hash=back_test_one_stock_with_policy(duration,policy,symbol,0)
   #等于0的基本上没有操作条件，所以在统计的时候去掉
   win_array<<  oper_hash["total_win_percent"] unless oper_hash["total_win_percent"]==0.0
   win_file << oper_hash["symbol"]+oper_hash["win_percent"].to_s

  end #end if count>=
   count+=1  
  end  # end of $all_stock_list

  win_file<<policy.to_s 
  win_file <<win_array_statistic(win_array).to_s
   
  win_file.close 
  puts "cost time =#{Time.now - start_time}"
  return win_array
end



##################################################
#below is self test area
if $0==__FILE__

#测试一只股票
#stock_array=["000656.sz","000669.sz","000672.sz","000716.sz","000725.sz","000737.sz","000736.sz"]

#stock_array.each do |stock|
 #   back_test_one_stock_with_policy(250,"",stock,0)
#end

#测试多只股票
back_test_multi_stock(1700,1800,"",60)
end