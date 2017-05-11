# encoding: utf-8


# Detect pixels within the image having similar colors as the corner pixels
class Xi::DIP::Preprocess::SimCornersMask

  # Label as backgroun every pixel having a similar color as the corner pixels
  # @param image [Magick::Image] the given image
  # @param max_distance [Float] colors are similar in case of smaller distance
  # @param remap [Boolean] whether or not to remap image on 31 predefined colors
  # @return [Array] the 2D boolean mask array
  def self.extract(image, max_distance:0.1, remap:false)
    nrows, ncols = image.rows, image.columns
    cimage = image.dup

    # remap image on 31 predefined colors, if requested
    if remap
      colormap = Xi::DIP::Color::ColorMap.image_from_colors(31)
      cimage = cimage.remap(colormap, Magick::NoDitherMethod)
    end

    # extract rgb float values from the image
    img_colors = cimage.dispatch(0, 0, ncols, nrows, 'RGB', true)
    img_colors = img_colors.each_slice(3).to_a

    # recover corner coordinates from flat RGB array
    corners = [
      0,
      ncols - 1,
      (nrows - 1) * ncols,
      nrows * ncols - 1,
    ]

    corner_colors = corners.map{|cindex| img_colors[cindex] }

    # compute euclidean distance of each pixel against corner pixels
    mask = Array.new(nrows){ Array.new(ncols, false) }

    img_colors.each_with_index do |image_color, cindex|
      i = cindex / cimage.columns
      j = cindex % cimage.columns
      corner_colors.each do |corner_color|
        dist = Xi::DIP::Color::Comparator.compare(image_color, corner_color)
        mask[i][j] = true if dist < max_distance
      end
    end

    mask
  end
end
