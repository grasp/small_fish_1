
def get_average_volume_for_days(raw_data_array,back_days,duration)

	total_volume=0
	(duration-1).downto(0).each do |i|

		total_volume+=raw_data_array[back_days+i][1][4].to_i
	end
  return (total_volume.to_f/duration.to_f).to_i
end


def anaylys_volume_signal(raw_data_array,back_days)
   volume_signal=Hash.new
   todays_volume=raw_data_array[back_days][1][4].to_i
   #puts "todays_volume=#{todays_volume}"
   #two_days_volume=todays_volume+raw_data_array[back_days+1][1][4]
   #three_days_volume=todays_volume+raw_data_array[back_days+1][1][4]
   two_days_avg_volume=get_average_volume_for_days(raw_data_array,back_days,2)
   #puts "two_days_avg_volume=#{two_days_avg_volume}"
   volume_signal["1day_over_2days"]=todays_volume>get_average_volume_for_days(raw_data_array,back_days,2)
  
  # volume_signal["1day_over_2days_pecent"]=((todays_volume-two_days_avg_volume)/two_days_avg_volume.to_f)

   volume_signal["1day_over_3days"]=todays_volume>get_average_volume_for_days(raw_data_array,back_days,3)
   volume_signal["2day_over_5days"]=get_average_volume_for_days(raw_data_array,back_days,2)>get_average_volume_for_days(raw_data_array,back_days,5)
   volume_signal["5day_over_10days"]=get_average_volume_for_days(raw_data_array,back_days,5)>get_average_volume_for_days(raw_data_array,back_days,10)
   volume_signal["10day_over_20days"]=get_average_volume_for_days(raw_data_array,back_days,10)>get_average_volume_for_days(raw_data_array,back_days,20)
   volume_signal["20day_over_30days"]=get_average_volume_for_days(raw_data_array,back_days,20)>get_average_volume_for_days(raw_data_array,back_days,30)
   volume_signal["30day_over_60days"]=get_average_volume_for_days(raw_data_array,back_days,30)>get_average_volume_for_days(raw_data_array,back_days,60)
   return volume_signal
end

def statistic_on_volume_signal(volume_signal,volume_signal_counter_hash)

	 volume_signal["1day_over_2days"]==true ? volume_signal_counter_hash["1day_over_2days_true"]+=1 : volume_signal_counter_hash["1day_over_2days_false"]+=1
     volume_signal["1day_over_3days"]==true ? volume_signal_counter_hash["1day_over_3days_true"]+=1 : volume_signal_counter_hash["1day_over_3days_false"]+=1
     volume_signal["5day_over_10days"]==true ? volume_signal_counter_hash["5day_over_10days_true"]+=1 : volume_signal_counter_hash["5day_over_10days_false"]+=1
     volume_signal["10day_over_20days"]==true ? volume_signal_counter_hash["10day_over_20days_true"]+=1 : volume_signal_counter_hash["10day_over_20days_false"]+=1
     volume_signal["20day_over_30days"]==true ? volume_signal_counter_hash["20day_over_30days_true"]+=1 : volume_signal_counter_hash["20day_over_30days_false"]+=1
     volume_signal["30day_over_60days"]==true ? volume_signal_counter_hash["30day_over_60days_true"]+=1 : volume_signal_counter_hash["30day_over_60days_false"]+=1
     return volume_signal_counter_hash
end