# encoding: utf-8

class Xi::DIP::ColorDetector::Detector
  attr_reader :classifier, :clusters, :image, :colors, :rsize

  # Load the MLP classifier
  # @param model_file [String] the classifier's model
  def initialize(model_file)
    Xi::DIP::Utils.check_file_readable!(model_file)
    @classifier = Xi::ML::Classify::Classifier.new('MLPClassifier', model_file)
    @clusters = @classifier.model.model['classes']
  end

  # Load and preprocess image
  # @param image_file [String] the given image
  # @param options [Hash] which preprocessing techniques to apply on the image
  # @param display [Boolean] whether or not to display the recolored bkg image
  def preprocess_image(image_file, options, display=false)
    @image = Xi::DIP::Image.new(image_file)

    unless options.nil?
      @image.remove_alpha_channel! if options[:remove_alpha]

      @image.contrast!(options[:contrast]) if options[:contrast]
      @image.enhance! if options[:enhance]
      @image.modulate!(options[:brightness]) if options[:brightness]

      @image.crop!(options[:crop]) if options[:crop]
      @image.resize!(*options[:resize]) if options[:resize]

      # remove background
      if options[:extract_bkg]
        back_mask, = Xi::DIP::Preprocess::BackgroundMask.extract(
          @image.image, options[:extract_bkg])

        if display
          @image.recolor_boolean_mask!(back_mask)
          fg_img = File.join(
            Xi::DIP::Utils.dirname(image_file),
            "#{Xi::DIP::Utils.basename(image_file)}_without_background.png",
          )
          @image.save(fg_img)
          Xi::DIP.logger.info("Image without background saved under #{fg_img}")
        end

        @image.subimage_from_mask!(back_mask)
      end
    end
  end

  # Detect the main colors of the current image by means of color classification
  # Color features are extracted from current image
  # @param level [Symbol] which extraction level (:pixel / :region / :image)
  # @param ftype [Symbol] which features type (:value / :distance / :histogram)
  # @param fargs [Hash] the arguments associated to the feature type
  def color_histogram(level, ftype, fargs)
    return if @image.nil?

    @colors = []

    @rsize = 1
    @rsize = fargs[:size] if level == :region && fargs.key?(:size)

    if level == :image
      hcolors = color_probability(level, ftype, fargs)
    else
      hcolors = color_coverage(level, ftype, fargs)
    end

    hcolors.sort_by{|_, v| -v }.to_h
  end

  # Get the color probabilities of the current image
  # @param level [Symbol] which extraction level (:image)
  # @param ftype [Symbol] which features type (:value / :distance / :histogram)
  # @param fargs [Hash] the arguments associated to the feature type
  def color_probability(level, ftype, fargs)
    # only one features-array => color probability histogram

    hcolors = {}

    Xi::DIP::ColorDetector::Features.generator(
      @image, level, ftype, fargs) do |feat|

      prediction = @classifier.classify_doc(feat)[:probas]

      count = prediction.values.inject(:+)
      hcolors = prediction.map do |color, percentage|
        [color, (percentage / count * 100).round(2)]
      end.to_h
    end

    hcolors
  end

  # Get the color coverage percentages of the current image
  # @param level [Symbol] which extraction level (:pixel / :region)
  # @param ftype [Symbol] which features type (:value / :distance / :histogram)
  # @param fargs [Hash] the arguments associated to the feature type
  def color_coverage(level, ftype, fargs)
    # extract and classify each feature at a time => color coverage histogram
    count = 0

    hcolors = @clusters.each_with_object({}){|name, h| h[name] = 0.0 }

    Xi::DIP::ColorDetector::Features.generator(
      @image, level, ftype, fargs) do |feat|

      unless feat.nil? || feat.empty?
        prediction = @classifier.classify_doc(feat)
        color = prediction[:category]

        hcolors[color] += 1
        @colors << color
      end

      count += 1
    end

    hcolors.map{|k, v| [k, (v / count * 100).round(2)] }.to_h
  end

  # Create an image with recolored pixeles (for debugging)
  # @param output [String] the output png file
  # @param nclusters [Integer] the number of color clusters to use
  def draw_recolored_image(output, nclusters=12)
    img_height = @image.rows - @rsize + 1
    img_width = @image.columns - @rsize + 1
    img_size = img_height * img_width

    if @colors.nil? || @colors.empty? || @colors.size != img_size
      Xi::DIP.logger.warn('Image can not be recolored: '\
        "#{@colors.size} color(s) != #{img_size} pixel(s)")
      return
    end

    raise Xi::DIP::Error::ConfigError, \
      "Wrong value/type for number of colors: #{nclusters}" \
      unless Xi::DIP::Color::ColorMap::CLUSTERS.key?(nclusters)

    main_colors = Xi::DIP::Color::ColorMap::CLUSTERS[nclusters]

    index = 0
    nimage = Magick::Image.new(img_width, img_height)

    @image.image.each_pixel do |_, j, i|
      if j < img_width && i < img_height
        hex_color = main_colors.key(@colors[index])
        npixel = Xi::DIP::Color::Convertor.convert(hex_color, :pixel)

        nimage.pixel_color(j, i, npixel)
        index += 1
      end
    end

    Xi::DIP::Utils.create_path(output)
    nimage.write(output)
  end

  private :color_probability, :color_coverage
end
