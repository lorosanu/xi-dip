# encoding: utf-8

class Xi::DIP::Color::Convertor

  SPACES = [:pixel, :hex, :rgb, :hsl, :hsv, :yiq, :xyz, :lab, :rgbc].freeze

  RANGES = {
    :rgb => [0.0..1.0, 0.0..1.0, 0.0..1.0],
    :hsl => [0.0..1.0, 0.0..1.0, 0.0..1.0],
    :hsv => [0.0..1.0, 0.0..1.0, 0.0..1.0],
    :yiq => [0.0..1.0, 0.0..1.0, 0.0..1.0],
    :xyz => [0.0..1.0, 0.0..1.0, 0.0..1.0],
    :lab => [0..100, -128..128, -128..128],
  }.freeze

  # Check for a valid input
  # @param color [Magick::Pixel] the given color object
  def self.validate_input(color)
    raise Xi::DIP::Error::ConfigError, \
      "Bad input: #{color}. Expected Magick::Pixel, Array[3] or String(7)"\
      unless color.is_a?(Magick::Pixel) || \
        (color.is_a?(Array) && color.size == 3) || \
        (color.is_a?(String) && color.size == 7 && color.start_with?('#'))
  end

  # Check for a valid color space
  # @param space [Symbol] the given color space
  def self.validate_colorspace(space)
    raise Xi::DIP::Error::ConfigError, \
      "Bad color space: #{space}. Expected: #{SPACES}" \
      unless SPACES.include?(space)
  end

  # Convert color into an other color space or color format
  # @param color [Magick::Pixel] the given color
  # @param space [Symbol] the new color space
  # @return [Array] the array of converted values
  def self.convert(color, space)
    method = :"to_#{space}"

    begin
      case color
      when Magick::Pixel
        return Xi::DIP::Color::Pixel.__send__(method, color)
      when String
        return Xi::DIP::Color::Hex.__send__(method, color)
      when Array
        return Xi::DIP::Color::RGB.__send__(method, color)
      end
    rescue => e
      raise Xi::DIP::Error::CaughtException, \
        "Exception encountered when converting to #{space}: #{e.message}"
    end
  end

  # Convert array of rgb values into an other color space
  # @param rgb_values [Array] the array of RGB values
  # @param space [Symbol] the new color space
  # @return [Array] the array of converted pixels
  def self.convert_array(rgb_values, space)
    method = :"to_#{space}"

    begin
      rgb_values.map{|rgb| Xi::DIP::Color::RGB.__send__(method, rgb) }
    rescue => e
      raise Xi::DIP::Error::CaughtException, \
        "Exception encountered when converting array to #{space}: #{e.message}"
    end
  end

  # Convert array of multiple rgb values into an other color space
  # @param rgb_values [Array] the array of several flat RGB values
  # @param space [Symbol] the new color space
  # @return [Array] the array of converted pixels
  def self.convert_region_array(rgb_values, space)
    method = :"to_#{space}"
    nimage = []

    begin
      rgb_values.each do |region|
        rvalues = []
        region.each_slice(3) do |rgb|
          rvalues.concat(Xi::DIP::Color::RGB.__send__(method, rgb))
        end
        nimage << rvalues
      end
    rescue => e
      raise Xi::DIP::Error::CaughtException, \
        "Exception encountered when converting region to #{space}: #{e.message}"
    end

    nimage
  end
end
