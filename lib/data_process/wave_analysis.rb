require "pathname"

lib_path=Pathname.new(__FILE__).parent.parent
require File.join(lib_path,"yahoo","load_daily_k_to_hash.rb")

#
def get_highest_lowest(raw_data_array,back_days,duration)

high_low=Array.new
new_array=raw_data_array[back_days,raw_data_array.size]

	duration.upto(new_array.size-duration).each do |index|
		lowest=true
     
		(-duration).upto(-1).each do |i|
			lowest &&= new_array[index+i][1][2].to_f>new_array[index][1][2].to_f unless new_array[index+i].nil?
		end

		(1).upto(duration).each do |i|
			lowest &&= new_array[index+i][1][2].to_f>new_array[index][1][2].to_f unless new_array[index+i].nil?
		end
		if  lowest==true
		   #  puts "lowest"+raw_data_array[index][0].to_s 
		      high_low<<[new_array[index][0], "lowest", new_array[index][1][2]]
		 end
     end


	duration.upto(new_array.size-duration).each do |index|
		highest=true
     
		(-duration).upto(-1).each do |i|
			highest &&= new_array[index+i][1][2].to_f<new_array[index][1][2].to_f unless new_array[index+i].nil?
		end

		(1).upto(duration).each do |i|
			highest &&= new_array[index+i][1][2].to_f<new_array[index][1][2].to_f unless new_array[index+i].nil?
		end
		       if  highest==true
		     #  puts "highest"+ raw_data_array[index][0].to_s 
		       #high_low<<raw_data_array[index]
		    high_low<<[new_array[index][0], "highest", new_array[index][1][2]]
		     end
     end

high_low_signal=Array.new
  high_low.sort.reverse[0,5].each do |price_high_log|
  	high_low_signal<<price_high_log[1]
  end

#print high_low_signal.to_s+"\n"

return high_low_signal
end


if $0==__FILE__
	 data_hash = yahoo_get_raw_data_from_file("600345.ss")
	 raw_data_array=data_hash.to_a
     get_highest_lowest(raw_data_array,100,30)
end