# encoding: utf-8


class Xi::DIP::ColorExtractor::Extractor
  attr_reader :image, :colors

  # Load and preprocess image
  # @param image_file [String] the given image
  # @param options [Hash] which preprocessing techniques to apply on the image
  def preprocess_image(image_file, options=nil)
    @image = Xi::DIP::Image.new(image_file)

    unless options.nil?
      @image.remove_alpha_channel! if options[:remove_alpha]
      @image.crop!(options[:crop]) if options[:crop]
      @image.resize!(*options[:resize]) if options[:resize]
      @image.posterize!(*options[:posterize]) if options[:posterize]
      @image.remap!(options[:remap]) if options[:remap]

      # remove background
      if options[:extract_bkg]
        back_mask, = Xi::DIP::Preprocess::BackgroundMask.extract(
          @image.image, options[:extract_bkg])

        @image.subimage_from_mask!(back_mask)
      end
    end
  end

  # Manually extract the histogram of main colors in given image
  # @param nclusters [Integer] the number of color clusters to use
  # @param cspace [Symbol] compare colors into an other color space
  # @param distance [Symbol] choose the distance type
  # @return [Hash] the color histogram
  def color_histogram(nclusters=31, cspace=:rgb, distance=:euclidean)
    rimage = @image.extract_rgb()
    cimage = Xi::DIP::Color::ColorMap.rgb_from_colors(nclusters)

    # change the color space
    if cspace != :rgb
      rimage = Xi::DIP::Color::Convertor.convert_array(rimage, cspace)
      cimage = Xi::DIP::Color::Convertor.convert_array(cimage, cspace)
    end

    # get the color names
    color_names = Xi::DIP::Color::ColorMap::CLUSTERS[nclusters].values

    # extract colors
    histo = color_names.each_with_object({}){|cname, h| h[cname] = 0.0 }

    @colors = rimage.map do |image_color|
      best_cluster_score = Float::MAX
      best_cluster_idx = -1

      cimage.each_with_index do |cluster_color, cluster_idx|
        d = Xi::DIP::Color::Comparator.compare(
          image_color, cluster_color, distance)

        if d < best_cluster_score
          best_cluster_score = d
          best_cluster_idx = cluster_idx
        end
      end

      # count color occurrences
      best_colorname = color_names[best_cluster_idx]
      histo[best_colorname] += 1

      best_colorname
    end

    size = @image.size * 1.0
    histo = histo.map{|cname, count| [cname, (count / size * 100).round(2)] }

    histo.sort_by{|_, v| -v }.to_h
  end

  # Create an image with recolored pixeles
  # @param output [String] the output png file
  # @param nclusters [Integer] the number of color clusters to use
  def draw_recolored_image(output, nclusters=31)
    return if @colors.nil? || @colors.empty? || @colors.size != @image.size

    main_colors = Xi::DIP::Color::ColorMap::CLUSTERS[nclusters]

    index = 0
    nimage = Magick::Image.new(@image.columns, @image.rows)

    @image.image.each_pixel do |_, j, i|
      hex_color = main_colors.key(@colors[index])
      npixel = Xi::DIP::Color::Convertor.convert(hex_color, :pixel)

      nimage.pixel_color(j, i, npixel)
      index += 1
    end

    Xi::DIP::Utils.create_path(output)
    nimage.write(output)
  end
end
