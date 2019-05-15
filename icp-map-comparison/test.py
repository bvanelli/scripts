#!/usr/bin/env python

import numpy as np
import cv2
import time
import icp
import matplotlib.pyplot as plt

def read_image(im):
    height, width = im.shape
    black_pixels = np.sum(im == 0)

    points = np.zeros((black_pixels, 3))

    count = 0
    for i in range(0, height):
        for j in range(0, width):
            if im[i, j] == 0:
                points[count, :] =  np.array([i, j, 0])
                count = count + 1

    return points

def test_match():
    im_model_raw = cv2.imread("map.png", cv2.IMREAD_GRAYSCALE)
    ret_model, im_model = cv2.threshold(im_model_raw,254,255,cv2.THRESH_BINARY)

    im_raw = cv2.imread("gmapping.png", cv2.IMREAD_GRAYSCALE)
    ret, im = cv2.threshold(im_raw,1,255,cv2.THRESH_BINARY)

    points_model = read_image(im_model)
    points = read_image(im)

    np.random.shuffle(points_model)
    extension = points.shape[0] - points_model.shape[0]
    points_model_upsampled = np.append(points_model, points_model[0:extension, :], axis=0)
    #np.random.shuffle(points)
    #points = points[0:points_model.shape[0],:]

    T, distances, iterations = icp.icp(points, points_model_upsampled, tolerance=0.0001)

    # Make C a homogeneous representation of B
    points_transformed = np.ones((points.shape[0], 4))
    points_transformed[:,0:3] = points

    # Transform C
    points_transformed = np.dot(T, points_transformed.T).T

    print(T)

    print(distances)

    print(iterations)

    plt.plot(points_model[:, 0], points_model[:, 1], 'ro',
             points_transformed[:, 0], points_transformed[:, 1], 'bo')
    plt.axis('equal')
    plt.show()


if __name__ == "__main__":
    test_match()
