# encoding: utf-8


require 'minitest/autorun'

$LOAD_PATH.unshift 'lib/'
require 'xi/dip'

class DetectorTest < Minitest::Unit::TestCase

  def setup
    @img_file = File.join('data', 'car.jpg')

    options = %w[
      pixel_value
      pixel_distance
      region-4x4_value
      region-64x64_histogram
      image_histogram
    ]

    @models = {}
    options.each do |option|
      mfile = File.join(File.dirname(__FILE__), "mlpclassifier_#{option}.json")
      Xi::DIP::Utils.check_file_readable!(mfile)

      @models[option] = mfile
    end
  end

  def test_detect_pixel_value
    rcolors = {
      'white' => 24.50,
      'black' => 17.21,
      'yellow' => 17.12,
      'gray' => 14.76,
      'brown' => 10.75,
      'cyan' => 5.60,
      'blue' => 5.31,
      'green' => 3.51,
      'purple' => 0.88,
      'orange' => 0.25,
      'red' => 0.09,
      'pink' => 0.02,
    }

    detector = Xi::DIP::ColorDetector::Detector.new(@models['pixel_value'])
    detector.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [100, 100] })

    gcolors = detector.color_histogram(
      :pixel,
      :value,
      { :colorspace => :rgb },
    )

    assert_equal rcolors, gcolors
  end

  def test_detect_pixel_distance
    rcolors = {
      'white' => 24.04,
      'yellow' => 17.98,
      'gray' => 15.82,
      'black' => 15.40,
      'blue' => 6.56,
      'brown' => 6.22,
      'cyan' => 5.63,
      'green' => 5.33,
      'red' => 2.64,
      'orange' => 0.19,
      'purple' => 0.18,
      'pink' => 0.01,
    }

    detector = Xi::DIP::ColorDetector::Detector.new(@models['pixel_distance'])
    detector.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [100, 100] })

    gcolors = detector.color_histogram(
      :pixel,
      :distance,
      { :nclusters => 12, :measure => :euclidean, :colorspace => :rgb }
    )

    assert_equal rcolors, gcolors
  end

  def test_detect_region_value
    rcolors = {
      'yellow' => 21.81,
      'white' => 20.65,
      'gray' => 13.83,
      'black' => 12.63,
      'blue' => 9.84,
      'green' => 7.25,
      'cyan' => 5.97,
      'brown' => 4.30,
      'red' => 3.57,
      'purple' => 0.15,
      'pink' => 0.0,
      'orange' => 0.0,
    }

    detector = Xi::DIP::ColorDetector::Detector.new(@models['region-4x4_value'])
    detector.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [100, 100] })

    gcolors = detector.color_histogram(
      :region,
      :value,
      { :size => 4, :sliding => true, :colorspace => :rgb }
    )

    assert_equal rcolors, gcolors
  end

=begin
  def test_detect_image_value
    rcolors = {
      'yellow' => 79.76,
      'white' => 13.23,
      'black' => 3.44,
      'gray' => 1.30,
      'pink' => 1.13,
      'green' => 0.63,
      'brown' => 0.35,
      'cyan' => 0.11,
      'orange' => 0.02,
      'purple' => 0.01,
      'red' => 0.0,
      'blue' => 0.0,
    }

    detector = Xi::DIP::ColorDetector::Detector.new(@models['image_value'])
    detector.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [64, 64] })

    gcolors = detector.color_histogram(
      :image,
      :value,
      { :colorspace => :rgb },
    )

    assert_equal rcolors, gcolors
  end

  def test_detect_image_value_from_regions
    rcolors = {
      'yellow' => 93.87,
      'green' => 5.1,
      'white' => 0.59,
      'gray' => 0.21,
      'brown' => 0.17,
      'orange' => 0.06,
      'cyan' => 0.0,
      'blue' => 0.0,
      'red' => 0.0,
      'black' => 0.0,
      'pink' => 0.0,
      'purple' => 0.0,
    }

    detector = Xi::DIP::ColorDetector::Detector.new(
      @models['region-64x64_value'])

    detector.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [64, 64] })

    gcolors = detector.color_histogram(
      :image,
      :value,
      { :colorspace => :rgb },
    )

    assert_equal rcolors, gcolors
  end
=end

  def test_detect_image_histogram
    rcolors = {
      'gray' => 12.74,
      'brown' => 11.03,
      'black' => 10.84,
      'blue' => 10.2,
      'green' => 10.18,
      'purple' => 9.83,
      'cyan' => 8.86,
      'pink' => 7.44,
      'yellow' => 6.04,
      'red' => 5.8,
      'orange' => 5.53,
      'white' => 1.49,
    }

    detector = Xi::DIP::ColorDetector::Detector.new(@models['image_histogram'])
    detector.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [64, 64] })

    gcolors = detector.color_histogram(
      :image,
      :histogram,
      { :nbins => 4, :colorspace => :rgb }
    )

    assert_equal rcolors, gcolors
  end

  def test_detect_image_histogram_from_regions
    rcolors = {
      'white' => 98.86,
      'green' => 1.12,
      'brown' => 0.02,
      'black' => 0.00,
      'gray' => 0.00,
      'cyan' => 0.00,
      'blue' => 0.00,
      'purple' => 0.00,
      'orange' => 0.00,
      'pink' => 0.00,
      'red' => 0.00,
      'yellow' => 0.00,
    }

    detector = Xi::DIP::ColorDetector::Detector.new(
      @models['region-64x64_histogram'])

    detector.preprocess_image(
      @img_file, { remove_alpha: nil, resize: [64, 64] })

    gcolors = detector.color_histogram(
      :image,
      :histogram,
      { :nbins => 4, :colorspace => :rgb }
    )

    assert_equal rcolors, gcolors
  end
end
