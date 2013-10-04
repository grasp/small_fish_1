require 'net/http'  
require 'pp'  
  
#coding:UTF-8
sina_array_description_index={
1 => "最高价"

}


def sina_get_realtime_data_for_one_stock(stock_number)

proxy_addr="10.140.19.49"
proxy_port="808"

uri = URI("http://hq.sinajs.cn/list=sh601566"  )

Net::HTTP.start(uri.host, uri.port,proxy_addr,proxy_port) do |http|
  request = Net::HTTP::Get.new uri
  response = http.request request # Net::HTTPResponse object
  pp response.body.split(",")
end

end



puts sina_array_description_index

