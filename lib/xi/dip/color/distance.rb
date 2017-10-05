# encoding: utf-8

class Xi::DIP::Color::Distance

  WP_WEIGHTS = [0.3, 0.59, 0.11].freeze
  WN_WEIGHTS = [2.0, 4.0, 3.0].freeze

  # Compute the euclidean distance between two colors
  # @param v1 [Array] the color attributes of the first color
  # @param v2 [Array] the color attributes of the second color
  # @return [Float] the distance between the two colors
  def self.euclidean(v1, v2)
    n = v1.size

    sum = 0.0
    n.times{|i| sum += (v1[i] - v2[i])**2 }

    Math.sqrt(sum)
  end

  # Compute the weighted euclidean distance between two colors
  # @param v1 [Array] the color attributes of the first color
  # @param v2 [Array] the color attributes of the second color
  # @param weights [Array] the color weights
  # @return [Float] the weighted distance between the two colors
  def self._weighted_euclidean(v1, v2, weights)
    n = v1.size

    return 0.0 if n != weights.size

    sum = 0.0
    n.times{|i| sum += weights[i] * (v1[i] - v2[i])**2 }

    Math.sqrt(sum)
  end


  # Compute the WP weighted euclidean distance between two colors
  # @param v1 [Array] the color attributes of the first color
  # @param v2 [Array] the color attributes of the second color
  # @return [Float] the weighted distance between the two colors
  def self.euclidean_wp(v1, v2)
    _weighted_euclidean(v1, v2, WP_WEIGHTS)
  end

  # Compute the WN weighted euclidean distance between two colors
  # @param v1 [Array] the color attributes of the first color
  # @param v2 [Array] the color attributes of the second color
  # @return [Float] the weighted distance between the two colors
  def self.euclidean_wn(v1, v2)
    _weighted_euclidean(v1, v2, WN_WEIGHTS)
  end

  # Get radians from degrees
  def self.radians(degrees)
    degrees * Math::PI / 180
  end

  # Get degrees from radians
  def self.degrees(radians)
    radians * 180 / Math::PI
  end

  # Compute the color difference delta E (CIE 2000)
  # @param v1 [Array] the LAB color attributes of the first color
  # @param v2 [Array] the LAB color attributes of the second color
  # @return [Float] the distance between the two colors
  def self.delta_e(v1, v2)
    l1, a1, b1 = v1
    l2, a2, b2 = v2

    kl = kc = kh = 1

    avg_lp = (l1 + l2) / 2.0
    c1 = Math.sqrt(a1**2 + b1**2)
    c2 = Math.sqrt(a2**2 + b2**2)
    avg_c1_c2 = (c1 + c2) / 2.0

    g = 0.5 * \
      (1 - Math.sqrt((avg_c1_c2**7.0) / ((avg_c1_c2**7.0) + (25.0**7.0))))

    a1p = (1.0 + g) * a1
    a2p = (1.0 + g) * a2

    c1p = Math.sqrt((a1p**2) + (b1**2))
    c2p = Math.sqrt((a2p**2) + (b2**2))
    avg_c1p_c2p = (c1p + c2p) / 2.0

    h1p = ([b1, a1p] == [0.0, 0.0]) ? 0.0 : degrees(Math.atan2(b1, a1p))
    h1p += 360 if h1p < 0

    h2p = ([b2, a2p] == [0.0, 0.0]) ? 0.0 : degrees(Math.atan2(b2, a2p))
    h2p += 360 if h2p < 0

    if (h1p - h2p).abs > 180
      avg_hp = (h1p + h2p + 360) / 2.0
    else
      avg_hp = (h1p + h2p) / 2.0
    end

    t = 1 - 0.17 * \
      Math.cos(radians(avg_hp - 30)) + 0.24 * Math.cos(radians(2 * avg_hp)) + \
      0.32 * Math.cos(radians(3 * avg_hp + 6)) - \
      0.2 * Math.cos(radians(4 * avg_hp - 63))

    diff_h2p_h1p = h2p - h1p
    if diff_h2p_h1p.abs <= 180
      delta_hp = diff_h2p_h1p
    elsif diff_h2p_h1p.abs > 180 && h2p <= h1p
      delta_hp = diff_h2p_h1p + 360
    else
      delta_hp = diff_h2p_h1p - 360
    end

    delta_lp = l2 - l1
    delta_cp = c2p - c1p
    delta_hp = 2 * Math.sqrt(c2p * c1p) * Math.sin(radians(delta_hp) / 2.0)

    s_l = 1 + \
      ((0.015 * ((avg_lp - 50)**2)) / Math.sqrt(20 + ((avg_lp - 50)**2.0)))
    s_c = 1 + 0.045 * avg_c1p_c2p
    s_h = 1 + 0.015 * avg_c1p_c2p * t

    delta_ro = 30 * Math.exp(-((((avg_hp - 275) / 25)**2.0)))

    r_c = Math.sqrt(
      ((avg_c1p_c2p**7.0)) / ((avg_c1p_c2p**7.0) + (25.0**7.0)))

    r_t = -2 * r_c * Math.sin(2 * radians(delta_ro))

    delta_e = Math.sqrt(
      ((delta_lp / (s_l * kl))**2) + \
      ((delta_cp / (s_c * kc))**2) + \
      ((delta_hp / (s_h * kh))**2) + \
      r_t * (delta_cp / (s_c * kc)) * (delta_hp / (s_h * kh)))

    delta_e
  end

  private_class_method :_weighted_euclidean
end
