import numpy as np
import cv2

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

    def generate_xml(self, wall_list, scale = 0.05):
        xml = self.__xml_header__

        for index, wall in enumerate(wall_list):
            dimensions = wall.dimensions()*scale
            centroid = wall.centroid()*scale
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
    def __init__(self, start, end):
        self.start = start
        self.end = end

    def __str__(self):
        return "Start = {0}; End={1}".format(self.start, self.end)
    
    def centroid(self):
        return (self.start + self.end)/2.0 + 0.5

    def dimensions(self):
        return (self.end - self.start) + 1.0

    def length(self):
        return np.sum(self.dimensions()) - 1.0

    def contains(self, wall):
        dimension = self.dimensions()
        x = np.linspace(self.start[0], self.end[0], num=dimension[0])
        y = np.linspace(self.start[1], self.end[1], num=dimension[1])
        
        if (wall.start[0] in x and wall.start[1] in y and
            wall.end[0] in x and wall.end[1] in y):
            return True

        return False

def isWallinList(walls, new_wall):
    for wall in walls:
        if (wall.contains(new_wall)):
            return True
    return False

def main():
    im = cv2.imread('map.png', cv2.IMREAD_GRAYSCALE)
    height, width = im.shape

    walls = list()

    # generate the all the walls in the width direction
    for i in range(0, height):
        started = False
        finished = False
        for j in range(0, width):
            if (im[i, j] == 0 and started == False):
                start = np.array([i, j])
                started = True

            if ((im[i,j] == 255 and started == True) or (j == width - 1 and finished == False)):
                end = np.array([i, j - 1])
                finished = True

            if (started and finished):
                walls.append(Wall(start, end))
                started = False
                finished = False

    # generate the all the walls in the height direction
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
                started = False
                finished = False
                new_wall = Wall(start, end)
                walls.append(new_wall)

    # sort walls by lenght because bigger ones are likely to contain smaller ones
    walls.sort(key=lambda x: x.length(), reverse=True)

    # filter all walls that are contained (inside of) by longer walls
    walls_filtered = list()
    for element in walls:
        if not isWallinList(walls_filtered, element):
            walls_filtered.append(element)

    # finally generate the model file
    xml = XMLWriter().generate_xml(walls_filtered)

    with open('model.sdf', 'w') as f:
        f.write(xml)

if __name__ == "__main__":
    main()