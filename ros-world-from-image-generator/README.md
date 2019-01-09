# ros-world-from-image-generator

This neat little script is capable of generating a ROS World from an image provided by the user. The algorithms identify all straight walls and reproduces it in the model, so that it can be later simulated on Gazebo.

```
positional arguments:
  file                  Your image file path.

optional arguments:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        The output map name (default is model.sdf).
  -r RESOLUTION, --resolution RESOLUTION
                        Resolution (m/pixels) of map (default is 0.05).
  -w WALL, --wall WALL  Wall height of reconstruction (m) (default is 2.5).
```

## Usage

In order to use this script, first install the dependencies `numpy` and `python-opencv`:

```
sudo apt install python-numpy python-opencv
```

Then, create the map image using a low resolution (the exemple below is using 100x100 pixels):

![gimp](https://user-images.githubusercontent.com/8211602/50905571-6a385b80-1423-11e9-94b8-2c0a02d9fc79.png)

Then, use the script to generate the map:

```
python3 generator.py map.png
```

The default resolution is 0.05, meaning that the 100 pixel map will translate to a 5 meters map in the simulation.

This command will generate a model.sdf file, that can be user to start the Gazebo simulation. Since only the model is generate, usually you will also need to create a World file that imports the Model. Finally the launch file will include the world file.

The result will look like this:

![gazebo](https://user-images.githubusercontent.com/8211602/50906035-825caa80-1424-11e9-86f7-328bb9f40d9c.jpg)
