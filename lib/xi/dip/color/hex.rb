# encoding: utf-8


class Xi::DIP::Color::Hex

  def self.validate(color)
    raise Xi::DIP::Error::ConfigError, \
      "Bad input: #{color}. Expected String(7)" \
      unless color.is_a?(String) && color.size == 7 && color.start_with?('#')
  end

  def self.to_pixel(color)
    ncolor = color.delete('#').scan(/../)
    ncolor.map!{|x| x.to_i(16) * 257 }

    Magick::Pixel.new(*ncolor)
  end

  def self.to_hex(color)
    color
  end

  def self.to_rgb(color)
    ncolor = color.delete('#').scan(/../)
    ncolor.map{|x| x.to_i(16) / 255.0 }
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
