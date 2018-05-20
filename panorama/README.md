# Panorama

In this script we will be building a Matlab script that automatically extract features and applies homography transformations to align photos for a full sized panorama photo. The objective here is take 5 colored photos (640x480) taken from different angles and combine them into a single panoramic photo. Because some of the regions overlap, it is possible to extract and match features between photos in order to obtain the relation they share. Using that, we will be then rotating the pictures and aligning them.

The photos chosen are the following:

![full](https://user-images.githubusercontent.com/8211602/39070875-65f4f30e-44bb-11e8-9a38-cade3f527de5.png)

We will be using [Peter Corke's Computer Vision toolbox](http://petercorke.com/wordpress/toolboxes/machine-vision-toolbox) to process the images. In order to properly align all the photos, we have to see where they are similar, thus, let's extract features!

## Extracting features

Let's load the image and extract features with the function `isurf()`.

```matlab
im1 = iread('dataset/building1.jpg');
sf1 = isurf(im1);
```

The result will look something like this:

![features](https://user-images.githubusercontent.com/8211602/39071421-637cc71c-44bd-11e8-82fd-c0c956fc673c.jpg)

Now, let's do the same thing with the second image. In order to correctly align the panorama, we need to match features on both images and using the matching points, derive the homography matrix, or in other words, the camera position.

```matlab
im2 = iread('dataset/building2.jpg');
sf2 = isurf(im2);

m = sf1.match(sf2);
```

The results of some matches can be seen as follow. As you can see, some matches are right on point, but some miss by a large amount.

![matches](https://user-images.githubusercontent.com/8211602/39071877-03e77372-44bf-11e8-95dc-e8657a2a4f28.png)

## Applying RANSAC

In order to obtain a better approximation for the homography, we will use [RANSAC](https://en.wikipedia.org/wiki/Random_sample_consensus) (Random SAmple Consensus) .

```matlab
H = ransac(@homography,[m.p1; m.p2],0.5);
```

where `homography()` is the function we want the result for the points to agree on. `m.p1` and `m.p2` are the matrixes of points to pass as argument to the `homography` function. Finally, the threshold serves as a limit on how well a point fits the estimated. As you can see in the following image, after running the `ransac()` function we have a much better estimation of the matches, and as a result, a more precise `H` matrix.

![matches-ransac](https://user-images.githubusercontent.com/8211602/39072589-5fdd77e2-44c1-11e8-9bed-3aa8c723b16d.png) 

## Warping

Now that we know the camera position, we can just `homwarp()` the images to obtain the  new image and the offset position.

```matlab
[imwarped offset] = homwarp(inv(H), im2, 'full');
```

## Final result

The end result, pasting the second image on the first would look something like this:

![mounted](https://user-images.githubusercontent.com/8211602/39074377-6c83dd28-44c7-11e8-9f93-df85419dede5.png)

As you can see, the warp was nearly perfect, however there are a few details to consider. First, the exposition of the images don't match, leaving a clear divisory line where the images meet. To correct that, one can use alpha blending to merge the pictures. We didn't.

We just repeat the steps done in the last commands to all the images to obtain the full panorama. The final image can be seen below. As you can see, we still have the problem of seeing the merging lines and the perspective for the right side of the building is not great, because we used the last camera as reference. This means the first image (farthest to the left) is kept unchanged, and all other perspectives are calculated based on the first image.

![final](https://user-images.githubusercontent.com/8211602/39097653-a45cb200-4635-11e8-8c25-11e6ef97f903.png)

In order to change the perspective to the middle camera, we will have to apply a transformation to all camera matrices, so that the middle camera have a `H` matrix equivalent to the eye matrix. To do that, we just take the inverse of the middle matrix and multiply all matrices by it:

```matlab
H = [eye(3) H];
indexCentral = ceil(numImages/2);
inverse = inv(H{indexCentral});

for i = 1:numImages
    H{i} = H{i} * inverse;
end
```

The result can be seen below. Notice how some misalignments are still present in the image. Also, because our approach relies on statistics for parameter estimation, it will lead to slightly different results every time the script is called.

![final-central](https://user-images.githubusercontent.com/8211602/39157679-5c85e9a8-4732-11e8-9fb1-f8735a1b20f1.png)



## Testing with another dataset

To test the algorithm with other dataset, we chose our beautiful campus in Blumenau/SC.  The set consists of 9 pictures, with little angle variations to better suit feature matching. The results can be seen below.

![final-ufsc](https://user-images.githubusercontent.com/8211602/39158320-c1bd0bd2-4735-11e8-94b9-ba342481934a.png)

## Comparisons

In order to compare the results, we selected two algorithms to run on the same dataset, one for Matlab under the Github repo [yihui-he/panorama](https://github.com/yihui-he/panorama) and one from the professional suite Adobe Photoshop.

### yihui-he/panorama

This version of panorama includes a different feature extraction method using using SIFT from  VLFeat library. This library is supposed to better extract the features on the image. It also includes algorithms to automatically merge and blend the results. Note that this algorithm uses the middle camera as the reference point. The result are as follow:

![yihui-he](https://user-images.githubusercontent.com/8211602/39076234-85dca9d6-44d0-11e8-8253-29a946a74733.png)

As you can see, this method misaligns the images, but it becomes less obvious as it is blurred by the blender.

### Photoshop

As expected, Photoshop renders the best results for the image stitching.

![photoshop](https://user-images.githubusercontent.com/8211602/39076235-8600cc6c-44d0-11e8-8310-6235464afb4b.png)

## I want to run it!

First, [download and install the toolbox](http://petercorke.com/wordpress/toolboxes/machine-vision-toolbox#Downloading_the_Toolbox) (for no particular reason, all the strings in the toolbox use the wrong quotes that does not work in 2016b and below. If you are facing issues, search and replace all double-quotes `"` with single quotes `'`). Just replace the photos on the `dataset` folder with your own, or change the path in the second line of the script.

```matlab
images = iread('YOUR FOLDER HERE/*.JPG','double');
```

Consider resizing the photos to a lower resolution like 640x480 in order to speed up the process. Also, remember they have to be in order and end with `.jpg`. Then, execute the script (tested on MATLAB 2016a):

```matlab
> trabalho1
```

## Conclusions

We can conclude that, even though the result is reasonable from a academic standpoint, it's not nearly as good as the professional tools available like Photoshop.