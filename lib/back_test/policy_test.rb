
require "pathname"
require "json"

lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"init","stock_list_init.rb")
require File.join(lib_path,"yahoo","load_daily_k_to_hash.rb")
require File.join(lib_path,"back_test","policy.rb")
require File.join(lib_path,"analysis","K_daily_MACD_analysis.rb")
require File.join(lib_path,"analysis","price_analysis.rb")


##
#MACD买卖算法测试
# backdays,从现在开始倒数多少个交易日开始来模拟测试
#policy, 还没有想好，感觉应该是一个函数，或者几个函数的组合，实际上就是交易信号
#symbol Yahoo股票代码

#
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

#get data array from hash
  data_hash = yahoo_get_raw_data_from_file(symbol)
  data_array=data_hash.to_a

  #操作记录Hash
  oper_hash=Hash.new
  oper_hash["start_date"]=data_array[backdays][0] unless  data_array[backdays].nil?
  oper_hash["policy_buy"] =policy.to_s
  oper_hash["back_days"] =backdays
  oper_hash["buy_signal"]=0
  oper_hash["buy_action"]=0

  oper_hash["sell_signal"]=0
  oper_hash["sell_action"]=0
  oper_hash["keep_times"]=0
  #
  buy_date=String.new
  
  #从倒数的那天开始，计算每天的MACD数组，放发生MACD翻转时候，可以作为买卖信号
  backdays.downto(0).each do |back_days|
  next if data_array[backdays].nil? #it is at the end of backdays
  #puts data_array[back_days][1]
  open_price=data_array[back_days][1][0]||0
  high_price=data_array[back_days][1][1]||0
  low_price=data_array[back_days][1][2]||0
  close_price=data_array[back_days][1][3]||0

  #puts "open_price #{open_price},high#{high_price},low_price=#{low_price},close_price#{close_price}"
  #记录操作的文件，用于研究和改进操作点
  #oper_record_file = File.new(File.join(Pathname.new(__FILE__).parent.parent,"report","#{symbol}_oper.txt"),"w") #need record on report folder
  return [symbol,0,nil] if data_array.size ==0
  return [symbol,0,nil] if data_array.size<backdays

  latest_price=open_price
  #按照当日均价来成交，那么均线按照最低价来做是否合理呢？
 # todays_price= (data_array[back_days][1][1].to_f+data_array[back_days][1][2].to_f)/2
 #那就按照最低价来操作
  todays_price= open_price.to_f
 #不处理那些没有K线数据的，下载问题
 
 #最低价策略
 lowest_prince_one_hundred_day=get_lowest_price(data_hash,120)

  #记录当下最新价格，如果交割日不在当日，需要按照交割日算，交割日也是按照当前后退的日子算
  

  #获取K线原始数据
  buy_macd_array=buy_get_back_days_macd_array(back_days,data_hash,symbol)
  sell_macd_array=sell_get_back_days_macd_array(back_days,data_hash,symbol)
  #获取买卖信号
  buy_macd_signal=generate_macd_sinal(buy_macd_array)
  sell_macd_signal=generate_macd_sinal(sell_macd_array)

  price_singal=price_signal(data_hash,20)#20 days price signal
  volume_signal=generate_volume_signal(back_days,data_array)
  #这个地方是买点信号
 # puts " current=#{macd_signal["5_days_cross_10_days"]},last=#{last_macd_signal["5_days_cross_10_days"]},result=#{ macd_signal["5_days_cross_10_days"] && last_macd_signal["5_days_cross_10_days"]}"
  
 # if macd_signal["5_days_cross_10_days"]==true && last_macd_signal["5_days_cross_10_days"]==false
   #if calculate_macd_policy(macd_signal,last_macd_signal,policy)

