# encoding: utf-8


class Xi::DIP::Color::Pixel

  def self.validate(color)
    raise Xi::DIP::Error::ConfigError, \
      "Bad input: #{color}. Expected Magick::Pixel" \
      unless color.is_a?(Magick::Pixel)
  end

  def self.to_pixel(color)
    color
  end

  def self.to_hex(color)
    hex = '#'
    hex << (color.red / 257).to_s(16).rjust(2, '0')
    hex << (color.green / 257).to_s(16).rjust(2, '0')
    hex << (color.blue / 257).to_s(16).rjust(2, '0')

    hex.upcase
  end

  def self.to_rgb(color)
    [color.red / 65_535.0, color.green / 65_535.0, color.blue / 65_535.0]
  end

  def self.to_hsl(color)
    rgb = to_rgb(color)
    Xi::DIP::Color::RGB.to_hsl(rgb)
  end

  def self.to_hsv(color)
    rgb = to_rgb(color)
    Xi::DIP::Color::RGB.to_hsv(rgb)
  end

  def self.to_yiq(color)
    rgb = to_rgb(color)
    Xi::DIP::Color::RGB.to_yiq(rgb)
  end

  def self.to_xyz(color)
    rgb = to_rgb(color)
    Xi::DIP::Color::RGB.to_xyz(rgb)
  end

  def self.to_lab(color)
    rgb = to_rgb(color)
    Xi::DIP::Color::RGB.to_lab(rgb)
  end

  def self.to_rgbc(color)
    rgb = to_rgb(color)
    Xi::DIP::Color::RGB.to_rgbc(rgb)
  end
end
