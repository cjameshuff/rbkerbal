#!/usr/bin/env ruby

load 'lib/orbcalcs.rb'

perigee = 228089.0
apogee = 258997.0

# puts "perigee: #{perigee/1000.0} km"
# puts "apogee: #{apogee/1000.0} km"
# puts "variation in altitude: #{(apogee - perigee)/1000.0} km"
# puts "semimajor axis: #{(perigee + apogee)/2000.0} km"
# puts "eccentricity: #{eccentricity(perigee, apogee)}"
# 
# data = [
#     [apogee, 2009.0],
#     [perigee, 2083.9]
# ]
# data.each {|d|
#     puts "#{d[0]} m, #{d[1]} m/s, M_KERBAL: %e kg" % calcmass(d[0], d[1], perigee, apogee)
# }

r = 370834 + 600e3
v = 3485.9
puts "espec: #{espec(r, v, M_KERBAL)} J/kg"
puts "vexcess: #{vexcess(r, v, M_KERBAL)} m/s"

# (0..9999).step(50) {|d|
#     r = 600e3 + 1e3*d
#     puts "%4d km, Vcirc = %7.2f m/s, Tcirc = %7.2f min, Vesc = %7.2f m/s" %
#         [d, vcirc(r, M_KERBAL), tcirc(r, M_KERBAL)/60, vesc(r, M_KERBAL)]
# }
