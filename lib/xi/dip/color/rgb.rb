# encoding: utf-8


class Xi::DIP::Color::RGB

  def self.validate(color)
    raise Xi::DIP::Error::ConfigError, \
      "Bad input: #{color}. Expected Array[3]" \
      unless color.is_a?(Array) && color.size == 3
  end

  def self.to_pixel(color)
    ncolor = color.map{|x| (x * 65_535.0).to_i }
    Magick::Pixel.new(*ncolor)
  end

  def self.to_hex(color)
    hex = '#'
    hex << color.map{|x| (x * 255).to_i.to_s(16).rjust(2, '0') }.join('')
    hex.upcase
  end

  def self.to_rgb(color)
    color
  end

  def self.to_hsl(color)
    r, g, b = color

    cmax = color.max
    cmin = color.min
    delta = cmax - cmin

    l = (cmax + cmin) / 2.0

    h = nil

    if delta == 0
      h = 0
    elsif cmax == r
      h = 60 * (((g - b) / delta) % 6)
    elsif cmax == g
      h = 60 * (((b - r) / delta) + 2)
    else
      h = 60 * (((r - g) / delta) + 4)
    end

    s = (delta == 0) ? 0.0 : (delta / (1 - (2 * l - 1).abs))

    # real HSL values: [h, s * 100.0, l * 100.0]
    [h / 360.0, s, l]
  end

  def self.to_hsv(color)
    r, g, b = color

    cmax = color.max
    cmin = color.min
    delta = cmax - cmin

    h = nil

    if delta == 0
      h = 0
    elsif cmax == r
      h = 60 * (((g - b) / delta) % 6)
    elsif cmax == g
      h = 60 * (((b - r) / delta) + 2)
    else
      h = 60 * (((r - g) / delta) + 4)
    end

    s = (cmax == 0) ? 0.0 : (delta / cmax)

    # real HSV values: [h, s * 100.0, cmax * 100.0]
    [h / 360.0, s, cmax]
  end

  def self.to_yiq(color)
    r, g, b = color

    y = r * 0.299 + g * 0.587 + b * 0.114
    i = r * 0.596 - g * 0.275 - b * 0.321
    q = r * 0.212 - g * 0.523 + b * 0.311

    y = 0.0 if y < 0
    i = 0.0 if i < 0
    q = 0.0 if q < 0

    # real YIQ values: [y * 100.0, i * 100.0, q * 100.0]
    [y, i, q]
  end

  def self.to_xyz(color)
    r, g, b = color

    r = (r <= 0.04045) ? r / 12.92 : ((r + 0.055) / 1.055)**2.4
    g = (g <= 0.04045) ? g / 12.92 : ((g + 0.055) / 1.055)**2.4
    b = (b <= 0.04045) ? b / 12.92 : ((b + 0.055) / 1.055)**2.4

    r *= 100
    g *= 100
    b *= 100

    x = 0.412453 * r + 0.357580 * g + 0.180423 * b
    y = 0.212671 * r + 0.715160 * g + 0.072169 * b
    z = 0.019334 * r + 0.119193 * g + 0.950227 * b

    [x, y, z]
  end

  def self.to_lab(color)
    x, y, z = to_xyz(color)

    x /= 95.047
    y /= 100.000
    z /= 108.883

    x = (x > 0.008856) ? (x**(1.0 / 3)) : ((7.787 * x) + (16.0 / 116))
    y = (y > 0.008856) ? (y**(1.0 / 3)) : ((7.787 * y) + (16.0 / 116))
    z = (z > 0.008856) ? (z**(1.0 / 3)) : ((7.787 * z) + (16.0 / 116))

    l = (116.0 * y) - 16.0
    a = 500.0 * (x - y)
    b = 200.0 * (y - z)

    [l, a, b]
  end

  def self.to_rgbc(color)
    _, a, b = to_lab(color)
    chroma = Math.sqrt(a**2 + b**2)
    color << chroma
  end
end
