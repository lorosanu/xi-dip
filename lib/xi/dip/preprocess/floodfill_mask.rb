# encoding: utf-8


# Detect the pixels belonging to the background:
#  - detect the edges of the image
#  - use a flood fill starting from all corners up to the edges
class Xi::DIP::Preprocess::FloodFillMask

  CORNERS = [[0, 0], [0, -1], [-1, 0], [-1, -1]].freeze

  # Extract a flood fill mask from an image
  # @param image [Magick::Image] the given image
  # @param gray_threshold [Float] background pixels have a lower gray lightness
  # @param remap [Boolean] whether or not to remap image on 31 predefined colors
  # @return [Array] the 2D boolean mask array
  def self.extract(image, gray_threshold:0.05, remap:false)
    cimage = image.dup

    # remap image on 31 predefined colors, if requested
    if remap
      colormap = Xi::DIP::Color::ColorMap.image_from_colors(31)
      cimage = cimage.remap(colormap, Magick::NoDitherMethod)
    end

    # edge detection
    cimage = cimage
      .negate
      .quantize(256, Magick::GRAYColorspace)
      .enhance
      .reduce_noise(3)
      .edge

    # mask on edges
    lmask = self.lightness_mask_from_edges(cimage)

    # binary thresholding: label ~edges with 'false', ~background with 'true'
    bmask = lmask.map{|a| a.map{|x| x <= gray_threshold } }

    # make edges thicker ('true' pixels)
    bmask = self.erode(self.dilate(bmask, false, 3), false, 1)

    # label image borders with 'true'
    bmask[0].map!{ true }
    bmask[-1].map!{ true }
    bmask.each{|a| a[0], a[-1] = true, true }

    # label adjacent pixels of the same value
    labels = self.label_boolean_regions(bmask)

    # count as background all pixels labeled like the ones in the corners
    labels_corners = CORNERS.map{|i, j| labels[i][j] }.uniq

    # final mask: label background pixels outside of edges
    nmask = Array.new(cimage.rows){ Array.new(cimage.columns, false) }
    cimage.rows.times do |i|
      cimage.columns.times do |j|
        nmask[i][j] = labels_corners.include?(labels[i][j])
      end
    end

    # remove remaining inner edges: erode & dilate
    self.erode(self.dilate(nmask))
  end

  # Return each pixel's lightness from a gray-scale edge image
  # @param image [Magick::Image] the given image
  # @return [Array] the lightness mask
  def self.lightness_mask_from_edges(image)
    mask = Array.new(image.rows){ Array.new(image.columns) }
    image.each_pixel{|pixel, j, i| mask[i][j] = pixel.to_HSL[-1].round(3) }

    mask
  end

  # Label adjacent pixels of the same color
  # @param mask [Array] the given edge mask
  # @return [Array] the 2D color map
  def self.label_boolean_regions(mask, connectivity=4)
    nrows, ncols = mask.size, mask[0].size

    # define the possible neighboring positions based on connectivity type
    neighbor_coordinates = select_neighbors(connectivity)

    relabel = true

    # initialize labels
    labels = Array.new(nrows){ Array.new(ncols) }
    labels[0].map!{ 1 }
    labels[-1].map!{ 1 }
    labels.each{|a| a[0], a[-1] = 1, 1 }

    # initialize number of different regions
    count_regions = 1

    npass = 1
    while relabel
      Xi::DIP.logger.info("FloodFill pass no. #{npass}")

      to_update = {}
      1.upto(nrows - 2) do |i|
        1.upto(ncols - 2) do |j|

          nvalues = neighbor_coordinates.map{|x, y| mask[i + x][j + y] }
          nlabels = neighbor_coordinates.map{|x, y| labels[i + x][j + y] }

          min_label, max_label = neighbor_labels(mask[i][j], nvalues, nlabels)

          if min_label == -1
            # has no matching neighbors
            if labels[i][j].nil?
              count_regions += 1
              labels[i][j] = count_regions
            end
          else
            # has matching neighbors
            labels[i][j] = min_label

            # request map update if neighboring pixels have different labels
            if max_label != min_label
              if to_update.key?(max_label)
                to_update[max_label] = [min_label, to_update[max_label]].min
              else
                to_update[max_label] = min_label
              end
            end
          end

        end
      end

      if to_update.empty?
        relabel = false
      else
        # update needed
        to_update.each do |k, val|
          to_update[k] = to_update[val] \
            if to_update.key?(val) && to_update[val] < val
        end

        # second pass
        nrows.times do |i|
          ncols.times do |j|
            if to_update.key?(labels[i][j])
              labels[i][j] = to_update[labels[i][j]]
            end
          end
        end
      end

      npass += 1
    end

    labels
  end

  # Return the coordinates of the requested neighbors
  # @param connectivity [Integer] the connectivity type
  # @return [Array] the neighbor's coordinates
  def self.select_neighbors(connectivity=4)
    case connectivity
    when 4
      return [[-1, 0], [0, -1]]
    when 8
      return [[-1, -1], [-1, 0], [-1, 1], [0, -1]]
    else
      raise Xi::DIP::Error::ConfigError, \
        "Connectivity must be of value 4 or 8. #{connectivity} given."
    end
  end

  # Return the labels of neighboring pixels having same value as current pixel
  # @param cvalue [Boolean] the current pixel's boolean value
  # @param neighbors [Array] the current pixel's neighboring booleans
  # @param labels [Array] the current pixel's neighboring labels
  # @return [Integer, Integer] the requested neighbors
  def self.neighbor_labels(cvalue, neighbors, labels)
    nlabels = []
    neighbors.each_with_index do |value, lindex|
      nlabels << labels[lindex] if value == cvalue && !labels[lindex].nil?
    end

    return -1, -1 if nlabels.empty?
    return nlabels.min, nlabels.max
  end

  # Erode the given boolean mask
  # @param mask [Array] given boolean mask
  # @return [Array] new boolean mask
  def self.erode(mask, value=true, radius=1)
    nrows = mask.size
    ncols = mask[0].size

    eroded = Array.new(nrows){ Array.new(ncols, !value) }
    nrows.times do |i|
      ncols.times do |j|
        if mask[i][j] == value
          check = true

          (i - radius).upto(i + radius) do |m|
            (j - radius).upto(j + radius) do |n|
              if m >= 0 && m <= nrows - 1 && n >= 0 && n <= ncols - 1
                check = false unless mask[m][n] == value
              end
            end
          end

          eroded[i][j] = value if check
        end
      end
    end

    eroded
  end

  # Dilate the given boolean mask
  # @param mask [Array] given boolean mask
  # @return [Array] new boolean mask
  def self.dilate(mask, value=true, radius=1)
    nrows = mask.size
    ncols = mask[0].size

    dilated = Array.new(nrows){ Array.new(ncols, !value) }
    nrows.times do |i|
      ncols.times do |j|
        if mask[i][j] == value

          (i - radius).upto(i + radius) do |m|
            (j - radius).upto(j + radius) do |n|
              if m >= 0 && m <= nrows - 1 && n >= 0 && n <= ncols - 1
                dilated[m][n] = value
              end
            end
          end

        end
      end
    end

    dilated
  end

end
