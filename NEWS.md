# @markup markdown

# News

## XiDIP 1.4.0 - 07/11/2017
* use the 0.6.0 gem version of xi-ml
* use a new models archive inside the docker image
* update test models to match the new MLP format

## XiDIP 1.3.0 - 05/10/2017
* update project configuration
    - add docker files
    - update rakefile & gemspec
* expand the image lib to perform more image processings
* add computations on a pixel level
    - manually convert pixels into different color spaces
    - manually compare pixels based on various distance measures
* extract background of an image
    - using a flodfill method
    - using a simcorners method
    - or both
* manually extract main colors from an image
    - based on a predefined cluster of colors
    - choose colorspace
    - choose distance measure
* automatically detect main colors from an image
    - extract color features
        - for each pixel: pixel's value, pixel's distance to color clusters
        - for a *[m x m]* region of pixels: pixels values, pixels histogram
        - for the entire image: pixels values, pixels histogram
    - apply the corresponding pretrained MLPClassifier

## XiDIP 1.2.0
* add alpha? method
* add config.load method

## XiDIP 1.1.1
* fix dithering

## XiDIP 1.1.0
* rename XiImage XiDIP

## XiImage 1.0.0
* add Xi namespace

## XiImage 0.2.0
* lint

## XiImage 0.1.1
* fix exif encoding issue

## XiImage 0.1.0
* image class
    - exif method
    - size method
    - color_histogram method
* add config module
* use log4r

