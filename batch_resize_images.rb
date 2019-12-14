#!/usr/bin/env ruby

# Resizes jpeg images in the folder. Source images must
# meet requirements that can be interactively changed

require 'RMagick'

def gets_int_with_default(message, default)
  result = gets_str_with_default message, default
  result.to_i
end

def gets_str_with_default(message, default)
  print message
  print " [#{default}]" unless default.nil?
  print ': '
  result = gets.chomp
  result = default if result.size.zero?
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
    msg = 'Smaller dimension should be more than (in pixels) '
    @threshold_size = gets_int_with_default msg, 2200
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

# Abstracts saving parameters
class SavingOptions
  attr_reader :option
  attr_reader :suboption

  def input
    show_caption
    loop do
      msg = 'Please choose the option'
      @option = gets_int_with_default msg, 1
      break if [1, 2, 3].include? @option

      puts 'Acceptable options are only 1, 2 or 3'
    end
    clarify_input
  end

  def create_saver
    case @option
    when 1
      SubfolderSaver.new @suboption
    when 2
      PrefixSaver.new @suboption
    when 3
      OverrideSaver.new @suboption
    end
  end

  private

  def show_caption
    puts
    puts 'Select where images are saved:'
    puts '  1 - save to subfolder'
    puts '  2 - save with prefix'
    puts '  3 - overwrite existing files'
  end

  def clarify_input
    case @option
    when 1
      clarify_subfolder_name
    when 2
      clarify_prefix
    when 3
      clarify_overwrite
    end
  end

  def clarify_subfolder_name
    msg = 'Which subfolder the files should be written to?'
    @suboption = gets_str_with_default msg, 'converted'
  end

  def clarify_prefix
    msg = 'Which prefix should be prepended to files?'
    @suboption = gets_str_with_default msg, 'sml'
  end

  def clarify_overwrite
    msg = 'Copy original images to "original" subfolder?'
    @suboption = gets_str_with_default msg, 'no'
  end
end

# Performs saving into a subfolder
class SubfolderSaver
  def initialize(subfolder_name)
    @subfolder_name = subfolder_name
  end

  def save(selection)
    puts "saving to subfolder '#{@subfolder_name}'"
    prepare_dir
    selection.each do |item|
      resizer = Resizer.new item, "#{@subfolder_name}/#{item}"
      resizer.resize_and_save
    end
  end

  private

  def prepare_dir
    if Dir.exist? @subfolder_name
      consider_overwriting
    else
      Dir.mkdir @subfolder_name
    end
  end

  def consider_overwriting
    msg = "Directory exists! Type 'y' or 'yes' if you want to replace files"
    yes = gets_str_with_default msg, 'no'
    abort 'Stopping script.' unless ['yes', 'y'].include? yes
  end
end

# Performs saving with prefix
class PrefixSaver
  def initialize(prefix_name)
    @prefix_name = prefix_name
  end

  def save(selection)
    puts 'saving with prefix'
  end
end

# Performs override saving
class OverrideSaver
  def initialize(make_copy)
    @make_copy = make_copy
  end

  def save(selection)
    puts 'overwriting'
  end
end

# Does resizing work
class Resizer
  include Magick

  def initialize(source_filename, destination_filename)
    @source_filename = source_filename
    @destination_filename = destination_filename
  end

  def resize_and_save
    resize
    save
  end

  private

  def resize
    print "#{@source_filename} - resizing... "
    @image = Magick::Image.read(@source_filename).first
    @image.resize! 1000, 1000
    print "done, "
  end

  def save
    puts "saving to #{@destination_filename}"
    @image.write(@destination_filename)
  end
end

selection = ImagesSelection.new
selection.input
selection.apply
selection.show_current

saving_options = SavingOptions.new
saving_options.input

saver = saving_options.create_saver
saver.save selection
