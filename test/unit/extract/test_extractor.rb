# encoding: utf-8


require 'minitest/autorun'

$LOAD_PATH.unshift 'lib/'
require 'xi/dip'

class ExtractorTest < Minitest::Unit::TestCase

  def setup
    @img_file = File.join('data', 'car.jpg')
    Xi::DIP::Utils.check_file_readable!(@img_file)

    @extractor = Xi::DIP::ColorExtractor::Extractor.new()
  end

  def test_extract_rgb_euclidean_31
    rcolors = {
      'grey' => 30.78,
      'grey|lightGrey' => 27.78,
      'black' => 19.99,
      'brown' => 8.12,
      'brown|darkBrown' => 7.23,
      'blue|lightBlue' => 2.88,
      'brown|lightBrown' => 2.44,
      'red|lightRed' => 0.59,
      'cyan|darkCyan' => 0.08,
      'yellow|darkYellow' => 0.08,
      'yellow' => 0.03,
      'chartreuse|darkChartreuse' => 0.0,
      'red|darkRed' => 0.0,
      'chartreuse' => 0.0,
      'chartreuse|lightChartreuse' => 0.0,
      'yellow|lightYellow' => 0.0,
      'green' => 0.0,
      'green|lightGreen' => 0.0,
      'green|darkGreen' => 0.0,
      'cyan' => 0.0,
      'cyan|lightCyan' => 0.0,
      'red' => 0.0,
      'blue' => 0.0,
      'white' => 0.0,
      'blue|darkBlue' => 0.0,
      'magenta' => 0.0,
      'magenta|lightMagenta' => 0.0,
      'magenta|darkMagenta' => 0.0,
      'pink' => 0.0,
      'pink|lightPink' => 0.0,
      'pink|darkPink' => 0.0,
    }

    @extractor.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [100, 100] })
    gcolors = @extractor.color_histogram(31, :rgb, :euclidean)

    assert_equal rcolors, gcolors
  end

  def test_extract_rgb_euclidean_31_remap
    # same results as rmagick's remap + color_histogram method
    rcolors = {
      'grey' => 30.78,
      'grey|lightGrey' => 27.78,
      'black' => 19.99,
      'brown' => 8.12,
      'brown|darkBrown' => 7.23,
      'blue|lightBlue' => 2.88,
      'brown|lightBrown' => 2.44,
      'red|lightRed' => 0.59,
      'cyan|darkCyan' => 0.08,
      'yellow|darkYellow' => 0.08,
      'yellow' => 0.03,
      'chartreuse|darkChartreuse' => 0.0,
      'red|darkRed' => 0.0,
      'chartreuse' => 0.0,
      'chartreuse|lightChartreuse' => 0.0,
      'yellow|lightYellow' => 0.0,
      'green' => 0.0,
      'green|lightGreen' => 0.0,
      'green|darkGreen' => 0.0,
      'cyan' => 0.0,
      'cyan|lightCyan' => 0.0,
      'red' => 0.0,
      'blue' => 0.0,
      'white' => 0.0,
      'blue|darkBlue' => 0.0,
      'magenta' => 0.0,
      'magenta|lightMagenta' => 0.0,
      'magenta|darkMagenta' => 0.0,
      'pink' => 0.0,
      'pink|lightPink' => 0.0,
      'pink|darkPink' => 0.0,
    }

    @extractor.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [100, 100] })
    gcolors = @extractor.color_histogram(31, :rgb, :euclidean)

    assert_equal rcolors, gcolors
  end

  def test_extract_hsl_euclidean_31
    rcolors = {
      'grey' => 29.09,
      'grey|lightGrey' => 19.22,
      'black' => 17.19,
      'brown' => 16.74,
      'blue|lightBlue' => 10.74,
      'brown|darkBrown' => 2.83,
      'magenta' => 1.06,
      'blue' => 0.93,
      'blue|darkBlue' => 0.81,
      'brown|lightBrown' => 0.26,
      'yellow|darkYellow' => 0.26,
      'yellow' => 0.21,
      'chartreuse|darkChartreuse' => 0.17,
      'green|darkGreen' => 0.16,
      'red|darkRed' => 0.12,
      'cyan|darkCyan' => 0.11,
      'yellow|lightYellow' => 0.06,
      'pink' => 0.03,
      'pink|darkPink' => 0.01,
      'cyan' => 0.0,
      'cyan|lightCyan' => 0.0,
      'green|lightGreen' => 0.0,
      'green' => 0.0,
      'chartreuse|lightChartreuse' => 0.0,
      'chartreuse' => 0.0,
      'red|lightRed' => 0.0,
      'magenta|lightMagenta' => 0.0,
      'magenta|darkMagenta' => 0.0,
      'red' => 0.0,
      'pink|lightPink' => 0.0,
      'white' => 0.0,
    }

    @extractor.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [100, 100] })
    gcolors = @extractor.color_histogram(31, :hsl, :euclidean)

    assert_equal rcolors, gcolors
  end

  def test_extract_lab_euclidean_31
    rcolors = {
      'grey' => 30.71,
      'grey|lightGrey' => 27.00,
      'black' => 19.85,
      'brown' => 6.46,
      'brown|darkBrown' => 5.79,
      'blue|lightBlue' => 3.94,
      'yellow|darkYellow' => 2.77,
      'brown|lightBrown' => 2.73,
      'yellow|lightYellow' => 0.69,
      'cyan' => 0.03,
      'cyan|darkCyan' => 0.03,
      'chartreuse|darkChartreuse' => 0.0,
      'red|darkRed' => 0.0,
      'chartreuse' => 0.0,
      'chartreuse|lightChartreuse' => 0.0,
      'yellow' => 0.0,
      'green' => 0.0,
      'green|lightGreen' => 0.0,
      'green|darkGreen' => 0.0,
      'red|lightRed' => 0.0,
      'cyan|lightCyan' => 0.0,
      'red' => 0.0,
      'blue' => 0.0,
      'white' => 0.0,
      'blue|darkBlue' => 0.0,
      'magenta' => 0.0,
      'magenta|lightMagenta' => 0.0,
      'magenta|darkMagenta' => 0.0,
      'pink' => 0.0,
      'pink|lightPink' => 0.0,
      'pink|darkPink' => 0.0,
    }

    @extractor.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [100, 100] })
    gcolors = @extractor.color_histogram(31, :lab, :euclidean)

    assert_equal rcolors, gcolors
  end
end
