# encoding: utf-8

require 'rmagick'
require 'exifr'

DEFAULT_COLORS = { '#FFFFFF' => ['white'],
                   '#000000' => ['black'] }.freeze

class Xi::DIP::ColorMap
  attr_reader :image, :colors

  def initialize(colors)
    @colors = colors
    @image = Magick::Image.new(1, @colors.length)
    @colors.each_with_index {|c, i| @image.pixel_color(0, i, c[0]) }
  end
end

class Xi::DIP::Image
  class << self
    attr_accessor :colormap
  end

  @loaded = false
  def self.load
    return if @loaded
    @colormap = Xi::DIP::ColorMap.new(
      Xi::DIP::Config.get('colormap', DEFAULT_COLORS)
    )
    @loaded = true
  end

  def initialize(blob)
    @blob = blob
    @image = Magick::Image.from_blob(blob).first
    Xi::DIP::Image.load
  end

  def format
    @image.format
  end

  def exif
    exif = nil
    if format == 'JPEG'
      exif = EXIFR::JPEG.new(StringIO.new @blob).exif
    elsif format == 'TIFF'
      exif = EXIFR::TIFF.new(StringIO.new @blob).exif
    end
    exif = (exif.nil?) ? {} : exif.to_hash
    exif.each do |k, v|
      begin
        v.encode!('utf-8', 'utf-8', :invalid => :replace) if v.class == String
      rescue
        exif.delete(k)
      end
    end
  end

  def size
    [@image.columns, @image.rows]
  end

  def color_histogram(colormap: nil)
    colormap = Xi::DIP::Image.colormap if colormap.nil?
    img = @image
    img = img.transparent('white', 65_535)
    img = img.remap(colormap.image)
    histo = {}
    img.color_histogram.each do |color, number|
      color = color.to_color(Magick::AllCompliance, true, 8, true)
      color_name = colormap.colors[color]
      histo[color_name] = number
    end
    histo
  end
end