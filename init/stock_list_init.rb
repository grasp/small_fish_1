



#lib_path=Pathname.new(__FILE__).parent.parent
#require File.join(lib_path,"init","redis_init.rb")
#require File.join(lib_path,"utility","get_all_stock_name_table.rb")
require File.expand_path("../config_load.rb",__FILE__)
require File.expand_path("../redis_init.rb",__FILE__)

#$redis.flushdb
#if  $redis.exists("stock_name_list")!=true
	# table_file=File.join(lib_path.parent,"info","stock_table_2013_10_01.txt")
     #assert(File.exist?(table_file),"#{table_file} not exist!")
     #load_stock_list_file_into_redis(table_file)
 #else
 #	$all_stock_list=$redis.hget("stock_name_list")


#end

module StockList

#load stock list into hash with yahoo symbol and name
def load_stock_list_file

	stock_list_file=File.expand_path("../../resources/stock_list/#{AppSettings.stock_list_name}",__FILE__)
	raise unless File.exist?(stock_list_file)
    
    all_stock_list=Hash.new
    File.open(stock_list_file,"r").each do |line|
    newline=line.force_encoding("utf-8")
    code=newline.match(/^\d\d\d\d\d\d/).to_s.force_encoding("utf-8")
    name=newline.match(/\D+/).to_s.force_encoding("utf-8")
    
    raise if name.nil? && code.nil?
    puts "Warn:#{code} without name!!" if name.nil?

    if code.match(/^60\d\d\d\d/)
  	code=code+".ss"
  	all_stock_list[code]=name
    elsif code.match(/^000\d\d\d/)
  	code=code+".sz"
  	all_stock_list[code]=name
    elsif code.match(/^002\d\d\d/)
    code=code+".sz"
    all_stock_list[code]=name
    elsif code.match(/^300\d\d\d/)
	code=code+".sz"
	all_stock_list[code]=name
    else
    end    
    end
    return all_stock_list
end

def store_stock_list_into_redis(stock_list)
  
  #stock_id=Integer.new
  stock_id=0

  stock_list.each do |symbol,name|
    $redis.set("sym_id_#{symbol}",stock_id)
    $redis.set("id_sym_#{stock_id}",symbol)
    $redis.set("sym_nam_#{symbol}",name)
    stock_id+=1
  end


end

end


if $0==__FILE__
  include StockList
  #stock_list= load_stock_list_file
  #store_stock_list_into_redis(stock_list)
  start=Time.now
 2400.downto(0).each do |i|
   $redis.get("id_sym_#{i}") 
  end
  puts "cost #{Time.now-start}"
end

