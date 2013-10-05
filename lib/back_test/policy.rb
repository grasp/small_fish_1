
begin
	#macd_signal_hash["5_days_cross_10_days"] =true if macd_array[0] >macd_array[1]
	#macd_signal_hash["5_days_cross_20_days"] =true if macd_array[0] >macd_array[2]
	#macd_signal_hash["5_days_cross_30_days"] =true if macd_array[0] >macd_array[3]
	#macd_signal_hash["5_days_cross_60_days"] =true if macd_array[0] >macd_array[4]
    #macd_signal_hash["10_days_cross_20_days"] =true if macd_array[1] >macd_array[2]
	#macd_signal_hash["10_days_cross_30_days"] =true if macd_array[1] >macd_array[3]
	#macd_signal_hash["10_days_cross_60_days"] =true if macd_array[1] >macd_array[4]
    #macd_signal_hash["20_days_cross_30_days"] =true if macd_array[2] >macd_array[3]
	#macd_signal_hash["20_days_cross_60_days"] =true if macd_array[2] >macd_array[4]
	#macd_signal_hash["30_days_cross_60_days"] =true if macd_array[3] >macd_array[4]
	#macd_signal_hash["5_days_down_10_days"] =true if macd_array[0] <=macd_array[1]
	#macd_signal_hash["5_days_down_20_days"] =true if macd_array[0] <=macd_array[2]
	#macd_signal_hash["5_days_down_30_days"] =true if macd_array[0] <=macd_array[3]
	#macd_signal_hash["5_days_down_60_days"] =true if macd_array[0] <=macd_array[4]
    #macd_signal_hash["10_days_down_20_days"] =true if macd_array[1] <=macd_array[2]
	#macd_signal_hash["10_days_down_30_days"] =true if macd_array[1] <=macd_array[3]
	#macd_signal_hash["10_days_down_60_days"] =true if macd_array[1] <=macd_array[4]
    #macd_signal_hash["20_days_down_30_days"] =true if macd_array[2] <=macd_array[3]
	#macd_signal_hash["20_days_down_60_days"] =true if macd_array[2] <=macd_array[4]
	#macd_signal_hash["30_days_down_60_days"] =true if macd_array[3] <=macd_array[4]
end
buy_policy=Hash.new

def calculate_macd_policy(macd_hash,last_macd_hash,policy_array)
  
  current_macd=true
  last_macd=true

	policy_array[0].each do |policy|
		key=policy.keys[0]
		value=policy.values[0]
		#puts "#{key},#{value}"
		if macd_hash[key]!=value
			current_macd =false
			break;
		else
			next
		end
	end

	policy_array[1].each do |policy|
		key=policy.keys[0]
		value=policy.values[0]
		#puts "#{key},#{value}"
		if last_macd_hash[key]!=value
			last_macd =false
			break;
		else
			next
		end
	end
#puts "#{current_macd &&  last_macd},current_macd=#{current_macd},last_macd=#{last_macd}"
return current_macd &&  last_macd
end

if $0==__FILE__
   buy_array=["5_days_cross_10_days"=>true],["5_days_cross_10_days"=>false]

   macd_signal_hash=Hash.new
	macd_signal_hash["5_days_cross_10_days"] =true 
	macd_signal_hash["5_days_cross_20_days"] =true 
    macd_signal_hash["5_days_cross_30_days"] =true 
	macd_signal_hash["5_days_cross_60_days"] =true 
    macd_signal_hash["10_days_cross_20_days"] =true 
	macd_signal_hash["10_days_cross_30_days"] =true 
	macd_signal_hash["10_days_cross_60_days"] =true 
    macd_signal_hash["20_days_cross_30_days"] =true 
	macd_signal_hash["20_days_cross_60_days"] =true 
	macd_signal_hash["30_days_cross_60_days"] =true 
	macd_signal_hash["5_days_down_10_days"] =true 
	macd_signal_hash["5_days_down_20_days"] =true 
	macd_signal_hash["5_days_down_30_days"] =true 
	macd_signal_hash["5_days_down_60_days"] =true 
    macd_signal_hash["10_days_down_20_days"] =true 
	macd_signal_hash["10_days_down_30_days"] =true 
	macd_signal_hash["10_days_down_60_days"] =true 
    macd_signal_hash["20_days_down_30_days"] =true 
	macd_signal_hash["20_days_down_60_days"] =true 
	macd_signal_hash["30_days_down_60_days"] =true 

   puts calculate_macd_policy(macd_signal_hash,buy_array)

end