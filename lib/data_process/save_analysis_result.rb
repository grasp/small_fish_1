
require File.expand_path("../macd_history.rb",__FILE__)
require File.expand_path("../low_high_price_history.rb",__FILE__)

def save_analysis_result(symbol)

    file_path=File.expand_path("../../../resources/analysis_result/#{symbol}.txt",__FILE__)
    #analysis_result_file=File.new("#{symbol}.txt","w+")
    puts file_path
    raw_hash=get_raw_data_from_file(symbol)
    macd_result=generate_one_stock_macd(raw_hash)
    price_result=low_high_price_analysis(raw_hash)

    result_macd_hash=macd_result[0]
    price_hash=macd_result[1]
    low_price_hash=price_result[0]
    high_price_hash=price_result[1]


    analysis_file=File.new(file_path,"w+")
    result_macd_hash.each do |date,macd_array|
    	analysis_file<<date.to_s+"#"+price_hash[date].to_s+"#"+macd_array.to_s+"#"+low_price_hash[date].to_s+"#"+high_price_hash[date].to_s+"\n"
    end
    analysis_file.close
end



if $0==__FILE__
	save_analysis_result("000009.sz")
end