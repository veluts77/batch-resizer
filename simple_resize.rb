#!/usr/bin/env ruby

require 'RMagick'
include Magick

def gets_with_default(message, default)
  print message
  print " [#{default}]" unless default.nil?
  print ': '
  result = gets
  result = default if result.chomp.size.zero?
  result
end

# dsdfdsf sdf
class ImagesProvider
  def load
    puts 'loading'
  end

  def filter
    puts 'filtering'
  end
end

v = gets_with_default 'enter a value', 34
puts v
