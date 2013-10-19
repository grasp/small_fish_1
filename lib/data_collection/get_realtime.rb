
def yahoo_convert_result_to_hash(result,result_hash)
	  raise if result.nil?
      result.match(/\{.*\}/).to_s.gsub(/\{|\}/,"").split(/,/).each do|array_item|
 	  #puts array_item
 	  hash=array_item.gsub(/"/,"").strip.split("=>")
 	  result_hash[hash[0]]=hash[1]
 	end
 	return result_hash
end

def yahoo_get_real_time_stock_data(symbol)
	command_run="ruby G:\\small_fish_0\\lib\\yahoo\\yahoofinance.rb -r #{symbol}"
	result=`#{command_run}`
	result_hash=Hash.new

    yahoo_convert_result_to_hash(result,result_hash)
    price=result_hash["lastTradeWithTime"].split("-")[1].gsub(/\<b\>/,"").gsub(/\<\/b\>/,"")
    puts price

    puts result_hash
    return result_hash

end

def yahoo_get_standand_quote(symbol)
  	command_run="ruby G:\\small_fish_0\\lib\\yahoo\\yahoofinance.rb -s #{symbol}"
	result=`#{command_run}`
	result_hash=Hash.new

    yahoo_convert_result_to_hash(result,result_hash)
    puts result_hash
    return result_hash
end

def yahoo_get_extend_quote(symbol)
	command_run="ruby G:\\small_fish_0\\lib\\yahoo\\yahoofinance.rb -x #{symbol}"
	result=`#{command_run}`
	result_hash=Hash.new

    yahoo_convert_result_to_hash(result,result_hash)
    puts result_hash
    return result_hash
end
yahoo_get_extend_quote("601566.ss")
#yahoo_get_standand_quote("601566.ss")
#yahoo_get_real_time_stock_data("601566.ss")