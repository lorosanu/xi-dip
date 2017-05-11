# encoding: utf-8


# Apply different float masks on an image to extract the image's background
class Xi::DIP::Preprocess::BackgroundMask

  # Apply the requested masks
  # @param image [Magick::Image] the given image
  # @param masks [Array] list of masks (hash of name and arguments)
  # @return [Array, Float] the 2D boolean mask, the coverage percentage
  def self.extract(image, masks)
    nrows = image.rows
    ncols = image.columns
    no_bkg_mask = Array.new(nrows){ Array.new(ncols, false) }

    return no_bkg_mask, 0.0 if masks.empty?
    Xi::DIP::Utils.validate_image(image)

    size = nrows * ncols
    max_true_cover = 80.0

    # apply masks
    @bmasks = []
    masks.each do |mask|        # each mask's hash
      m_name = mask[:name]      # mask name
      m_args = mask[:args]      # mask arguments

      begin
        @bmasks << {
          :name => m_name,
          :cover => 0.0,
          :content => Object.const_get(m_name).extract(image, m_args),
        }
      rescue => e
        raise Xi::DIP::Error::CaughtException, \
          "Failed to initialize class '#{m_name}': #{e.message}"
      end
    end

    # count the number of true values in each boolean mask
    @bmasks.each do |bmask|
      bmask[:cover] = percentage(count_true(bmask[:content]), size)
    end

    # sort masks in descending order of background cover
    @bmasks.sort_by!{|bmask| bmask[:cover] }.reverse!

    Xi::DIP.logger.info('Masks cover over total image size:')
    @bmasks.each do |bmask|
      Xi::DIP.logger.info("\t - Mask #{bmask[:name]}: #{bmask[:cover]}%")
    end

    # check if any mask is true at i,j coordinates
    # cont the number of true values in the global background boolean mask
    ng = 0
    background_mask = Array.new(nrows).fill do |i|
      Array.new(ncols).fill do |j|
        bool = @bmasks.any?{|bmask| bmask[:content][i][j] }
        ng += 1 if bool
        bool
      end
    end

    # check combined mask
    global_cover = percentage(ng, size)
    if global_cover < max_true_cover
      Xi::DIP.logger.info(
        "Applying all masks #{masks.map{|x| x[:name] }} (#{global_cover}%)")
      return background_mask, global_cover
    end

    # return the most invasive mask having cover < max_true_cover
    idx = @bmasks.find_index{|mask| mask[:cover] < max_true_cover }

    unless idx.nil?
      Xi::DIP.logger.info(
        "Applying mask #{@bmasks[idx][:name]} (#{@bmasks[idx][:cover]}%)")
      return @bmasks[idx][:content], @bmasks[idx][:cover]
    end

    # return entirely false 2D array
    Xi::DIP.logger.info('Applying no background mask (masks too invasive)')
    return no_bkg_mask, 0.0
  end

  def self.percentage(x, y)
    return -1 if y == 0
    (x * 1.0 / y * 100).round(2)
  end

  # Count the number of 'true' values in mask
  def self.count_true(mask)
    mask.inject(0){|sum, row| sum + row.count(true) }
  end

end
