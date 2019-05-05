#!/usr/bin/env ruby

# Resizes jpeg images in the folder. Source images must
# meet requirements that can be interactively changed

require 'RMagick'

def gets_with_default(message, default)
  print message
  print " [#{default}]" unless default.nil?
  print ': '
  result = gets.chomp
  result = default if result.size.zero?
  result.to_i
end

# Selection of images that can be downsized
class ImagesSelection
  include Magick

  def initialize
    @selection = []
  end

  def input
    puts 'Image selection section.'
    msg = 'Smaller dimension should be more than (in pixels) '
    @threshold_size = gets_with_default msg, 2200
  end

  def apply
    print 'Selecting appropriate files... '
    Dir.foreach('.') do |filename|
      @selection.push(filename) if accepted_image? filename
    end
    puts 'done.'
  end

  def show_current
    puts "The following files are selected (#{@selection.size} in total):"
    each { |filename| print "#{filename} " }
    puts
  end

  def each(&block)
    @selection.each(&block)
  end

  private

  def accepted_image?(filename)
    (jpeg_image? filename) && (smaller_dimension_exceeds_threshold? filename)
  end

  def jpeg_image?(filename)
    is_jpeg = (filename.end_with? 'jpg') || (filename.end_with? 'jpeg')
    is_jpeg
  end

  def smaller_dimension_exceeds_threshold?(filename)
    image = Magick::Image.read(filename).first
    min_dimension = [image.columns, image.rows].min
    exceeds = min_dimension > @threshold_size
    exceeds
  end
end

selection = ImagesSelection.new
selection.input
selection.apply
selection.show_current
selection.each { |filename| puts filename }
