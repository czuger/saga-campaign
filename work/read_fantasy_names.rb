require 'open-uri'
require 'pp'
require 'yaml'

# Fantasy names comes from : 'http://www.angelfire.com/tx/afira/fantasymfull.html'

result = []

File.open( 'names.txt', 'r' ) do |f|
  f.readlines.each do |line|
    s = line.strip.split( "\t" )
    next if s.count < 3
    result << s
  end
end

result.flatten!
result.map{ |e| e.downcase! }

File.open( '../data/fantasy_names.yaml', 'w' ) { |file| file.write( result.to_yaml ) }