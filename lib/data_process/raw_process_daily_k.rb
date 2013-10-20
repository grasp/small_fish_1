
#将日线数据转化成hash
#hash的key 为日期数据
#hash 的值为几个基本数据，依次为开盘，最高，最低，收盘，成交量
def get_raw_data_from_file(symbol)

 data_hash=Hash.new

 #stock_file_path=File.join(h_data_path,symbol+".txt")
  stock_file_path=File.expand_path("../../../resources/history_daily_data/#{symbol}.txt",__FILE__)
  puts stock_file_path
  raise unless File.exist?(stock_file_path)
  open(stock_file_path).each do |line|
   
 	daily_data = line.split(",")
 	next if daily_data[2].nil?
 	data_hash[daily_data[1]]=[daily_data[2],daily_data[3],daily_data[4],daily_data[5],daily_data[6],daily_data[7].strip]
 end
data_hash
end
