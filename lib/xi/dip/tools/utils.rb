# encoding: utf-8


class Xi::DIP::Utils

  # Validate the type of given image argument
  # @param image [Magick::Image] the given image
  def self.validate_image(image)
    raise Xi::DIP::Error::DataError, \
      'Given image is not of type Magick::Image' \
      unless image.is_a?(Magick::Image)
  end

  # Validate the type of given argument
  # @param pixel [Magick::Pixel] the given argument
  def self.validate_pixel(pixel)
    raise Xi::DIP::Error::DataError, \
      'Given argument is not of type Magick::Pixel' \
      unless pixel.is_a?(Magick::Pixel)
  end

  # Create folder path
  # @param output [String]
  def self.create_folder(output)
    return if output.nil? || output == ''
    FileUtils.mkdir_p(output) unless File.directory?(output)
  end

  # Create file path
  # @param output [String]
  def self.create_path(output)
    return if output.nil? || output == ''
    self.create_folder(File.dirname(output))
  end

  # Check file existance
  # @param input [String]
  def self.check_file_readable!(input)
    raise Xi::DIP::Error::ConfigError, 'Empty file name' \
      if input.nil? || input == ''

    raise Xi::DIP::Error::ConfigError, \
      "File '#{input}' is missing or not readable" \
      unless File.readable?(input)
  end

  # static method to check folder existance
  def self.check_folder_readable!(input)
    raise Xi::ML::Error::ConfigError, 'Empty folder name' \
      if input.nil? || input == ''

    raise Xi::ML::Error::ConfigError, \
      "Folder '#{input}' is missing or not readable" \
      unless File.directory?(input)
  end

  # Recover file name with extension
  # @param input [String]
  # @return [String]
  def self.filename(input)
    return '' if input.nil? || File.basename(input).nil?
    File.basename(input)
  end

  # Recover file basename
  # @param input [String]
  # @return [String]
  def self.basename(input)
    return '' if input.nil?
    File.basename(input, File.extname(input))
  end

  # Recover file dirname
  # @param input [String]
  # @return [String]
  def self.dirname(input)
    return '' if input.nil?
    File.dirname(input)
  end

  # Recover file extension
  # @param input [String]
  # @return [String]
  def self.extname(input)
    return '' if input.nil?
    File.extname(input)
  end

  # Recover path without extension
  # @param input [String]
  # @return [String]
  def self.path_without_ext(input)
    return '' if input.nil?
    File.join(self.dirname(input), self.basename(input))
  end

  # Change filename: add text before extension
  # @param input [String]
  # @return [String]
  def self.change_filename(input, subname)
    return '' if input.nil?
    "#{self.path_without_ext(input)}#{subname}#{self.extname(input)}"
  end

end
