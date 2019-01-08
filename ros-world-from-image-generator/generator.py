import numpy as np
import cv2
from matplotlib import pyplot as plt

im = cv2.imread('map.png', cv2.IMREAD_GRAYSCALE)
height, width = im.shape

class XMLWriter:
    __xml_header__ = """
<?xml version='1.0'?>
<sdf version='1.6'>
    <model name='turtlebot3_rooms'>
    <pose frame=''>0 0 0 0 0 0</pose>
    """

    __xml_footer__ = """
    <static>1</static>
    </model>
</sdf>
    """

    __xml_link__ = """
        <link name='Wall_{link_number}'>
            <collision name='Wall_{link_number}_Collision'>
            <geometry>
                <box>
                <size>{size} {height}</size>
                </box>
            </geometry>
            <pose frame=''>0 0 0 0 0 0</pose>
            </collision>
            <visual name='Wall_{link_number}_Visual'>
            <pose frame=''>0 0 0 0 0 0</pose>
            <geometry>
                <box>
                <size>{size} {height}</size>
                </box>
            </geometry>
            <material>
                <script>
                <uri>file://media/materials/scripts/gazebo.material</uri>
                <name>Gazebo/Grey</name>
                </script>
                <ambient>1 1 1 1</ambient>
            </material>
            </visual>
            <pose frame=''>{position} 0 0 0 {orientation}</pose>
        </link>
    """

    def generate_xml(self, wall_list):
        xml = self.__xml_header__

        for index, wall in enumerate(wall_list):
            dimensions = wall.dimensions()
            centroid = wall.centroid()
            xml_wall = self.__xml_link__.format(
                link_number = index,
                height = 2.5,
                size = '{} {}'.format(dimensions[0], dimensions[1]),
                position = '{} {}'.format(centroid[0], centroid[1]),
                orientation = 0)
            xml = xml + xml_wall

        xml = xml + self.__xml_footer__
        return xml


class Wall:
    def __init__(self, start, end, scale = 0.05):
        self.start = start*scale
        self.end = end*scale
        self.scale = scale

    def __str__(self):
        return "Start = {0}; End={1}".format(self.start, self.end)
    
    def centroid(self):
        return (self.start + self.end)/2.0 + 0.5*self.scale

    def dimensions(self):
        return (self.end - self.start) + 1.0*self.scale

walls = list()
# for i in range(0, height):
#     started = False
#     finished = False
#     for j in range(0, width):
#         if (im[i, j] == 0 and started == False):
#             start = np.array([i, j])
#             started = True

#         if ((im[i,j] == 255 and started == True) or (j == width - 1 and finished == False)):
#             end = np.array([i, j - 1])
#             finished = True

#         if (started and finished):
#             walls.append(Wall(start, end))
#             started = False
#             finished = False

for j in range(0, width):
    started = False
    finished = False
    for i in range(0, height):
        if (im[i, j] == 0 and started == False):
            start = np.array([i, j])
            started = True

        if ((im[i,j] == 255 and started == True) or (i == height - 1 and finished == False)):
            end = np.array([i - 1, j])
            finished = True

        if (started and finished):
            walls.append(Wall(start, end))
            started = False
            finished = False

xml = XMLWriter().generate_xml(walls)

with open('model.sdf', 'w') as f:
    f.write(xml)
