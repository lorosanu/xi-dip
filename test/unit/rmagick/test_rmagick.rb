# encoding: utf-8


require 'minitest/autorun'

$LOAD_PATH.unshift 'lib/'
require 'xi/dip'

class RmagickTest < Minitest::Unit::TestCase

  def setup
    img_file = File.join('data', 'car.jpg')
    Xi::DIP::Utils.check_file_readable!(img_file)

    @image = Xi::DIP::Image.new(img_file)
  end

  def test_color_shades
    rcolors = {
      'grey|lightGrey' => 28.33,
      'grey' => 26.58,
      'black' => 23.51,
      'brown|darkBrown' => 7.91,
      'brown' => 7.08,
      'blue|lightBlue' => 2.96,
      'brown|lightBrown' => 2.76,
      'red|lightRed' => 0.61,
      'white' => 0.09,
      'cyan|darkCyan' => 0.08,
      'yellow|darkYellow' => 0.06,
      'yellow' => 0.02,
      'red|darkRed' => 0.0,
      'yellow|lightYellow' => 0.0,
      'chartreuse|darkChartreuse' => 0.0,
      'chartreuse' => 0.0,
      'chartreuse|lightChartreuse' => 0.0,
      'green' => 0.0,
      'green|lightGreen' => 0.0,
      'green|darkGreen' => 0.0,
      'cyan' => 0.0,
      'cyan|lightCyan' => 0.0,
      'blue' => 0.0,
      'red' => 0.0,
      'blue|darkBlue' => 0.0,
      'magenta' => 0.0,
      'magenta|lightMagenta' => 0.0,
      'magenta|darkMagenta' => 0.0,
      'pink' => 0.0,
      'pink|lightPink' => 0.0,
      'pink|darkPink' => 0.0,
    }

    gcolors = @image.color_histogram(31)
    assert_equal rcolors, gcolors
  end

  def test_main_colors
    rcolors = {
      'grey' => 54.91,
      'black' => 23.51,
      'brown' => 17.75,
      'blue' => 2.96,
      'red' => 0.62,
      'white' => 0.09,
      'cyan' => 0.08,
      'yellow' => 0.08,
      'chartreuse' => 0.0,
      'green' => 0.0,
      'magenta' => 0.0,
      'pink' => 0.0,
    }

    gcolors = @image.maincolor_histogram(31)
    assert_equal rcolors, gcolors
  end
end
