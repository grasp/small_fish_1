

#generate a serial signal from one moment macd array

def generate_macd_sinal(macd_array)

    macd_signal_hash=Hash.new{false}
	macd_signal_hash["5_days_cross_10_days"] =true if macd_array[0] >macd_array[1]
	macd_signal_hash["5_days_cross_20_days"] =true if macd_array[0] >macd_array[2]
	macd_signal_hash["5_days_cross_30_days"] =true if macd_array[0] >macd_array[3]
	macd_signal_hash["5_days_cross_60_days"] =true if macd_array[0] >macd_array[4]
    macd_signal_hash["10_days_cross_20_days"] =true if macd_array[1] >macd_array[2]
	macd_signal_hash["10_days_cross_30_days"] =true if macd_array[1] >macd_array[3]
	macd_signal_hash["10_days_cross_60_days"] =true if macd_array[1] >macd_array[4]
    macd_signal_hash["20_days_cross_30_days"] =true if macd_array[2] >macd_array[3]
	macd_signal_hash["20_days_cross_60_days"] =true if macd_array[2] >macd_array[4]
	macd_signal_hash["30_days_cross_60_days"] =true if macd_array[3] >macd_array[4]
	macd_signal_hash["5_days_down_10_days"] =true if macd_array[0] <=macd_array[1]
	macd_signal_hash["5_days_down_20_days"] =true if macd_array[0] <=macd_array[2]
	macd_signal_hash["5_days_down_30_days"] =true if macd_array[0] <=macd_array[3]
	macd_signal_hash["5_days_down_60_days"] =true if macd_array[0] <=macd_array[4]
    macd_signal_hash["10_days_down_20_days"] =true if macd_array[1] <=macd_array[2]
	macd_signal_hash["10_days_down_30_days"] =true if macd_array[1] <=macd_array[3]
	macd_signal_hash["10_days_down_60_days"] =true if macd_array[1] <=macd_array[4]
    macd_signal_hash["20_days_down_30_days"] =true if macd_array[2] <=macd_array[3]
	macd_signal_hash["20_days_down_60_days"] =true if macd_array[2] <=macd_array[4]
	macd_signal_hash["30_days_down_60_days"] =true if macd_array[3] <=macd_array[4]

return  macd_signal_hash
end

def judge_big_state (macd_array)
	
end
