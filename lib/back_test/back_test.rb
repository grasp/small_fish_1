
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
def back_test_one_stock(backdays,symbol,duration)

   #记录买卖点
	buy_hash=Hash.new
	sell_hash=Hash.new
   #记录盈利
	total_win=0
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

  last_macd_signal=Hash.new #存储昨天的MACD，用来判断买入和卖出

  #操作记录Hash
  oper_hash=Hash.new

  oper_record_file=File.new("#{symbol}_oper.txt","w")

  #从倒数的那天开始，计算每天的MACD数组，放发生MACD翻转时候，可以作为买卖信号
  backdays.downto(0).each do |back_days|
  data_hash = yahoo_get_raw_data_from_file(symbol)
  data_array=data_hash.to_a
  #记录操作的文件，用于研究和改进操作点
  #oper_record_file = File.new(File.join(Pathname.new(__FILE__).parent.parent,"report","#{symbol}_oper.txt"),"w") #need record on report folder
  return [symbol,0,nil] if data_array.size ==0

  latest_price=data_array[0][1][0]||0

 #不处理那些没有K线数据的，下载问题
 

  #记录当下最新价格，如果交割日不在当日，需要按照交割日算，交割日也是按照当前后退的日子算
  

  #获取K线原始数据
  macd_array=get_back_days_macd_array(back_days,data_hash,symbol)

  #获取买卖信号
  macd_signal=generate_macd_sinal(macd_array)
  price_singal=price_signal(data_hash,20)#20 days price signal

  #这个地方是买点信号
  #这个策略只有33%的盈利概率
 #if (macd_signal["5_days_cross_20_days"] ==true && last_macd_signal["5_days_cross_20_days"] ==false && macd_signal["10_days_down_20_days"] ==true &&  macd_signal["20_days_down_30_days"] ==true 	&& macd_signal["30_days_down_60_days"] ==true)

  #这个策略只有22%的盈利概率, 比上面好点
 # if (macd_signal["5_days_cross_10_days"] ==true && last_macd_signal["5_days_down_10_days"] ==false && last_macd_signal["10_days_down_20_days"] ==true &&  last_macd_signal["20_days_down_30_days"] ==true   && last_macd_signal["30_days_down_60_days"] ==true)

  #这个策略只有%的盈利概率, 比上面好点
 #if macd_signal["5_days_cross_10_days"] == true && macd_signal["5_days_cross_20_days"] == true  && macd_signal["5_days_cross_20_days"] == true && macd_signal["5_days_cross_30_days"] == true   && macd_signal["5_days_cross_60_days"] == true && last_macd_signal["5_days_cross_20_days"] == false

 if macd_signal["5_days_cross_10_days"] ==true
 # && macd_signal["5_days_cross_20_days"] ==false\
 # && macd_signal["10_days_cross_20_days"] ==true\
 # && macd_signal["20_days_cross_30_days"] ==true\
 # && last_macd_signal["5_days_down_10_days"] ==true)


 # puts "Buy signal"
  #买入操作
  #操作记录，何时买进，
  if last_sell_flag==true && last_buy_flag == false  #确保当下已经卖出股票了，而不是追加投入

  #  puts "buy now!"
     oper_hash[symbol]=["buy",data_array[back_days][0],data_array[back_days][1][0]]
     oper_record_file << ["buy",data_array[back_days][0],data_array[back_days][1][0]].to_s
  	# buy_hash[data_array[back_days][0]]=data_array[back_days][1][0]
    #买入价格
  	 last_buy_price=data_array[back_days][1][0]
  	 last_buy_flag=true
     last_sell_flag=false
    # puts "last_buy_flag=#{last_buy_flag},last_sell_flag=#{last_sell_flag}"
    end #end of if last_sell
  end #end of if macd_signal....

  #这个地方是卖点信号
  if (macd_signal["5_days_down_10_days"]==true && last_macd_signal["5_days_down_10_days"] ==false)
  # if macd_signal["5_days_down_20_days"]==true && last_macd_signal["5_days_down_20_days"] ==false
  #卖出操作
  #统计持仓时间，何时卖出
 # puts "sell signal"
  if last_buy_flag==true && last_sell_flag ==false
     # puts "sell  now!"
     # oper_hash[symbol]=["sell",data_array[back_days][0],data_array[back_days][1][0]]
      oper_record_file << ["sell",data_array[back_days][0],data_array[back_days][1][0]].to_s
      #利润计算
  		total_win+=data_array[back_days][1][0].to_f-last_buy_price.to_f
  		last_buy_flag=false
  		last_sell_flag=true
     # puts "last_buy_flag=#{last_buy_flag},last_sell_flag=#{last_sell_flag}"
  end# end of if last_buy_flag
  end#end of if macd_signal
  #记录上次的数据，用于判断
  last_macd_signal=macd_signal

end

#如果当日交割，那么按照这一日来结算利润，TBD
if last_buy_flag==true
	total_win+=latest_price.to_f-last_buy_price.to_f
end

oper_record_file << "total-win=#{total_win}"
oper_record_file.close #关闭交易记录文件
puts "#{symbol} done!"
return [symbol,total_win,last_buy_price.to_f]

end
#####################################################
#统计多个股票操作的总结果，计算各种失败概率
def win_array_statistic(win_array)

    win_array_hash = Hash.new
    temp_array=win_array
    temp_array.delete("NaN")
    total_size=temp_array.size
    loss_total=0
    puts temp_array.select {|count| count >0}.size

    win_array_hash["loss_total"]=(((temp_array.select {|count| count <=0}.size)/total_size.to_f).to_f*100).round(2).to_s+"%"
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

   puts temp_array
   puts "total stock number=#{temp_array.size}"
   win_array_hash.each do |key,value|
     puts "#{key}=#{value}"
   end
  
   return win_array_hash
end


###############################################################
##   选取开始和结束的股票样本，可以控制测试的时间，最长的200天全部测试大约需要40分钟
##
def back_test_multi_stock(start,stop)
 
  win_array=Array.new
  start_time = Time.now

  #记录每一只股票的盈利记录
  win_file=File.new("win_list.txt","w")

  count =0


  $all_stock_list.each do |symbol,name|
   if (count >= start && count < stop)
   puts count.to_s + "_" + symbol

   result=back_test_one_stock(60,symbol,0)

   next if (result[2]==0 || result[1].nil? || result[2].nil?)   
   percent=((result[1]/result[2])*100).to_f.round(2)

   win_array<<  percent 
   win_file << result[0].to_s+ " " + percent.to_s+"\r\n"

  end #end if count>=
   count+=1
  
  end  # end of $all_stock_list
  win_file.close 

   
  #统计盈利分布
  win_array_statistic(win_array)

  puts "cost time =#{Time.now - start_time}"
  return win_array
end

##################################################
#below is self test area
if $0==__FILE__

#back_test_all_stock

#test_win_array=[-200,-100,-90,-80,-70,-60,-50,-40,-30,-20,-10,-5,-3,-2,-1,0,1,2,3,10,20,30,40,50,60,70,80,90,100,200,300]
#win_array_statistic(test_win_array)

back_test_multi_stock(1030,1050)
end