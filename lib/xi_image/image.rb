require 'rmagick'
require 'exifr'

DEFAULT_COLORS =  {'#FFFFFF' => ['white'],
                   '#000000' => ['black']}

class XiImage::ColorMap
  attr_reader :image, :colors

  def initialize(colors)
    @colors = colors
    @image = Magick::Image.new(1, @colors.length)
    @colors.each_with_index {|c, i| @image.pixel_color(0, i, c[0])}
  end
end

class XiImage::Image

  @@loaded = false
  def self.load
    return if @@loaded
    @@colormap = XiImage::ColorMap.new(
      XiImage::Config.get('colormap', DEFAULT_COLORS)
    )
    @@loaded = true
  end

  def initialize(path)
    fail IOError, "Path '#{path}' does not exist or is not a file" unless File::file?(path)
    XiImage::Image.load
    @path = path
    @image = Magick::ImageList.new(path).first
  end

  def format
    @image.format
  end

  def exif
    exif = nil
    if format == 'JPEG'
      exif = EXIFR::JPEG.new(@path).exif
    elsif format == 'TIFF'
      exif = EXIFR::TIFF.new(@path).exif
    end
    (exif.nil?) ? {} : exif.to_hash
  end

  def size
    [@image.columns, @image.rows]
  end

  def color_histogram(colormap: nil)
    colormap = @@colormap if colormap.nil?
    img = @image
    img = img.transparent('white', 65535)
    img = img.remap(colormap.image)
    Hash[img.color_histogram.map {|k,v|
      [colormap.colors[k.to_color(Magick::AllCompliance, true, 8, true)], v]}]
  end
end
