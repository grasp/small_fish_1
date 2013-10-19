require "pathname"
require "json"
lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"yahoo","load_daily_k_to_hash.rb")

def get_lowest_price(data_hash,duration,back_days)
	#每天为一个数组，第一个数组是最近的一天数据
	data_array=data_hash.to_a
	lowest_price_array=Array.new

	back_days.upto(back_days+duration-1).each do |one_day_data|	
		unless data_array[one_day_data].nil?
		  lowest_price_array << data_array[one_day_data][1][2].to_f
	    end
	end
	#puts lowest_price_array.sort[0]
	#puts lowest_price_array.sort.last

	#puts "last #{lowest_price_array.sort.last},first=#{lowest_price_array.sort.first}"
	return [lowest_price_array.sort.first,lowest_price_array.sort.last]

end



def get_highst_price(data_hash,duration)
	#每天为一个数组，第一个数组是最近的一天数据
	data_array=data_hash.to_a
	price_array=Array.new

	0.upto(duration-1).each do |one_day_data|	
		#puts data_array[one_day_data][1][2] # [1],[2]为最低价
		unless data_array[one_day_data].nil?
		  price_array<< data_array[one_day_data][1][1].to_f
	    end
	end
	#puts lowest_price_array.sort
	#puts price_array.sort.reverse[0]
	return price_array.sort.reverse[0]

end

def price_signal(data_hash,duration)
   low_price=get_lowest_price(data_hash,duration)
   high_price=get_highst_price(data_hash,duration)
   current_price=((data_hash.to_a[0][1][2].to_f+data_hash.to_a[0][1][1].to_f)/2).to_f.round(2)
   price_sigal_hash=Hash.new{false}

	percent=((high_price.to_f-low_price.to_f)/current_price).to_f.round(2)*100

	#puts percent

	price_sigal_hash["higher_0_5%"]=true if  percent>0 && percent <=5
	price_sigal_hash["higher_5_10%"]=true if  percent>5 && percent <=10
	price_sigal_hash["higher_10_15%"]=true if  percent>10 && percent <=15
	price_sigal_hash["higher_15_20%"]=true if  percent>15 && percent <=20
	price_sigal_hash["higher_20_30%"]=true if  percent>20 && percent <=30
	price_sigal_hash["higher_30_40%"]=true if  percent>30 && percent <=40
	price_sigal_hash["higher_40_50%"]=true if  percent>40 && percent <=50
    price_sigal_hash["higher_50%"]=true if  percent>=50 
    return  price_sigal_hash
end

if $0 == __FILE__

  data_hash = yahoo_get_raw_data_from_file("600345.ss")
  puts price_signal(data_hash,20)

end