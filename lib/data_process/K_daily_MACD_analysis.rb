require "pathname"
require "json"
lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"yahoo","load_daily_k_to_hash.rb")
##
#durartion-means  how many days of to be average
#array_size, how long for this statistic
#data_hash, the original raw data to hash , key is date, and value is an array
#返回一个数组，数组里面是一个长度为array_size，计算druation个日子的均差
#作用：这个数组可以用来判断当前股票大的状态：上升，盘整，下降

#计算 back_day那天的MACD均值
def get_macd_value(back_day,data_hash,duration)
  
  data_array = data_hash.to_a
 # average_price_array=Array.new
  return [] if data_array.size ==0
  sum=0.0
  average_price=0.0
  last_price=[[0],[0],[0],[0],[0]]
  #把最新日期改为，后退的几天，这样可以知道后退天的MACD盘口信息
  back_day.upto(duration+back_day-1).each do |j|
     data_array[j] = last_price if data_array[j].nil? #if no data coming, then use the last one
     open_price=data_array[j][1][0]||0
     close_price=data_array[j][1][3]||0
  	# sum+=((open_price.to_f+close_price.to_f)/2).to_f.round(2) 
    #sum+=(close_price.to_f).to_f.round(2) 
    sum+=(open_price.to_f).to_f.round(2)     	
    last_price = data_array[j]
end
 average_price=(sum/duration).round(2) #注意，我们的均价为算数平均值，这个暂时这样了
# average_price_array<<average_price
#返回均价数组
return average_price

end
##
#获得后退天的，一个5日，10日，20日，30日，60日价格均值的数组
#这个应该作为信号的输入源头
#用6日均线和12日均线，能够获得很理想的结果
def get_back_days_macd_array(back_days,data_hash,symbol)

  return [] if data_hash.size ==0 #to avoid 
   current_macd_array=Array.new


   #current_macd_array<<get_macd_value(back_days,data_hash,3)
   #current_macd_array<<get_macd_value(back_days,data_hash,7)

   current_macd_array<<get_macd_value(back_days,data_hash,6)
   current_macd_array<<get_macd_value(back_days,data_hash,12)

   current_macd_array<<get_macd_value(back_days,data_hash,20)
   current_macd_array<<get_macd_value(back_days,data_hash,30)
   current_macd_array<<get_macd_value(back_days,data_hash,60)

   #current_macd_array<<get_macd_value(back_days,data_hash,6)
   #current_macd_array<<get_macd_value(back_days,data_hash,12)
   #current_macd_array<<get_macd_value(back_days,data_hash,24)
   #current_macd_array<<get_macd_value(back_days,data_hash,48)
   #current_macd_array<<get_macd_value(back_days,data_hash,100)

   #print  current_macd_array
   return current_macd_array

end


def get_average_volume(back_day,data_array,array_size)
  average_volume=0.0
  back_day.upto(array_size+back_day-1).each do |j|
  average_volume+= data_array[j][1][4].to_f.round(2)

 end
 return average_volume/array_size
end

def generate_volume_signal(back_day,data_array)
  one_days_avg_volume=get_average_volume(back_day,data_array,1)
  two_days_avg_volume=get_average_volume(back_day,data_array,2)

  five_days_avg_volume=get_average_volume(back_day,data_array,5)
  ten_days_avg_volume=get_average_volume(back_day,data_array,10)
  tweety_days_avg_volume=get_average_volume(back_day,data_array,20)
  thirty_days_avg_volume=get_average_volume(back_day,data_array,30)
  sixty_days_avg_volume=get_average_volume(back_day,data_array,60)
  #diff= five_days_avg_volume-ten_days_avg_volume
  #percent=(diff.to_f/ten_days_avg_volume.to_f)
  #return  (ten_days_avg_volume < tweety_days_avg_volume) &&  (five_days_avg_volume > ten_days_avg_volume) && (tweety_days_avg_volume < five_days_avg_volume)
  #return tweety_days_avg_volume > thirty_days_avg_volume
  return one_days_avg_volume > five_days_avg_volume
end


##
#判断是否为盘整状态,价格变化
#
def get_zhenfu_state(back_day,data_hash,array_size)
 
  macd_array=get_macd_array(back_day,data_hash,array_size,5)
  diff=macd_array.sort.reverse[0].to_f.round(2)-macd_array.sort[0].to_f.round(2)
  average=((macd_array.sort.reverse[0]+macd_array.sort[0])/2).to_f.round(2)
  return (diff/average).to_f.round(2)*100
  
  #应该用积分算法，算面积是比较好的，用最高价和最低价判断比较低级
end

def generate_panzheng_signal(back_day,data_hash)
    panzhen_signal_hash=Hash.new{false}
    diff=get_zhenfu_state(back_day,data_hash,5)
    panzhen_signal_hash["5days_0_5%"]=true if diff>0 && diff<=5
    panzhen_signal_hash["5days_5_10%"]=true if diff>5 && diff<=10
    panzhen_signal_hash["5days_10-15%"]=true if diff>10 && diff<=15
    panzhen_signal_hash["5days_15_20%"]=true if diff>15 && diff<=20
    panzhen_signal_hash["5days_20_100%"]=true if diff>20
 return panzhen_signal_hash
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
  macd_signal_hash["5_days_down_10_days"] =true if macd_array[0]<= macd_array[1]
  macd_signal_hash["5_days_down_20_days"] =true if macd_array[0]<= macd_array[2]
  macd_signal_hash["5_days_down_30_days"] =true if macd_array[0]<= macd_array[3]
  macd_signal_hash["5_days_down_60_days"] =true if macd_array[0]<= macd_array[4]
  macd_signal_hash["10_days_down_20_days"] =true if macd_array[1]<= macd_array[2]
  macd_signal_hash["10_days_down_30_days"] =true if macd_array[1]<= macd_array[3]
  macd_signal_hash["10_days_down_60_days"] =true if macd_array[1]<= macd_array[4]
  macd_signal_hash["20_days_down_30_days"] =true if macd_array[2]<= macd_array[3]
  macd_signal_hash["20_days_down_60_days"] =true if macd_array[2]<= macd_array[4]
  macd_signal_hash["30_days_down_60_days"] =true if macd_array[3]<= macd_array[4]

return  macd_signal_hash
end


def get_monthly_MACD_array(raw_data_array)

  
end


#下面为测试代码

if $0 == __FILE__

  data_hash = yahoo_get_raw_data_from_file("600345.ss")
  #get_macd_array(data_hash,100,60)
  #macd_array=get_back_days_macd_array(30,data_hash,"600345.ss")

  #get_diff_array_from_array(macd_array)

  get_average_volume(101,data_hash.to_a,5)

end