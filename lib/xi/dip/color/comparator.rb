# encoding: utf-8

class Xi::DIP::Color::Comparator

  DISTANCES = [:euclidean, :euclidean_wp, :euclidean_wn, :delta_e].freeze

  # Check for a valid distance type
  # @param distance [Symbol] the distance type
  def self.validate_distance(distance)
    raise Xi::DIP::Error::ConfigError, \
      "Bad distance type: #{distance}. Expected: #{DISTANCES}" \
      unless DISTANCES.include?(distance)
  end

  # Compute the distance between two colors
  # @param color1 [Array] the first color values
  # @param color2 [Array] the second color values
  # @param distance [Symbol] the distance type
  # @return [Float] the distance between the two colors
  def self.compare(color1, color2, distance=:euclidean)
    Xi::DIP::Color::Distance.__send__(distance, color1, color2)
  end

  def self.convert_and_compare(color1, color2, distance=:euclidean)
    c1 = Xi::DIP::Color::Convertor.convert(color1, :rgb)
    c2 = Xi::DIP::Color::Convertor.convert(color2, :rgb)
    Xi::DIP::Color::Distance.__send__(distance, c1, c2)
  end

end
