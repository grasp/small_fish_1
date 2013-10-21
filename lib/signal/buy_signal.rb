require 'settingslogic'
require File.expand_path("../read_data_process.rb",__FILE__)

class BuySettings < Settingslogic

source File.expand_path("../buy_policy_1.yml",__FILE__)
 # source File.expand_path("../buy_policy_1.yml",__FILE__)

end

def generate_price_buy_signal(price_array,buy_policy_class)
	#print price_array.to_s
	#puts price_array[0].to_f
	#puts price_array[3].to_f
    #puts (price_array[0].to_f < price_array[3].to_f)
	puts (buy_policy_class.price.price_open_bigger_close) && (price_array[0].to_f > price_array[3].to_f)

end



if $0==__FILE__

processed_data_array=read_data_process_file("000009.sz")
buy_policy_class=BuySettings.new(File.expand_path("../buy_policy_1.yml",__FILE__))

processed_data_array[0].each do |date,price_array|
	generate_price_buy_signal(price_array,buy_policy_class)
end

end