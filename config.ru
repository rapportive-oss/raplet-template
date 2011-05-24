# Start the Raplet Sinatra application in Rack
puts "Initializing Raplet..."
require './raplet'
require './jsonp_errors'

puts "Running Raplet..."
use JsonpErrors
run Raplet
