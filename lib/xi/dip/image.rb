# encoding: utf-8


class Xi::DIP::Image
  attr_reader :image, :blob

  # Initialize the image object
  # @param image [String] the file containing the image
  def initialize(image)
    if image.is_a?(String)
      load_from_file(image)
    else
      load_from_object(image)
    end

    begin
      @image = Magick::Image.from_blob(@blob).first
    rescue => e
      raise Xi::DIP::Error::CaughtException, \
        "Exception encountered when loading image: #{e.message}"
    end
  end

  def load_from_file(file)
    Xi::DIP::Utils.check_file_readable!(file)
    @blob = File.read(file)
  end

  def load_from_object(blob)
    @blob = blob.dup
  end

  # Store the image to file
  # @param output_file [String] the file where to store the image
  def save(output_file)
    Xi::DIP::Utils.create_path(output_file)
    @image.write(output_file)
  end

  # @return [Integer] the number of columns in the image
  def columns
    @image.columns
  end

  # @return [Integer] the number of rows in the image
  def rows
    @image.rows
  end

  # @return [Integer, Integer] the number of columns and of rows in the image
  def shape
    return @image.columns, @image.rows
  end

  # @return [Integer] the number of pixels in the image
  def size
    @image.rows * @image.columns
  end

  # @return [String] the background color
  def background_color
    @image.background_color
  end

  # @return [String] the picture format (PNG, JPEG, ...)
  def format
    @image.format
  end

  # @return [Float] the picture's gamma value
  def gamma
    @image.gamma
  end

  # @return [Integer] the picture's number of unique colors
  def number_colors
    @image.number_colors
  end

  # @return [Array] the 2D array of the image's pixels
  def pixels_2d
    nrows, ncols = @image.rows, @image.columns

    pixels = Array.new(nrows){ Array.new(ncols) }
    @image.each_pixel{|pixel, j, i| pixels[i][j] = pixel.dup }

    pixels
  end

  # Generator of pixels
  def each_pixel
    @image.each_pixel{|pixel| yield pixel }
  end

  # Create a new image with negated colors
  # @return [Magick::Image] the new image with inverted colors
  def negate
    @image.negate
  end

  # Create a new image with gray-scale colors
  # @return [Magick::Image] the new image on gray color space
  def gray_colorspace
    @image.quantize(256, Magick::GRAYColorspace, Magick::NoDitherMethod)
  end

  # Create a new image with LAB colors
  # @return [Magick::Image] the new image on LAB color space
  def lab_colorspace
    @image.quantize(256, Magick::LabColorspace)
  end

  # Create a new image with HSL colors
  # @return [Magick::Image] the new image on HSL color space
  def hsl_colorspace
    @image.quantize(256, Magick::HSLColorspace)
  end

  # Crate a new image after edge detection
  # @return [Magick::Image] the new image with inverted gray-scale edges
  def detect_edge
    @image.negate.quantize(256, Magick::GRAYColorspace).edge
  end

  # Check if image has a transparency channel
  # @return [Boolean] if picture has alpha channel
  def alpha?
    @image.alpha?
  end

  # Resize the current image: change both height and width
  # Do nothing if new dimensions are larger than old ones
  # @param ncols [Integer] the image's new width
  # @param nrows [Integer] the image's new height
  def resize!(ncols, nrows)
    return if nrows >= @image.rows || ncols >= @image.columns
    @image.resize!(ncols, nrows)
  end

  # Force resize on the current image: change both height and width
  # @param ncols [Integer] the image's new width
  # @param nrows [Integer] the image's new height
  def force_resize!(ncols, nrows)
    @image.resize!(ncols, nrows)
  end

  # Resize the current image: keep scale ratio with respect to new height
  # @param nrows [Integer] the image's new height
  def scale_on_height!(nrows)
    return if nrows >= @image.rows

    ncols = ((nrows.to_f / @image.rows) * @image.columns).to_i
    @image.resize!(ncols, nrows)
  end

  # Resize the current image: keep scale ratio with respect to new width
  # @param ncols [Integer] the image's new width
  def scale_on_width!(ncols)
    return if ncols >= @image.columns

    nrows = ((ncols.to_f / @image.columns) * @image.rows).to_i
    @image.resize!(ncols, nrows)
  end

  # Resize the current image to fit 'crop_ratio' percent of the image
  # @param crop_ratio [Float] save 'crop_ratio' percentage of the image
  def crop!(crop_ratio=0.9)
    return if crop_ratio <= 0 || crop_ratio >= 1

    nrows = (@image.rows * crop_ratio).to_i
    ncols = (@image.columns * crop_ratio).to_i
    @image.resize_to_fit!(ncols, nrows)
  end

  # Remove the alpha channel from current image
  def remove_alpha_channel!
    @image.alpha(Magick::DeactivateAlphaChannel) if @image.alpha?
  end

  # Recolor transparent pixels
  def transparent!(color='white')
    @image = @image.transparent(color, Magick::TransparentOpacity)
  end

  # Enhance the intensity differences between the lighter and darker elements
  # @param contrast [Boolean] increase or decrease the image contrast
  def contrast!(contrast)
    @image = @image.contrast(contrast)
  end

  # Add blur
  def blur!
    @image = @image.blur_image()
  end

  # Apply a digital filter that improves the quality of a noisy image
  def enhance!
    @image = @image.enhance
  end

  # Smooth the contours of an image while still preserving edge information
  def reduce_noise!(radius)
    @image = @image.reduce_noise(radius)
  end

  # Control the brightness, saturation, and hue of an image
  def modulate!(b, s, h)
    @image = @image.modulate(b, s, h)
  end

  # Posterize: reduce the image to a limited number of colors (poster effect)
  # @param level [Integer] the number of colors per channel
  # @param dither [Boolean] whether or not to dither the image
  def posterize!(level, dither=false)
    @image = @image.posterize(level, dither)
  end

  # Correct the gamma level
  # @param level [Float] the gamma correction level
  def gamma_correct!(level)
    @image = @image.gamma_correct(level)
  end

  # Apply boolean mask on current image and return the transformed image
  # (true values are recolored)
  # @param bool_mask [Array] the 2D boolean array
  # @param rcolor [String] the replacing color
  def recolor_boolean_mask!(bool_mask, rcolor='none')
    @image.rows.times do |i|
      @image.columns.times do |j|
        @image.pixel_color(j, i, rcolor) if bool_mask[i][j]
      end
    end
  end

  # Reshape image: extract 'false' values from a boolean mask
  # @param bool_mask [Array] the 2D boolean array
  def subimage_from_mask!(bool_mask)
    count_false = 0
    @image.rows.times do |i|
      @image.columns.times do |j|
        count_false += 1 unless bool_mask[i][j]
      end
    end

    sub_image = Magick::Image.new(count_false, 1)

    k = 0
    @image.each_pixel do |pixel, j, i|
      unless bool_mask[i][j]
        sub_image.pixel_color(k, 0, pixel)
        k += 1
      end
    end

    @image = sub_image.dup
  end

  # Recolor image: limit color values to a predefined set of colors
  # @param nclusters [Integer] the number of color clusters to use
  def remap!(nclusters=31)
    colormap = Xi::DIP::Color::ColorMap.image_from_colors(nclusters)
    @image = @image.remap(colormap, Magick::NoDitherMethod)
  end

  # Recover the image metadata
  # @return [Hash] metadata
  def exif
    exif = nil
    if @image.format == 'JPEG'
      exif = EXIFR::JPEG.new(StringIO.new @blob).exif
    elsif @image.format == 'TIFF'
      exif = EXIFR::TIFF.new(StringIO.new @blob).to_hash
    end
    exif = (exif.nil?) ? {} : exif.to_hash
    exif.each do |k, v|
      begin
        v.encode!('utf-8', 'utf-8', :invalid => :replace) if v.is_a?(String)
      rescue
        exif.delete(k)
      end
    end
  end

  # Recover the histogram of main colors in given image after remap
  # @param nclusters [Integer] the number of color clusters to use
  # @return [Hash] the color histogram
  def color_histogram(nclusters=31)
    colormap = Xi::DIP::Color::ColorMap.image_from_colors(nclusters)
    colors = Xi::DIP::Color::ColorMap::CLUSTERS[nclusters]

    img = @image.dup
    img = img.transparent('white', Magick::TransparentOpacity)
    img = img.remap(colormap, Magick::NoDitherMethod)

    size = img.rows * img.columns * 1.0

    histo = colors.values.each_with_object({}){|cname, h| h[cname] = 0.0 }
    img.color_histogram.each do |color, count|
      color = color.to_color(Magick::AllCompliance, true, 8, true)
      color_name = colors[color]
      histo[color_name] = (count / size * 100).round(2)
    end

    histo.sort_by{|_, v| -v }.to_h
  end

  # Recover the histogram of basic main colors in given image after remap
  # @param nclusters [Integer] the number of color clusters to use
  # @return [Hash] the color histogram
  def maincolor_histogram(nclusters=31)
    colormap = Xi::DIP::Color::ColorMap.image_from_colors(nclusters)
    colors = Xi::DIP::Color::ColorMap::CLUSTERS[nclusters]

    img = @image.dup
    img = img.transparent('white', Magick::TransparentOpacity)
    img = img.remap(colormap, Magick::NoDitherMethod)

    size = img.rows * img.columns * 1.0

    main_colors = colors.values.map{|name| name.split('|')[0] }.uniq
    histo = main_colors.each_with_object({}){|cname, h| h[cname] = 0.0 }

    img.color_histogram.each do |color, count|
      color = color.to_color(Magick::AllCompliance, true, 8, true)
      color_name = colors[color].split('|')[0]
      histo[color_name] += count
    end

    histo = histo.map{|k, v| [k, (v / size * 100).round(2)] }.to_h
    histo.sort_by{|_, v| -v }.to_h
  end

  # Recolor image: limit color values to a predefined set of colors
  # @param output_file [String] where to save the recolored image
  # @param nclusters [Integer] the number of color clusters to use
  def draw_recolored_image(output_file, nclusters=31, main=false)
    colormap = Xi::DIP::Color::ColorMap.image_from_colors(nclusters)
    colors = Xi::DIP::Color::ColorMap::CLUSTERS[nclusters]

    img = @image.dup
    img = img.transparent('white', Magick::TransparentOpacity)
    img = img.remap(colormap, Magick::NoDitherMethod)

    img.each_pixel do |pixel, j, i|
      hex1 = Xi::DIP::Color::Convertor.convert(pixel, :hex)
      if main
        hex2 = colors.key(colors[hex1].split('|')[0])
      else
        hex2 = colors.key(colors[hex1])
      end

      npixel = Xi::DIP::Color::Convertor.convert(hex2, :pixel)
      img.pixel_color(j, i, npixel)
    end

    Xi::DIP::Utils.create_path(output_file)
    img.write(output_file)
  end

  # Extract float RGB values from current image
  # @param flatten [Boolean] whether to return an 1D array of RGB values
  # @return [Array] the rgb values
  def extract_rgb(flatten=false)
    rgb = @image.dispatch(0, 0, @image.columns, @image.rows, 'RGB', true)
    return rgb if flatten

    rgb.each_slice(3).to_a
  end

  # Extract sliding/non-sliding regions of float RGB values from current image
  # @param sliding [Boolean] whether or not the regions should overlap
  # @param size [Integer] the region's square side size (same width and height)
  # @return [Array] the rgb values
  def extract_rgb_regions(sliding=true, size=3)
    return [] if size <= 0 || size > @image.rows || size > @image.columns

    rgb = []

    if sliding
      max_i = @image.rows - size + 1
      max_j = @image.columns - size + 1

      max_i.times do |y|
        max_j.times do |x|
          values = export_pixels(x, y, size, size, true)
          rgb << values
        end
      end
    else
      ni = @image.rows / size
      nj = @image.columns / size

      ni.times do |i|
        nj.times do |j|
          x = j * size
          y = i * size
          values = export_pixels(x, y, size, size, true)
          rgb << values
        end
      end
    end

    rgb
  end

  # Yield sliding/non-sliding regions of float RGB values from current image
  # @param sliding [Boolean] whether or not the regions should overlap
  # @param size [Integer] the region's square side size (same width and height)
  def yield_rgb_regions(sliding=true, size=3)
    return if size <= 0 || size > @image.rows || size > @image.columns

    if sliding
      max_i = @image.rows - size + 1
      max_j = @image.columns - size + 1

      max_i.times do |y|
        max_j.times do |x|
          values = export_pixels(x, y, size, size, true)
          yield values
        end
      end
    else
      ni = @image.rows / size
      nj = @image.columns / size

      ni.times do |i|
        nj.times do |j|
          x = j * size
          y = i * size
          values = export_pixels(x, y, size, size, true)
          yield values
        end
      end
    end
  end

  # Extract float RGB values from requested pixels
  # @param x [Integer] x position
  # @param y [Integer] y position
  # @param ncols [Integer] width
  # @param nrows [Integer] height
  # @return [Array] the rgb values
  def export_pixels(x, y, ncols, nrows, flatten=false)
    rgb = @image.export_pixels(x, y, ncols, nrows, 'RGB')
    rgb.map!{|c| 1.0 * c / Magick::TransparentOpacity }
    return rgb if flatten

    rgb.each_slice(3).to_a
  end
end
