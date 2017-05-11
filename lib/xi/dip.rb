# encoding: utf-8


require 'pp'
require 'time'
require 'json'
require 'yaml'
require 'fileutils'         # create path
require 'log4r'
require 'rmagick'           # lib for image processing
require 'exifr'             # module to read metadata from JPEG and TIFF images
require 'exifr/jpeg'
require 'exifr/tiff'

module Xi
  module DIP
  end
end

require 'xi/dip/error'
require 'xi/dip/tools'

module Xi::DIP
  @logger = Xi::DIP::Logger.create_root()
  def self.logger
    @logger
  end
end

require 'xi/dip/image'
require 'xi/dip/color'
