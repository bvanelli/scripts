# Plate Recognition

The objective of this code is accurately identify a plate, segment the characters and ultimately convert it into a readable string. In order to do that, we are using Matlab code together with Peter [Corke's Machine Vision Toolbox](http://petercorke.com/wordpress/toolboxes/machine-vision-toolbox). The example plates can be shown on Figure 1.

<img src="https://github.com/marcelopetry/BLU3040_Visao/blob/master/A2/dataset/placa_carro1.jpg" height="120" width="260">  <img src="https://github.com/marcelopetry/BLU3040_Visao/blob/master/A2/dataset/placa_moto1.jpg" height="120" width="160">  

*Figure 1. Plate models according to brazilian standards, using [Mandatory font](https://en.wikipedia.org/wiki/Mandatory_(typeface)).

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

TODO: include niblack-otsu.png

## Character segmentation

In order to find all distinct objects on the image, we used `iblobs` to get useful region features. We then separate characters from noise using `clusterdata`. 

### `iblobs(image, 'area', area)`

Blob is a reagion feature . For a binary image, the `iblobs` function return all connected groups of pixels on the image, greater than a given area. It then gives every blob a number and a father, meaning that, if a letter has a hole in it, it will be detected as a child blob of the letter. The ultimate father of all blobs is the background. The following image illustrates this idea:

TODO: include blobs.png

Notice that we only want the blobs that are related to the background, so we can remove all others.

TODO: include blobs-nobg.png

Finally, we apply `clusterdata`, that simply splits data in groups based on their Euclidian distance and a cutoff value. We use as a parameter to the clustering the height of the blobs, that is supposed to be constant in all characters, and pick the global maximum because the big letters will always be the largest blob.

The last step is actually picking the group with largest heigth and sorting the by the x position in ascending order. This will unscramble the letters so that they can be matched in order. We first compare the y coordinates to determine if the the plate belongs to a car or a motorcycle, as shown in the Figure 1.

## Template matching

In order to match the characters to their alphanumeric counterparts, we first loaded a template for the custom Mandatory Font.

TODO: include template.png

In order to match the blobs to the template, we first take the character from the original image (before applying the transformations) and apply the `zncc` algorithm.

### ZNCC

The [ZNCC](https://en.wikipedia.org/wiki/Cross-correlation#Zero-normalized_cross-correlation_(ZNCC)), or Zero mean Normalized Cross Correlation is an algorithm based on NCC for template matching. The equation, considering an image I and a template T is as follows:

TODO: include zncc.png

The ZNCC is a pretty robust algorithm for template matching because it's invariant to affine changes in image brightness, offset and scale.

### Results

Using the first character of the plate used as an example, the letter B, we can obtain the results matching with all the letters available on the template. Notice that the B gives us the best result, but other round characters like D or S give high values, meaning that trying to match low quality plates (like in pictures taken from far away) might be a problem.

TODO: include zncc-out.png









## Entregas
Cada grupo deverá descrever a sua funcao sob a forma de relatório técnico. No relatório deverá ser apresentado:
* Contextualização
* Breve explicação sobre as metodologias utilizas
* Descrição da lógica 
* Testes e resultados
* Conclusão

Cada um dos grupos deverá criar um projeto público no GitHub e fazer upload do código desenvolvido. O link para o projeto do GitHub deverá constar no relatório entregue. O projeto no GitHub deverá conter um arquivo README explicando brevemente o algoritmo e como executá-lo. Cada grupo também deverá realizar uma demonstração do seu algoritmo durante a aula.


## Avaliação
A pontuacao do trabalho será atribuida de acordo com os criterios estabaleceidos a seguir: 
* Até 7.0: A função recebe como argumento uma imagem, e retorna um vetor com dois elementos contendo os três caracteres alfabeticos e os quatro caracteres numericos referentes ao número da placa do veículo. O algoritmo devera reconhecer os caracteres em pelo menos 3 imagens diferentes.
* Até 8.0: Além dos requesitos estabelecidos anteriormente, a função deverá retornar os caracteres numéricos referentes ao estado e a cidade.
* Até 10.0: Além dos requesitos estabelecidos anteriormente, as imagens passadas para a função deverão ter outros elementos além da placa do veículo, tais como parachoque, pavimento, pessoas, etc. Esta deverá primeiramente identificar, extrair e orientar a placa. Devem ser utilizadas tecnicas de conversao do espaco de cor, operacoes monadicas e homografia.
* Até 12.0: Além dos requesitos estabelecidos anteriormente, a função devera receber vídeo, de arquivo ou da webcam, e retornar os caracteres da placa.

