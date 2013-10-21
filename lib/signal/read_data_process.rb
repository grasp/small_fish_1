

def read_data_process_file(symbol)

 processed_file=File.expand_path("../../../resources/analysis_result/#{symbol}.txt",__FILE__)

  price_hash={}
  macd_hash={}
  low_price_hash={}
  high_price_hash={}
  volume_hash={}
 File.open(processed_file,"r").each do |line|
   
 	result_array=line.strip.split("#")
 	if  result_array.size>4
 	date=result_array[0]
    price_hash[date]=result_array[1].gsub(/\[|\]|\"/,"").split(",")
    macd_hash[date]=result_array[2].gsub(/\[|\]|\"/,"").split(",")
    low_price_hash[date]=result_array[3].gsub(/\[|\]|\"/,"").split(",")
    high_price_hash[date]=result_array[4].gsub(/\[|\]|\"/,"").split(",")
    volume_hash=result_array[5].gsub(/\[|\]|\"/,"").split(",")
end
 end
 [price_hash,macd_hash,low_price_hash,high_price_hash,volume_hash]
end


if $0==__FILE__
	read_data_process_file("000009.sz")
end