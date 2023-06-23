import cv2
import numpy as np
import random

# Load the original image in grayscale
img = cv2.imread('/users/yiyichen/Desktop/3.png', cv2.IMREAD_GRAYSCALE)

# Define the size of the blocks
block_size = 5

# Calculate the dimensions of the image in blocks
num_blocks_y = img.shape[0] // block_size
num_blocks_x = img.shape[1] // block_size

# Split the image into blocks
blocks = []
masks = []
for y in range(num_blocks_y):
    row = []
    mask_row = []
    for x in range(num_blocks_x):
        block = img[y*block_size:(y+1)*block_size, x*block_size:(x+1)*block_size]
        mask = np.all(block == 255)
        row.append(block)
        mask_row.append(mask)
    blocks.append(row)
    masks.append(mask_row)

# Collect the non-white blocks
nonwhite_blocks = []
for y in range(num_blocks_y):
    for x in range(num_blocks_x):
        if not masks[y][x]:
            nonwhite_blocks.append(blocks[y][x])

# Shuffle the non-white blocks randomly
random.shuffle(nonwhite_blocks)

# Place the shuffled non-white blocks back into the image
nonwhite_idx = 0
shuffled_blocks = []
for y in range(num_blocks_y):
    row = []
    for x in range(num_blocks_x):
        if masks[y][x]:
            row.append(np.full((block_size, block_size), 255))
        else:
            row.append(nonwhite_blocks[nonwhite_idx])
            nonwhite_idx += 1
    shuffled_blocks.append(row)

# Combine the shuffled blocks back into an image
shuffled_img = np.zeros_like(img)
for y in range(num_blocks_y):
    for x in range(num_blocks_x):
        shuffled_img[y*block_size:(y+1)*block_size, x*block_size:(x+1)*block_size] = shuffled_blocks[y][x]

# Save the shuffled image
cv2.imwrite('/users/yiyichen/Desktop/shuffled_image_14.png', shuffled_img)
