# encoding: utf-8

class Xi::DIP::Color::ColorMap

  CLUSTERS = {
    12 => {
      '#FFFFFF' => 'white',
      '#000000' => 'black',
      '#616161' => 'gray',
      '#FF0000' => 'red',
      '#00B300' => 'green',
      '#0000FF' => 'blue',
      '#008B8B' => 'cyan',
      '#8B5A2B' => 'brown',
      '#FFFF00' => 'yellow',
      '#FFA500' => 'orange',
      '#FF1493' => 'pink',
      '#8A2BE2' => 'purple',
    },
    13 => {
      '#FFFFFF' => 'white',
      '#000000' => 'black',
      '#616161' => 'gray',
      '#FF0000' => 'red',
      '#00B300' => 'green',
      '#0000FF' => 'blue',
      '#008B8B' => 'cyan',
      '#8B5A2B' => 'brown',
      '#FFFF00' => 'yellow',
      '#FFA500' => 'orange',
      '#FF1493' => 'pink',
      '#8A2BE2' => 'purple',
      '#FFE0BD' => 'skin',
    },
    31 => {
      '#FFFFFF' => 'white',
      '#000000' => 'black',
      '#404040' => 'grey',
      '#BFBFBF' => 'grey|lightGrey',
      '#FF0000' => 'red',
      '#FFA2A2' => 'red|lightRed',
      '#A60000' => 'red|darkRed',
      '#CC8019' => 'brown',
      '#FFD0A2' => 'brown|lightBrown',
      '#A65300' => 'brown|darkBrown',
      '#FFF200' => 'yellow',
      '#FFFFA2' => 'yellow|lightYellow',
      '#A6A600' => 'yellow|darkYellow',
      '#80FF00' => 'chartreuse',
      '#D0FFA2' => 'chartreuse|lightChartreuse',
      '#53A600' => 'chartreuse|darkChartreuse',
      '#00FF40' => 'green',
      '#A2FFB9' => 'green|lightGreen',
      '#00A629' => 'green|darkGreen',
      '#00ADEF' => 'cyan',
      '#A2FFFF' => 'cyan|lightCyan',
      '#00A6A6' => 'cyan|darkCyan',
      '#0000FF' => 'blue',
      '#A2B9FF' => 'blue|lightBlue',
      '#0029A6' => 'blue|darkBlue',
      '#800080' => 'magenta',
      '#D0A2FF' => 'magenta|lightMagenta',
      '#5300A6' => 'magenta|darkMagenta',
      '#EC008C' => 'pink',
      '#FFA2E8' => 'pink|lightPink',
      '#A6007C' => 'pink|darkPink',
    },
  }.freeze

  # Check for a valid number of clusters
  def self.validate_cluster(nclusters)
    raise Xi::DIP::Error::ConfigError, \
      "Bad number of clusters: #{nclusters}. Expected: #{CLUSTERS.keys}" \
      unless CLUSTERS.key?(nclusters)
  end

  # Generate an array of RGB float values from the clustered colors
  # @param nclusters [Integer] the number of color clusters to use
  # @return [Array] the array of RGB float values of each basic color
  def self.rgb_from_colors(nclusters=31)
    colors = CLUSTERS[nclusters].keys
    colors.map!{|c| Xi::DIP::Color::Hex.to_rgb(c) }
    colors
  end

  # Create an image from the clustered colors
  # @param nclusters [Integer] the number of color clusters to use
  # @return [Magick::Image] the image with 'nclusters' pixels
  def self.image_from_colors(nclusters=31)
    colors = CLUSTERS[nclusters].keys
    cimage = Magick::Image.new(1, colors.size)
    colors.each_with_index{|c, i| cimage.pixel_color(0, i, c) }

    cimage
  end

  # Create an image from the clustered colors and save it to file
  # @param nclusters [Integer] the number of color clusters to use
  # @param output [String] where to store the image
  def self.draw_image_from_colors(nclusters, output)
    cimage = image_from_colors(nclusters)

    Xi::DIP::Utils.create_path(output)
    cimage.write(output)
  end
end
