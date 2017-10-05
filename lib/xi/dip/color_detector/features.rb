# encoding: utf-8


class Xi::DIP::ColorDetector::Features

  OPTIONS = {
    :pixel => {
      :value => { :colorspace => :rgb },
      :distance => {
        :nclusters => 12,
        :measure => :euclidean,
        :colorspace => :rgb,
      },
    },
    :region => {
      :value => { :size => 3, :sliding => true, :colorspace => :rgb },
      :histogram => {
          :size => 100,
          :sliding => false,
          :nbins => 4,
          :colorspace => :rgb,
      },
    },
    :image => {
      :value => { :colorspace => :rgb },
      :histogram => {
        :nbins => 4,
        :colorspace => :rgb,
      },
    },
  }.freeze

  # Validate level, feature type and feature arguments
  # @param level [Symbol] which extraction level (:pixel / :region / :image)
  # @param ftype [Symbol] which features type (:value / :distance / :histogram)
  # @param fargs [Hash] the arguments associated to the feature type
  def self.validate_option(level, ftype, fargs)
    raise Xi::DIP::Error::ConfigError,
      "Bad level: #{level}. Expected: #{OPTIONS.keys}" \
      unless OPTIONS.keys.include?(level)

    raise Xi::DIP::Error::ConfigError, \
      "Bad feature type: #{ftype}. Expected: #{OPTIONS[level].keys}" \
      unless OPTIONS[level].key?(ftype)

    raise Xi::DIP::Error::ConfigError, \
      "Bad arguments: #{fargs}. Expected: #{OPTIONS[level][ftype].keys}" \
      unless fargs.is_a?(Hash) \
        && fargs.keys.sort == OPTIONS[level][ftype].keys.sort
  end

  # Extract features from image for color classification: yield one at a time
  # @param image [Xi::DIP::Image] the given image
  # @param level [Symbol] which extraction level (:pixel / :region / :image)
  # @param ftype [Symbol] which features type (:value / :distance / :histogram)
  # @param fargs [Hash] the arguments associated to the feature type
  def self.generator(image, level, ftype, fargs)
    method = :"extract_#{level}_#{ftype}"

    self.__send__(method, image, fargs) do |feat|
      yield feat
    end
  end

  # Extract rgb / hsl / lab / ... values from each pixel in the current image
  # @param image [Xi::DIP::Image] the given image
  # @param colorspace [Symbol] the wanted colorspace
  # @return [Array] the array of color values
  def self.color_values(image, colorspace)
    values = image.extract_rgb()
    values = Xi::DIP::Color::Convertor.convert_array(values, colorspace) \
      if colorspace != :rgb

    values
  end

  # Extract rgb / hsl / lab / ... values from each pixel in the current image
  # @param image [Xi::DIP::Image] the given image
  # @param fargs [Hash] the arguments associated to the feature type
  def self.extract_pixel_value(image, fargs)
    features = color_values(image, fargs[:colorspace])
    features.each{|feat| yield feat }
  end

  # Compute distances between the rgb / hsl / lab / ... values
  #   of each pixel in the image and a list of main colors
  # @param image [Xi::DIP::Image] the given image
  # @param fargs [Hash] the arguments associated to the feature type
  # - nclusters: the distances are computed with respect to these colors
  # - measure: the wanted distance measure
  # - colorspace: the wanted color space
  def self.extract_pixel_distance(image, fargs)
    rimage = image.extract_rgb()
    cimage = Xi::DIP::Color::ColorMap.rgb_from_colors(fargs[:nclusters])

    if fargs[:colorspace] != :rgb
      rimage = Xi::DIP::Color::Convertor.convert_array(
        rimage, fargs[:colorspace])
      cimage = Xi::DIP::Color::Convertor.convert_array(
        cimage, fargs[:colorspace])
    end

    rimage.each do |rvalues|
      feat = []
      cimage.each do |cvalues|
        feat << Xi::DIP::Color::Comparator.compare(
          rvalues, cvalues, fargs[:measure])
      end

      yield feat unless feat.empty?
    end
  end

  # Convert region values into an other color space
  # @param region [Array] flat array of rgb float values
  # @param colorspace [Symbol] the wanted colorspace
  # @return [Array] the possibly converted color values
  def self.region_colors(region, colorspace)
    nregion = region.clone

    if colorspace != :rgb
      nregion = Xi::DIP::Color::Convertor.convert_array(
        nregion.each_slice(3).to_a, colorspace)
      nregion.flatten!
    end

    nregion
  end

  # Extract rgb / hsl / lab / ... values from each region in the current image
  # @param image [Xi::DIP::Image] the given image
  # @param fargs [Hash] the arguments associated to the feature type
  # - :size: the region's squared size (width & height)
  # - :sliding: whether to use or not a sliding overlapping window
  # - :colorspace: the wanted color space
  def self.extract_region_value(image, fargs)
    image.yield_rgb_regions(fargs[:sliding], fargs[:size]) do |region|
      region = region_colors(region, fargs[:colorspace])
      yield region
    end
  end

  # Compute the color histogram for each requested region
  # @param image [Xi::DIP::Image] the given image
  # @param fargs [Hash] the arguments associated to the feature type
  # - :size: the region's squared size (width & height)
  # - :sliding: whether to use or not a sliding overlapping window
  # - :nbins: the number of bins determining the equal ranges of values in hist
  # - :colorspace: gives the proper value range of given colorspace
  def self.extract_region_histogram(image, fargs)
    intervals = define_intervals(fargs[:colorspace], fargs[:nbins])

    image.yield_rgb_regions(fargs[:sliding], fargs[:size]) do |region|
      region = region_colors(region, fargs[:colorspace])
      yield histogram_on_values(region, fargs[:nbins], intervals)
    end
  end


  # Extract rgb / hsl / lab / ... values from the current image
  # @param image [Xi::DIP::Image] the given image
  # @param fargs [Hash] the arguments associated to the feature type
  def self.extract_image_value(image, fargs)
    features = color_values(image, fargs[:colorspace])
    yield features.flatten
  end

  # Compute the color histogram for the entire image
  # @param image [Xi::DIP::Image] the given image
  # @param fargs [Hash] the arguments associated to the feature type
  # - :nbins: the number of bins determining the equal ranges of values in hist
  # - :colorspace: gives the proper value range of given colorspace
  def self.extract_image_histogram(image, fargs)
    intervals = define_intervals(fargs[:colorspace], fargs[:nbins])

    features = color_values(image, fargs[:colorspace])
    features.flatten!

    yield histogram_on_values(features, fargs[:nbins], intervals)
  end

  # Define the intervals for the histogram
  # @param colorspace [Symbol] the wanted colorspace
  # @param nbins [Integer] the number of bins
  # @return [Array] the corresponding intervals
  def self.define_intervals(colorspace, nbins)
    ranges = Xi::DIP::Color::Convertor::RANGES[colorspace]

    intervals = []
    ranges.each do |range|
      vmin = range.first * 1.0
      vmax = range.last * 1.0
      step = (vmax - vmin) / nbins
      interval = vmin.step(vmax - step, step).map{|x| (x...(x + step)) }
      interval[-1] = (vmax - step)..vmax
      intervals << interval
    end

    intervals
  end

  # Compute the color histogram for the given values
  # @param values [Array] the given values
  # @param nbins [Integer] the number of bins
  # @param intervals [Integer] the split intervals for current colorspace, nbins
  # @return [Hash] the color histogram
  def self.histogram_on_values(values, nbins, intervals)
    # 3D histogram: 4 bins => 64 values
    hist = Array.new(nbins){ Array.new(nbins){ Array.new(nbins, 0.0) } }

    count = 0
    values.each_slice(3) do |v1, v2, v3|
      int_v1 = intervals[0].index{|x| x.include?(v1) }
      int_v2 = intervals[1].index{|x| x.include?(v2) }
      int_v3 = intervals[2].index{|x| x.include?(v3) }

      count += 1
      hist[int_v1][int_v2][int_v3] += 1
    end

    hist.flatten.map{|x| x / count }
  end

  private_class_method :color_values, :region_colors, \
    :extract_pixel_value, :extract_pixel_distance, \
    :extract_region_value, :extract_region_histogram, \
    :extract_image_value, :extract_image_histogram, \
    :define_intervals, :histogram_on_values
end
