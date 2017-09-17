#/usr/bin/env ruby

require_relative 'remuxer.rb'

if ARGV.length != 2
  puts "incorrect usage: $ remux <source_path> <output_path>"
else
  Remuxer.auto_remux(ARGV[0], ARGV[1])
end