# encoding: utf-8

class Xi::DIP::ColorDetector::Dataset
  attr_reader :colorname, :files, :resize

  # Initialize the dataset: each image is to be resized into a _x_ format
  # @param colorname [String] the color name of the given image set
  # @param image_files [Array] the list of files representing the color
  # @param resize [Array] the new width and height for each image
  def initialize(colorname, image_files, resize=[64, 64])
    @colorname = colorname.to_s
    @files = image_files.clone
    @resize = resize.clone
  end

  # Create the dataset of the curent color
  # @param file [String] the output json file
  # @param level [Symbol] which extraction level (:pixel / :region / :image)
  # @param ftype [Symbol] which features type (:value / :distance / :histogram)
  # @param fargs [Hash] the arguments associated to the feature type
  def create_dataset(file, level, ftype, fargs)
    nsamples = 0

    File.open(file, 'w') do |of|
      @files.each_with_index do |image_file, index|
        Xi::DIP.logger.info("Processing image #{index + 1}")

        image = Xi::DIP::Image.new(image_file)
        image.force_resize!(*@resize) unless @resize == [-1, -1]

        Xi::DIP::ColorDetector::Features.generator(
          image, level, ftype, fargs) do |feat|

          color = {
            'category' => @colorname,
            'features' => feat,
          }
          of.puts(color.to_json)

          nsamples += 1
        end
      end
    end

    Xi::DIP.logger.info("Created a corpus with #{nsamples} samples")
  end
end
