
require 'settingslogic'

class AppSettings < Settingslogic
  source File.expand_path('../config/small_fish.yml', File.dirname(__FILE__))
end

if $0==__FILE__ 
   puts AppSettings.app_name
   puts AppSettings.stock_list_path
end