require 'rmagick'
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
    @image = Magick::ImageList.new(path)
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
