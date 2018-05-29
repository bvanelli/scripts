# Plate Recognition

The objective of this code is accurately identify a plate, segment the characters and ultimately convert it into a readable string. In order to do that, we are using Matlab code together with Peter [Corke's Machine Vision Toolbox](http://petercorke.com/wordpress/toolboxes/machine-vision-toolbox). The example plates can be shown on Figure 1.

<img src="https://user-images.githubusercontent.com/8211602/40629005-cf91d8f8-629e-11e8-86c3-3d59f698351d.jpg" height="120" width="260">  <img src="https://user-images.githubusercontent.com/8211602/40629006-cfc2b518-629e-11e8-9d6d-eaec89c42eaf.jpg" height="120" width="160">  

* Figure 1. Plate models according to brazilian standards, using [Mandatory font](https://en.wikipedia.org/wiki/Mandatory_(typeface)).

There are two main challenges to accomplish: identifying the plate number (bigger characters) and identifying the state-city (smaller characters on top of the bigger characters). Because each of this texts will require different data processing, we divided into two different problems. There is also the problem of order regarding the motorcycle plate, that has double-line plate number, and problems regarding different color plates for especial vehicles, like official cars.

There are several techniques to extract data from a plate, ranging from manually matching data to neural nets. We chose a method in between, in order to keep the code simpler. We first will explain how the plate is segmented and recognized, and then discuss how one would recognize a plate in the wild, between cars and pedestrians.

## Pre-processing

In order to reduce the complexity of data to process, we first apply filters aimed at reducing the amount of information on screen, in fact reducing data to a binary image. We apply `niblack` to filter the image, reducing reflections, and then compare with the results of `otsu`.

### `otsu(image)`

[Otsu](https://en.wikipedia.org/wiki/Otsu%27s_method) is an optimal threshold for binarizing an image with a bimodal intensity histogram. The algorithm assumes there are two main elements on the image: background and foreground, and then calculate the optimal value that will separate both layers.

### `niblack(image, k, window)`

[Niblack](https://link.springer.com/article/10.1007/s10462-017-9574-2) is an binarization algorithm that uses a custom threshold value to binarize every window of size (W = 2*window + 1). The value is chosen based on the average and variance of the neighbors, using the rule: T = average(W) + k * variance(W)

### Results

The following image show how the image is transformed in each step. Notice that even with processing, there is remaining noise on the result. In order to enhance the detection of the plate number (big letters and numbers), we also apply an morphological opening (morphological erosion followed by dilation) that reduce the amount of little white spots. We don't apply opening on state-city identification as it could render small letters illegible.

![niblack-otsu](https://user-images.githubusercontent.com/8211602/40282844-6cbef4e4-5c4b-11e8-9ada-3d4db1bd1877.png)

## Character segmentation

In order to find all distinct objects on the image, we used `iblobs` to get useful region features. We then separate characters from noise using `clusterdata`. 

### `iblobs(image, 'area', area)`

Blob is a reagion feature . For a binary image, the `iblobs` function return all connected groups of pixels on the image, greater than a given area. It then gives every blob a number and a father, meaning that, if a letter has a hole in it, it will be detected as a child blob of the letter. The ultimate father of all blobs is the background. The following image illustrates this idea:

![blobs](https://user-images.githubusercontent.com/8211602/40282842-6c433f34-5c4b-11e8-9f46-6fe3d6344235.png)

Notice that we only want the blobs that are related to the background, so we can remove all others.

![blobs-nobg](https://user-images.githubusercontent.com/8211602/40282843-6c9ba890-5c4b-11e8-843c-4c56a9ad19c7.png)

Finally, we apply `clusterdata`, that simply splits data in groups based on their Euclidian distance and a cutoff value. We use as a parameter to the clustering the height of the blobs, that is supposed to be constant in all characters, and pick the global maximum because the big letters will always be the largest blob.

The last step is actually picking the group with largest heigth and sorting the by the x position in ascending order. This will unscramble the letters so that they can be matched in order. We first compare the y coordinates to determine if the the plate belongs to a car or a motorcycle, as shown in the Figure 1.

## Template matching

In order to match the characters to their alphanumeric counterparts, we first loaded a template for the custom Mandatory Font, then matched the the blobs against the template. To do that, we first extract the character from the original image (before applying the transformations) and apply the `zncc` algorithm.

![template](https://user-images.githubusercontent.com/8211602/40282845-6ce2f7f4-5c4b-11e8-99ea-600148ece79f.png)

### ZNCC

The [ZNCC](https://en.wikipedia.org/wiki/Cross-correlation#Zero-normalized_cross-correlation_(ZNCC)), or Zero mean Normalized Cross Correlation is an algorithm based on NCC for template matching. The equation, considering an image I and a template T is as follows:

![zncc](https://user-images.githubusercontent.com/8211602/40282846-6d0376be-5c4b-11e8-8b77-b3db961cfe42.png)

The ZNCC is a pretty robust algorithm for template matching because it's invariant to affine changes in image brightness, offset and scale.

### Results

Using the first character of the plate used as an example (the letter B), we can obtain the results matching with all the letters available on the template. Notice that the B gives us the best result, but other round characters like D or S also produced high values, meaning that trying to match low quality plates (like in pictures taken from far away) might be a problem. The algorithm make mistakes especially matching O's in the state-city recognition because of the low pixel count. To correct this problem we could use a dictionary of state-cities, since they are all known, and match the closest to the string.

<img src="https://user-images.githubusercontent.com/8211602/40282847-6d286e74-5c4b-11e8-84b4-ed414029d6ae.png" width="50%">

## Correcting perspective

Realistically, most plates will not be as good as the images shown before, so we need to first recognize the location and orientation of the plate, and then extract and reorient it using homography. If you are not familiar with homography, [check this previous work on panoramas](https://github.com/bvanelli/scripts/tree/master/panorama). To identify the borders of the plate, we first use Hough transformation, find common intersections, reorient the plate and finally apply the algorithms shown above to segment and then identify characters.

**Disclaimer:** to preserve privacy, plate numbers were removed in the next pictures.

### Binarizing the image and localizing the plate

To reduce the amount of information, we first binarize the image using a neat little line.

```matlab
carro_chassi_t = iconvolve(niblack(im,-.5,1) < otsu(im),kgauss(2));
```

The result then shows clearly a black square where the plate should be:

<img src="https://user-images.githubusercontent.com/8211602/40626027-6a95f496-628c-11e8-9c26-114c03b48766.png" width="50%">

We then use region feature to extract the plate features.

<img src="https://user-images.githubusercontent.com/8211602/40626026-6a70c02c-628c-11e8-8510-49d628f5426e.png" width="50%">

### Applying Hough

Now that we know where the features are, we just take the centers and place in the plane. Then, we apply Hough transform to find a line that intersect most of the points. This line should pass exactly in the center of the plate.

<img src="https://user-images.githubusercontent.com/8211602/40626028-6ac462e0-628c-11e8-963a-a52d4268c64c.png" width="50%">

This means the plate can now be better isolated from the background. We will use this new image and apply Hough again to find the borders of the white plate. The 4 intersections of the lines will be the 4 points we will homwarp.

<img src="https://user-images.githubusercontent.com/8211602/40626029-6ae51c1a-628c-11e8-82dd-619835dfcfd3.png" width="50%">

### Applying homography

Now that we have the 4 points of the borders and the 4 points we want (given by [CONTRAN especifications](http://www.denatran.gov.br/download/Resolucoes/RESOLUCAO_CONTRAN_241.pdf)), we can homewarp the plate to the correct orientation.

<img src="https://user-images.githubusercontent.com/8211602/40626031-6b35c8fe-628c-11e8-8db0-a48bc35f7e8c.png" height="120">  <img src="https://user-images.githubusercontent.com/8211602/40626030-6b11682e-628c-11e8-90c2-efbd49c182c9.png" height="120">  

## I want to run it!

First, [download and install the toolbox](http://petercorke.com/wordpress/toolboxes/machine-vision-toolbox#Downloading_the_Toolbox) (for no particular reason, all the strings in the toolbox use the wrong quotes that does not work in 2016b and below. If you are facing issues, search and replace all double-quotes `"` with single quotes `'`). First, import your image using your favorite Computer Vision Toolbox in gray scale and double precision.

```matlab
plate = iread('YOUR IMAGE HERE', 'double', 'grey');
```

You also need to load the template for template matching (we include the mandatory template in the 'fonte' folder):

```matlab
template = load_font('fonte/letras.png', 'fonte/numeros.png');
```

Now, try identifying the plate:

```matlab
s1 = get_plate(plate, template)
```

Alternatively, you can identify the state-city:

```matlab
h1 = get_plate_header(plate, template)
```

## Conclusions

Much can be concluded from this experiment. First of all, detecting plates is hard! Minimal changes in the dataset, like brightness, amount of noise or even certain orientations can largely affect the results. More importantly, this algorithm cannot even be compared to commercial ones because it lacks basic precision on the full dataset.

To correct this problem, mixed algorithms including neural nets could be used to improve accuracy, as proposed [here](https://arxiv.org/abs/1802.09567) and [here](https://github.com/openalpr/openalpr). 
