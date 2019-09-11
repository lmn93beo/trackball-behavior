import numpy as np
import matplotlib.pyplot as plt
import PIL
import cv2

# Load and display image
filename = 'C07_01.001_processed_transformed.tif'
img = PIL.Image.open(filename)
img = cv2.imread(filename)
ROIs = cv2.selectROIs('Select ROIs', img, False)
plt.imshow(img)

