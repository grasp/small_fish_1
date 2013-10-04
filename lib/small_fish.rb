require "pathname"
require 'test/unit'
include Test::Unit::Assertions
require 'redis'

lib_path=Pathname.new(__FILE__).parent
require File.join(lib_path,"init","redis_init.rb")
require File.join(lib_path,"utility","get_all_stock_name_table.rb")
require File.join(lib_path,"init","stock_list_init.rb")