if buy_macd_signal["5_days_cross_10_days"]==true && todays_price.to_f<lowest_prince_one_hundred_day.to_f
  #print macd_signal.to_s+"\n"
  #print "macd_array=#{macd_array}"+"\n"


  oper_hash["buy_signal"]+=1

  #买入操作
  #操作记录，何时买进，
  if last_sell_flag==true && last_buy_flag == false  #&& volume_signal==true#确保当下已经卖出股票了，而不是追加投入
 
  #print "macd_array=#{macd_array}"+"\n"
     buy_date = data_array[back_days][0]
     oper_hash["buy_action"]+=1
     if first_buy_flag==true
     first_buy_price= todays_price
     first_buy_flag=false
     end
     #oper_hash["buy_"+"#{data_array[back_days][0]}"]=todays_price
     oper_hash["op"]=String.new if oper_hash["op"].nil?
     oper_hash["op"]+="buy_"+"#{buy_date} "+todays_price.to_s+" "
     #oper_hash["op"]+=generate_panzheng_signal(back_days,data_array).to_s+" "
     oper_hash["op"]+="volume up:"+volume_signal.to_s + " "



    #买入价格
  	 last_buy_price=todays_price
  	 last_buy_flag=true
     last_sell_flag=false

     last_keeped_backday =back_days
    end #end of if last_sell
  end #end of if macd_signal....

   prevent_lost_signal = ((last_buy_price.to_f-data_array[back_days][1][0].to_f)/last_buy_price.to_f) <=(-0.05)
  #这个地方是卖点信号
  #if (macd_signal["5_days_down_10_days"]==true && last_macd_signal["5_days_down_10_days"] ==false)
   if sell_macd_signal["5_days_down_10_days"]==true  || prevent_lost_signal==true #&& last_macd_signal["10_days_cross_20_days"] ==false
  #卖出操作
  #统计持仓时间，何时卖出
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

      #oper_hash[symbol]=["sell",data_array[back_days][0],data_array[back_days][1][0]]
     # oper_hash["sell_"+"#{data_array[back_days][0]}"]=data_array[back_days][1][0]+" keep:#{ keep_day} days,"+"win_percent #{win_percent}"
       oper_hash["op"]+="sell_"+"#{sell_date} " + todays_price.to_s + " keep:#{ keep_day} days,"+ "win #{win_percent}%"+"prevent_lost_signal=#{prevent_lost_signal}"+"\n"
       #oper_hash["op"]+=generate_panzheng_signal(back_days,data_array).to_s+"\n"
  oper_hash["win_percent"]=win_percent

      #利润计算
 
  	 last_buy_flag=false
  	 last_sell_flag=true

  end# end of if last_buy_flag
  end#end of if macd_signal
  #记录上次的数据，用于判断
  last_macd_signal=buy_macd_signal

end

#如果当日交割，那么按照这一日来结算利润，TBD
if last_buy_flag==true
	total_win+=latest_price.to_f-last_buy_price.to_f
  total_win_percent+=(((latest_price.to_f-last_buy_price.to_f)/last_buy_price.to_f)*100).round(3)
end

total_win_percent=total_win_percent.round(3)
oper_hash["policy_buy"]+=",win_percent:#{total_win_percent}%"
mark=String.new

if total_win_percent<=0
mark=":("*10
elsif total_win_percent>0 && total_win_percent<10
mark=""
elsif total_win_percent>=10 && total_win_percent<20
mark="**"*10
elsif total_win_percent>=20 && total_win_percent<30
mark="**"*20
elsif total_win_percent>=30
mark=":-)"*30
end

puts "#{policy},win_percent=#{total_win_percent.round(2)}%"
oper_hash["total-win"] = total_win.to_s+" "+"_win percent=#{total_win_percent}%,"+mark+"\n"

#if false
oper_record_file=File.new(File.join("../","policy","#{symbol}_oper.txt"),"w+")
oper_hash.each do |key,value|
   unless value.to_s.match("win percent=0%")
	   oper_record_file << "#{key}"+"  "+"#{value}"+"\n"
   end
