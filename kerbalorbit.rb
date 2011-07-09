#!/usr/bin/env ruby

load 'lib/orbcalcs.rb'

if(ARGV.length < 1)
    puts "usage: kerbalorbit ALTITUDE"
end

# altitude is above sea level, which is 600 km from the center of the planet
r = ARGV[0].to_f + 600.0e3

puts "r: %4d km" % [r]

puts "Escape velocity = %7.2f m/s" % [vesc(r, M_KERBAL)]

puts "Circular orbit: velocity = %7.2f m/s, period = %7.2f min" %
        [vcirc(r, M_KERBAL), tcirc(r, M_KERBAL)/60]

puts "Apogee of transfer orbit to 30 km altitude: velocity = %7.2f m/s, half-period = %7.2f min" %
        [vell(r, 630.0e3, r, M_KERBAL), 0.5*tell(r, 630.0e3, r, M_KERBAL)/60]