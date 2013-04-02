require "csv"
require "fileutils.rb"
 require 'zip/zip'


$lightrailTrips = Array.new
$marcTrips = Array.new
$commuterbusTrips = Array.new
$busTrips = Array.new
$metroTrips = Array.new

#takes the directory of GTFS data to be converted (should be in the same directory as this script)
$gtfsdir = ARGV[0]
dir = File.expand_path($gtfsdir)

routesString = ARGV[0] + "/routes.txt"
$tripsString = ARGV[0] + "/trips.txt"
stopsString = ARGV[0] + "/stops.txt"
$stop_timesString = ARGV[0] + "/stop_times.txt"


#define route IDs for metro, lightrail, marc, and commuterbus 
metro= ["5747"]
lightrail = ["5756"]
marc = ["5997","6033","5998"]
commuterbus = ["6007","6008","6009","6010","6011","6012","6030","6013","6014","6031","5770","6016","6017","6018","6019","6020","6021","6022","6023","6024","6025","6026","6027","6028","6029"]

headerArray = [
	["/routes.txt","route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color"],
	["/trips.txt","route_id,service_id,trip_id,trip_headsign,direction_id,block_id,shape_id"],
	["/stops.txt","stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station"],
	["/stop_times.txt","trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled"]]
	
copyArray = ["/agency.txt","/calendar.txt","/calendar_dates.txt","/stops.txt","/stop_times.txt"]

#create subdirectory for each new transit type
typeArray = ["metro","bus","lightrail","marc","commuterbus"]
typeArray.each { |x|
	newDir = $gtfsdir + "_" + x
	FileUtils.mkdir newDir
	puts "Making new directory: " + newDir
	
	
	#make routes, trips, stops, and stop_times for each new GTFS folder, populate headers
	headerArray.each{ |y|
		newFile = File.new newDir + y[0],"w"
		newFile.puts(y[1])
		newFile.close
		
		puts "Creating new files and headers for routes, trips, stop, and stop_times for " + x
	
	}
	
	#copy agency, calendar, calendar dates, stops, and stop_times from main directory to each new directory
	
	copyArray.each { |z|
		
		#newFile = File.new (newDir + z),"w" 

		#File.open($gtfsdir + z, 'r') { |f| f.write(File.new(newDir + z,'w')) }
		FileUtils.cp $gtfsdir + z, newDir + z, :preserve => true
	
		puts "Copying agency, calendar, and calendar dates for: " + x
	}
	
	
	
	def processRow(row,type,gtfsdir)
		
		puts "Processing route " + row[0] + " of type " + type
		
		#write a line for each route in the appropriate new routes.txt
		writeFile = File.open gtfsdir + "_" + type + "/routes.txt","a"
		i=0
		row.each {|z|
			if !z
				z=""
			end
			
			if i == 0
				writeFile.print z
			else
				writeFile.print "," + z
			end
			i += 1
		}	
		writeFile.puts ""
		writeFile.close 
		
		
		processTrips(row[0],type,gtfsdir)
		
	end
	
	def processTrips(row,type,gtfsdir)
		trips = CSV.open $tripsString
		
		
		writeFile = File.open gtfsdir + "_" + type + "/trips.txt","a"
		trips.drop(1).each do |t|
		
			##puts "Hi from processTrips(), row is " + row + " and t[0] is " + t[0]
			
			if t[0] == row
				
				puts "I found a trip that matches route " + row
				
				i=0
				t.each {|w|
					
					
					if !w
						w=""
					end
					
					if i == 0
						writeFile.print w
						
					else
						writeFile.print "," + w
						
					end
					i += 1
					
				}
				
				writeFile.puts ""
				
				case type
				
				when "lightrail"
					$lightrailTrips << t[6]
				when "metro"
					$metroTrips << t[6]	
				when "marc"
					$marcTrips << t[6]
				when "commuterbus"
					$commuterbusTrips << t[6]
				when "bus"
					$busTrips << t[6]
				else
					puts "something didn't make it into a trips array"
				end
			end
		
		
			
			
		end
	
		
		
		
		
		
	end
	
	
	
}

c = CSV.open routesString
c.drop(1).each do |row|

	if lightrail.include?(row[0].to_s)
		
		processRow(row,"lightrail",$gtfsdir);
		
	elsif metro.include?(row[0])
		processRow(row,"metro",$gtfsdir);	
		
	elsif marc.include?(row[0])
		processRow(row,"marc",$gtfsdir);
		
	elsif commuterbus.include?(row[0])
		processRow(row,"commuterbus",$gtfsdir);

	else 
		puts "ProccessROW bus was called"
		processRow(row,"bus",$gtfsdir);
		
		
		
	end
	
end	
	


  def bundle(type)
      bundle_filename = type + ".zip"
      FileUtils.rm type + ".zip",:force => true
      dir = $gtfsdir + "_" + type
      Zip::ZipFile.open(bundle_filename, Zip::ZipFile::CREATE) { |zipfile|
        Dir.foreach(dir) do |item|
          item_path = "#{dir}/#{item}"
          zipfile.add( item,item_path) if File.file?item_path
        end
      }
     File.chmod(0644,bundle_filename)
   end
 
 typeArray.each {|b|
	bundle(b)
 }
 
 