end
oper_record_file.close
#end
#puts "#{symbol} done!"
return [symbol,total_win_percent,last_buy_price.to_f]

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
def back_test_multi_stock(start,stop,policy)
 
  win_array=Array.new
  start_time = Time.now

  #记录每一只股票的盈利记录
  win_file=File.new("win_list.txt","a+")

  count =0


  $all_stock_list.each do |symbol,name|
   if (count >= start && count < stop)
   #puts count.to_s + "_" + symbol

   result=back_test_one_stock_with_policy(60,policy,symbol,0)

   next if (result[2]==0 || result[1].nil? || result[2].nil?)   
   #percent=((result[1]/result[2])*100).to_f.round(2)

   win_array<<  result[1]
   win_file << result[0].to_s+ " " + result[1].to_s+"\r\n"

  end #end if count>=
   count+=1
  
  end  # end of $all_stock_list

  win_file<<policy.to_s
 
  win_file<<win_array_statistic(win_array).to_s
   
  #统计盈利分布
  #win_array_statistic(win_array)
  win_file.close 
  puts "cost time =#{Time.now - start_time}"
  return win_array
end


def test_one_stock
policy_array=Array.new

#policy_array << [["5_days_cross_10_days"=>true],[]]
policy_array << [["5_days_cross_10_days"=>true,"10_days_cross_20_days"=>true,"20_days_cross_30_days"=>true,"30_days_cross_60_days"=>true],[]] #这个目前最好了

#上穿10日均线，第一个开叉信号
#policy_array << [["5_days_cross_10_days"=>true],["5_days_cross_10_days"=>false]]
#上穿20日均线-失败
#policy_array << [["5_days_cross_20_days"=>true],["5_days_cross_20_days"=>false]]
#上穿30日均线-失败
#policy_array << [["5_days_cross_30_days"=>true],["5_days_cross_30_days"=>false]]
#上穿60日均线-失败
#policy_array << [["5_days_cross_60_days"=>true],["5_days_cross_60_days"=>false]]
#10日线穿20日线的时候
#policy_array << [["5_days_cross_10_days"=>true,"10_days_cross_20_days"=>true],[]]

#第三个开叉的时候，更安全，买点少
#policy_array << [["5_days_cross_10_days"=>true,"10_days_cross_20_days"=>true,"20_days_cross_30_days"=>true],[]]

stock_array=["000656.sz","000669.sz","000672.sz","000716.sz","000725.sz","000737.sz","000736.sz"]
#stock_array=["000656.sz"]
stock_array.each do |stock|
	puts stock
policy_array.each do |policy|
  back_test_one_stock_with_policy(250,policy,stock,0)
end
end
end

def test_multi_stock
policy_array=Array.new

policy_array << [["5_days_cross_10_days"=>true],[]] #这个目前最好了
#policy_array << [["5_days_cross_10_days"=>true,"10_days_cross_20_days"=>true,"20_days_cross_30_days"=>true,"30_days_cross_60_days"=>true],[]] #这个目前最好了
#policy_array << [["5_days_cross_10_days"=>true],["5_days_cross_10_days"=>false]]
#policy_array << [["5_days_cross_20_days"=>true],["5_days_cross_20_days"=>false]]
#policy_array << [["5_days_cross_10_days"=>true,"20_days_down_30_days"=>true],[]]
#第三个开叉的时候，更安全，买点少
#policy_array << [["5_days_cross_10_days"=>true,"10_days_cross_20_days"=>true,"20_days_cross_30_days"=>true],[]]
#全部开叉的时候，更安全，买点少
#policy_array << [["5_days_cross_10_days"=>true,"10_days_cross_20_days"=>true,"20_days_cross_30_days"=>true,"30_days_cross_60_days"=>true],[]]


policy_array.each do |policy|
	back_test_multi_stock(732,832,policy)
end
end

##################################################
#below is self test area
if $0==__FILE__
#test_one_stock
test_multi_stock
end