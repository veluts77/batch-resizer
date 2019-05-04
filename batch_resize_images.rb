#!/usr/bin/env ruby

# Resizes jpeg images in the folder. Source images must
# meet requirements that can be interactively changed

require 'RMagick'

def gets_with_default(message, default)
  print message
  print " [#{default}]" unless default.nil?
  print ': '
  result = gets
  result = default if result.chomp.size.zero?
  result
end

# Selection of images that can be downsized
class ImagesSelection
  include Magick

  def initialize
    @selection = []
  end

  def input
    puts 'Image selection section.'
    msg = 'Smaller size should be more than (in pixels) '
    @threshold_size = gets_with_default msg, 2200
  end

  def apply
    Dir.foreach('.') do |filename|
      @selection.push(filename) if jpeg_image? filename
    end
  end

  def each(&block)
    @selection.each(&block)
  end

  private

  def jpeg_image?(filename)
    is_jpeg = (filename.end_with? 'jpg') || (filename.end_with? 'jpeg')
    is_jpeg
  end
end

selection = ImagesSelection.new
selection.input
selection.apply
selection.each { |filename| puts filename }
