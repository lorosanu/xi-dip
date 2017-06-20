# The Xilopix Digital Image Processing Library

## Description

* extract main colors from an image  
  using rmagick's remap & color_histogram methods  
  with respect to a predefined list of main colors

* extract main colors from an image  
  based on a given colorspace and a given distance measure  
  with respect to a predefined list of main colors  
  (ruby pixelwise processing => slower than rmagick's methods)

* detect main colors from an image  
  using an MLP classifier  
  trained on values/distances/histograms at the pixel/region/image level

* data preparation for color classification tasks (needed to build models)
    - extract values/distances/histograms from pixel/region/image areas;  
      requests are processed based on a configuration file
    - input  
      a folder with 12 sub-folders,  
      one subfolder for each main color,  
      each subfolder contains 100 png/jpg images
    - output  
      single .json file, containing all the extracted features from given images


## Usage

* ./bin/analyze_image [arguments]

    ```
    Object: extract main colors
    Usage:  ./bin/analyze_image [options]
      -i, --input INPUT    Input file
      -h, --help           Show this message
    ```

* ./bin/extract_color [arguments]

    ```
    Object: extract main colors
    Usage: ./bin/extract_color [options]
      -i, --input INPUT    Input file
      -c, --conf CONF      Config file
      -h, --help           Show this message
    ```

* ./bin/detect_color [arguments]

    ```
    Object: detect main colors
    Usage: ./bin/detect_color [options]
      -i, --input INPUT    Input file
      -c, --conf CONF      Config file
      -h, --help           Show this message
    ```

* ./bin/create_dataset [arguments]

    ```
    Object: create the dataset for color detection
    Usage: ./bin/create_dataset [options]
      -c, --config CONF     Config file
      -h, --help            Show this message
    ```


## Docker Execution

### Extract main colors from an image with rmagick's remap & color_histogram

```
docker-compose run --rm dip-devel ./bin/analyze_image -i data/car.jpg
```

Output


```
INFO [24-08-2017 16:00:28] [xi::dip]: Size: [100, 100]
INFO [24-08-2017 16:00:28] [xi::dip]: Format: JPEG
INFO [24-08-2017 16:00:28] [xi::dip]: Transparent: false
INFO [24-08-2017 16:00:28] [xi::dip]: Colors:
INFO [24-08-2017 16:00:28] [xi::dip]:  - grey                        30.78%
INFO [24-08-2017 16:00:28] [xi::dip]:  - grey|lightGrey              27.78%
INFO [24-08-2017 16:00:28] [xi::dip]:  - black                       19.99%
INFO [24-08-2017 16:00:28] [xi::dip]:  - brown|darkBrown              8.02%
INFO [24-08-2017 16:00:28] [xi::dip]:  - brown                        7.36%
INFO [24-08-2017 16:00:28] [xi::dip]:  - blue|lightBlue               2.88%
INFO [24-08-2017 16:00:28] [xi::dip]:  - brown|lightBrown             2.44%
INFO [24-08-2017 16:00:28] [xi::dip]:  - red|lightRed                 0.59%
INFO [24-08-2017 16:00:28] [xi::dip]:  - cyan|darkCyan                0.08%
INFO [24-08-2017 16:00:28] [xi::dip]:  - yellow|darkYellow            0.05%
INFO [24-08-2017 16:00:28] [xi::dip]:  - yellow                       0.03%
INFO [24-08-2017 16:00:28] [xi::dip]:  - chartreuse|darkChartreuse     0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - red|darkRed                   0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - chartreuse                    0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - chartreuse|lightChartreuse    0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - yellow|lightYellow            0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - green                         0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - green|lightGreen              0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - green|darkGreen               0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - cyan                          0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - cyan|lightCyan                0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - red                           0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - blue                          0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - white                         0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - blue|darkBlue                 0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - magenta                       0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - magenta|lightMagenta          0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - magenta|darkMagenta           0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - pink                          0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - pink|lightPink                0.0%
INFO [24-08-2017 16:00:28] [xi::dip]:  - pink|darkPink                 0.0%
INFO [24-08-2017 16:00:28] [xi::dip]: Execution: 0.040s
INFO [24-08-2017 16:00:28] [xi::dip]: Exif:
INFO [24-08-2017 16:00:28] [xi::dip]: Recolored imaged saved under data/car_remap_histogram_31colors.png
```

### Extract main colors from an image using RGB colorspace & euclidean distance

```
docker-compose run --rm dip-devel ./bin/extract_color \
  -i data/car.jpg \
  -c conf/color_extraction.yml
```

Configuration

```
:preprocessing:
  :remove_alpha: true
  :crop: 0.9
  :resize:
    - 100
    - 100
:nclusters: 31
:colorspace: :rgb
:distance: :euclidean
```

Output


```
INFO [24-08-2017 16:01:19] [xi::dip]: Processing current configuration:
{:preprocessing=>{:remove_alpha=>true, :resize=>[100, 100]},
 :nclusters=>31,
 :colorspace=>:rgb,
 :distance=>:euclidean}

INFO [24-08-2017 16:01:19] [xi::dip]: Extract colors
INFO [24-08-2017 16:01:19] [xi::dip]: Preprocessing execution: 0.004s
INFO [24-08-2017 16:01:19] [xi::dip]: Colors:
INFO [24-08-2017 16:01:19] [xi::dip]:   - grey                        30.78%
INFO [24-08-2017 16:01:19] [xi::dip]:   - grey|lightGrey              27.78%
INFO [24-08-2017 16:01:19] [xi::dip]:   - black                       19.99%
INFO [24-08-2017 16:01:19] [xi::dip]:   - brown                        8.12%
INFO [24-08-2017 16:01:19] [xi::dip]:   - brown|darkBrown              7.23%
INFO [24-08-2017 16:01:19] [xi::dip]:   - blue|lightBlue               2.88%
INFO [24-08-2017 16:01:19] [xi::dip]:   - brown|lightBrown             2.44%
INFO [24-08-2017 16:01:19] [xi::dip]:   - red|lightRed                 0.59%
INFO [24-08-2017 16:01:19] [xi::dip]:   - yellow|darkYellow            0.08%
INFO [24-08-2017 16:01:19] [xi::dip]:   - cyan|darkCyan                0.08%
INFO [24-08-2017 16:01:19] [xi::dip]:   - yellow                       0.03%
INFO [24-08-2017 16:01:19] [xi::dip]:   - chartreuse|darkChartreuse    0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - red|darkRed                  0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - chartreuse                   0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - chartreuse|lightChartreuse   0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - yellow|lightYellow           0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - green                        0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - green|lightGreen             0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - green|darkGreen              0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - cyan                         0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - cyan|lightCyan               0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - red                          0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - blue                         0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - white                        0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - blue|darkBlue                0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - magenta                      0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - magenta|lightMagenta         0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - magenta|darkMagenta          0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - pink                         0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - pink|lightPink               0.00%
INFO [24-08-2017 16:01:19] [xi::dip]:   - pink|darkPink                0.00%
INFO [24-08-2017 16:01:19] [xi::dip]: Color extraction execution: 0.151s
INFO [24-08-2017 16:01:19] [xi::dip]: Recolored imaged saved under data/car_recolored_extraction_31_rgb_euclidean.png
```

### Detect main colors in an image based on a pixel-value trained MLP classifier

```
docker-compose run --rm dip-devel ./bin/detect_color \
  -i data/car.jpg \
  -c conf/color_detection.yml
```

Configuration

```
:model: /usr/share/xi-dip/models/updated/12colors/sgd/relu/RGB/mlpclassifier_multilabel_2HL-36n-36n_pixel_value_RGB_64x64.json
:level: :pixel
:type: :value
:arguments:
  :colorspace: :rgb
:preprocessing:
  :remove_alpha: true
  :resize:
    - 100
    - 100
```

Output


```
INFO [24-08-2017 16:03:54] [xi::dip]: Processing current configuration:
{:model=>
  "/usr/share/xi-dip/models/updated/12colors/sgd/relu/RGB/mlpclassifier_multilabel_2HL-36n-36n_pixel_value_RGB_64x64.json",
 :level=>:pixel,
 :type=>:value,
 :arguments=>{:colorspace=>:rgb},
 :preprocessing=>{:remove_alpha=>true, :resize=>[100, 100]}}

INFO [24-08-2017 16:03:54] [xi::dip]: Detecting colors with an MLP classifier
INFO [24-08-2017 16:03:54] [xi::ml::classify::mlpclassifier]: Loaded already trained MLP classifier
INFO [24-08-2017 16:03:54] [xi::dip]: Preprocessing execution: 0.004s
INFO [24-08-2017 16:03:55] [xi::dip]: Colors:
INFO [24-08-2017 16:03:55] [xi::dip]:   - black                       35.14%
INFO [24-08-2017 16:03:55] [xi::dip]:   - white                       22.29%
INFO [24-08-2017 16:03:55] [xi::dip]:   - yellow                      17.63%
INFO [24-08-2017 16:03:55] [xi::dip]:   - blue                         8.70%
INFO [24-08-2017 16:03:55] [xi::dip]:   - gray                         6.45%
INFO [24-08-2017 16:03:55] [xi::dip]:   - brown                        3.86%
INFO [24-08-2017 16:03:55] [xi::dip]:   - green                        3.40%
INFO [24-08-2017 16:03:55] [xi::dip]:   - cyan                         2.24%
INFO [24-08-2017 16:03:55] [xi::dip]:   - orange                       0.19%
INFO [24-08-2017 16:03:55] [xi::dip]:   - red                          0.10%
INFO [24-08-2017 16:03:55] [xi::dip]:   - pink                         0.00%
INFO [24-08-2017 16:03:55] [xi::dip]:   - purple                       0.00%
INFO [24-08-2017 16:03:55] [xi::dip]: Color detection execution: 0.301s
INFO [24-08-2017 16:03:55] [xi::dip]: Recolored imaged saved under data/car_recolored_detection_pixel_value_rgb.png
```

### Detect main colors in an image based on a pixel-value trained MLP classifier
  after extracting the background ( ~ works on shopping images )

```
docker-compose run --rm dip-devel ./bin/detect_color \
  -i data/polo.jpg \
  -c conf/color_detection_removebkg.yml
```

Configuration

```
:model: /usr/share/xi-dip/models/updated/12colors/sgd/relu/RGB/mlpclassifier_multilabel_2HL-36n-36n_pixel_value_RGB_64x64.json
:level: :pixel
:type: :value
:arguments:
  :colorspace: :rgb
:preprocessing:
  :remove_alpha: true
  :resize:
    - 100
    - 100
  :extract_bkg:
    - :name: Xi::DIP::Preprocess::FloodFillMask
      :args:
        :remap: false
        :gray_threshold: 0.1
    - :name: Xi::DIP::Preprocess::SimCornersMask
      :args:
        :remap: false
        :max_distance: 0.1
```

Output

```
INFO [24-08-2017 10:18:20] [xi::dip]: Processing current configuration:
{:model=>
  "/usr/share/xi-dip/models/updated/12colors/sgd/relu/RGB/mlpclassifier_multilabel_2HL-36n-36n_pixel_value_RGB_64x64.json",
 :level=>:pixel,
 :type=>:value,
 :arguments=>{:colorspace=>:rgb},
 :preprocessing=>
  {:remove_alpha=>true,
   :resize=>[100, 100],
   :extract_bkg=>
    [{:name=>"Xi::DIP::Preprocess::FloodFillMask",
      :args=>{:remap=>false, :gray_threshold=>0.1}},
     {:name=>"Xi::DIP::Preprocess::SimCornersMask",
      :args=>{:remap=>false, :max_distance=>0.1}}]}}

INFO [24-08-2017 10:18:20] [xi::dip]: Detecting colors with an MLP classifier
INFO [24-08-2017 10:18:20] [xi::ml::classify::mlpclassifier]: Loaded already trained MLP classifier
INFO [24-08-2017 10:18:20] [xi::dip]: FloodFill pass no. 1
INFO [24-08-2017 10:18:20] [xi::dip]: FloodFill pass no. 2
INFO [24-08-2017 10:18:20] [xi::dip]: Masks cover over total image size:
INFO [24-08-2017 10:18:20] [xi::dip]: 	 - Mask Xi::DIP::Preprocess::SimCornersMask: 35.15%
INFO [24-08-2017 10:18:20] [xi::dip]: 	 - Mask Xi::DIP::Preprocess::FloodFillMask: 31.08%
INFO [24-08-2017 10:18:20] [xi::dip]: Applying all masks ["Xi::DIP::Preprocess::FloodFillMask", "Xi::DIP::Preprocess::SimCornersMask"] (37.83%)
INFO [24-08-2017 10:18:20] [xi::dip]: Image without background saved under data/polo_without_background.png
INFO [24-08-2017 10:18:20] [xi::dip]: Preprocessing execution: 0.233s
INFO [24-08-2017 10:18:20] [xi::dip]: Colors:
INFO [24-08-2017 10:18:20] [xi::dip]:   - red                         72.61%
INFO [24-08-2017 10:18:20] [xi::dip]:   - brown                       17.31%
INFO [24-08-2017 10:18:20] [xi::dip]:   - pink                         6.02%
INFO [24-08-2017 10:18:20] [xi::dip]:   - blue                         2.72%
INFO [24-08-2017 10:18:20] [xi::dip]:   - gray                         0.63%
INFO [24-08-2017 10:18:20] [xi::dip]:   - purple                       0.26%
INFO [24-08-2017 10:18:20] [xi::dip]:   - black                        0.21%
INFO [24-08-2017 10:18:20] [xi::dip]:   - white                        0.19%
INFO [24-08-2017 10:18:20] [xi::dip]:   - orange                       0.05%
INFO [24-08-2017 10:18:20] [xi::dip]:   - cyan                         0.02%
INFO [24-08-2017 10:18:20] [xi::dip]:   - green                        0.00%
INFO [24-08-2017 10:18:20] [xi::dip]:   - yellow                       0.00%
INFO [24-08-2017 10:18:20] [xi::dip]: Color detection execution: 0.413s
```


### Data preparation for color classification tasks

```
docker-compose run --rm dip-devel ./bin/create_dataset \
  -c conf/color_dataset.yml \
  --update \
  --colorize
```

Configuration: extract RGB float values of each pixel in resized 64x64 images

```
:res: /mnt/data/ml/colors/
:input: images/reference/
:output: features/reference/12colors/
:colors:
  - white
  - black
  - gray
  - red
  - green
  - blue
  - cyan
  - brown
  - yellow
  - orange
  - pink
  - purple
:options:
  :resize:
    - 64
    - 64
  :level: :pixel
  :type: :value
  :arguments:
    :colorspace: :rgb
```

Output

```
INFO [25-08-2017 11:06:32] [xi::dip]: Processing current configuration:
{:res=>"/mnt/data/ml/colors/",
 :input=>"images/reference",
 :output=>"features/reference/12colors/",
 :colors=>
  ["white",
   "black",
   "gray",
   "red",
   "green",
   "blue",
   "cyan",
   "brown",
   "yellow",
   "orange",
   "pink",
   "purple"],
 :options=>
  {:resize=>[64, 64],
   :level=>:pixel,
   :type=>:value,
   :arguments=>{:colorspace=>:rgb}}}

INFO [25-08-2017 11:06:32] [xi::dip]: Processing current configuration: resize=[64, 64], level=pixel, dbtype=value, args=rgb
INFO [25-08-2017 11:06:32] [xi::dip]: Features sets stored under /mnt/data/ml/colors/features/reference/12colors/pixel_value_rgb_64x64
INFO [25-08-2017 11:06:32] [xi::dip]: Creating the white features set
INFO [25-08-2017 11:06:32] [xi::dip]: Processing image 1
INFO [25-08-2017 11:06:32] [xi::dip]: Processing image 2
INFO [25-08-2017 11:06:32] [xi::dip]: Processing image 3
...
INFO [25-08-2017 11:06:36] [xi::dip]: Processing image 97
INFO [25-08-2017 11:06:36] [xi::dip]: Processing image 98
INFO [25-08-2017 11:06:36] [xi::dip]: Processing image 99
INFO [25-08-2017 11:06:36] [xi::dip]: Processing image 100
INFO [25-08-2017 11:06:36] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:06:36] [xi::dip]: Creating the black features set
...
INFO [25-08-2017 11:06:41] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:06:42] [xi::dip]: Creating the gray features set
...
INFO [25-08-2017 11:06:48] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:06:48] [xi::dip]: Creating the red features set
...
INFO [25-08-2017 11:06:54] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:06:54] [xi::dip]: Creating the green features set
...
INFO [25-08-2017 11:07:03] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:07:03] [xi::dip]: Creating the blue features set
...
INFO [25-08-2017 11:07:10] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:07:10] [xi::dip]: Creating the cyan features set
...
INFO [25-08-2017 11:07:17] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:07:17] [xi::dip]: Creating the brown features set
...
INFO [25-08-2017 11:07:25] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:07:25] [xi::dip]: Creating the yellow features set
...
INFO [25-08-2017 11:07:32] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:07:32] [xi::dip]: Creating the orange features set
...
INFO [25-08-2017 11:07:40] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:07:40] [xi::dip]: Creating the pink features set
...
INFO [25-08-2017 11:07:47] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:07:47] [xi::dip]: Creating the purple features set
...
INFO [25-08-2017 11:07:54] [xi::dip]: Created a corpus with 409600 samples
INFO [25-08-2017 11:07:54] [xi::dip]: Finished creating the color dataset
INFO [25-08-2017 11:07:54] [xi::dip]: 'Manually' updating the color dataset
INFO [25-08-2017 11:08:54] [xi::dip]: Updated the color dataset:
{
  "white"   => 454496,
  "black"   => 605907,
  "gray"    => 291638,
  "red"     => 409591,
  "green"   => 396251,
  "blue"    => 392530,
  "cyan"    => 396974,
  "brown"   => 367671,
  "yellow"  => 404719,
  "orange"  => 405949,
  "pink"    => 403795,
  "purple"  => 385679
}

```
