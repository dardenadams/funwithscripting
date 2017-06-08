# For calculating in ns the real latency of RAM
# Really justa  bit of math ...

# Since 1GHz = 1 clock cycle per nanosecond, we can calculate ns per each clock cycle by dividing 1(ns) by entered GHz value
puts 'Enter clock speed in GHz:'
speed = gets.chomp.to_f
# Since DDR is labeled at twice actual clock speed (Double Data Rate), divide by half for actual clock speed
speed = speed / 2
nspercycle = 1 / speed

puts nspercycle

# Get delay nums in ns. CAS (Column Address Strobe), RCD (RAS to CAS Delay), RP (Row Precharge time), RAS (Row Active Time)
puts 'Enter CAS latency in ns:'
cas = gets.chomp.to_f
puts 'Enter tRCD latency in ns:'
rcd = gets.chomp.to_f
puts 'Enter tRP latency in ns:'
rp = gets.chomp.to_f
puts 'Enter tRAS latency in ns:'
ras = gets.chomp.to_f

# Latency is speed x CAS, i.e. how long 1 clock cycle takes times number of clock cycles
# Round 4 decimal places for easy reading.
caslatency = (nspercycle * cas).round(4)
rcdlatency = (nspercycle * rcd).round(4) + caslatency
rplatency = (nspercycle * rp).round(4) + caslatency + rcdlatency
raslatency = (nspercycle * rp).round(4) + caslatency + rcdlatency + rplatency

puts 'True latency is (best case to worst case):'
puts caslatency
puts rcdlatency
puts rplatency
puts raslatency
puts 'If data address is already active, first value will apply. If data must be accessed at a'
puts 'completely new address and another address is already active, worst
