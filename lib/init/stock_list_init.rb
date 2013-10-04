
require "pathname"
require 'test/unit'
include Test::Unit::Assertions

lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"utility","get_all_stock_name_table.rb")

#$redis.flushdb
#if  $redis.exists("stock_name_list")!=true
	 table_file=File.join(lib_path.parent,"info","stock_table_2013_10_01.txt")
     assert(File.exist?(table_file),"#{table_file} not exist!")
     load_stock_list_file_into_redis(table_file)
 #else
 #	$all_stock_list=$redis.hget("stock_name_list")
#end
