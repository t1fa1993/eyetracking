import cv2
import numpy as np

img = cv2.imread('/users/yiyichen/Desktop/1.png')
img_size = img.shape
block_size = 20

# create mask for blocks
mask = np.sum(img, axis=-1) > 0

# pad image if needed to fit block size
if img_size[0] % block_size != 0:
    new_height = (img_size[0] // block_size + 1) * block_size
    img = np.vstack([img, np.zeros((new_height - img_size[0], img_size[1], img_size[2]))])
    mask = np.vstack([mask, np.zeros((new_height - img_size[0], img_size[1]))])
if img_size[1] % block_size != 0:
    new_width = (img_size[1] // block_size + 1) * block_size
    img = np.hstack([img, np.zeros((img.shape[0], new_width - img_size[1], img_size[2]))])
    mask = np.hstack([mask, np.zeros((img.shape[0], new_width - img_size[1]))])

# split image into blocks
img_blocks = [img[i:i+block_size, j:j+block_size, :] for i in range(0, img.shape[0], block_size) for j in range(0, img.shape[1], block_size)]
mask_blocks = [mask[i:i+block_size, j:j+block_size] for i in range(0, img.shape[0], block_size) for j in range(0, img.shape[1], block_size)]

# shuffle blocks that contain white pixels
white_blocks = [block for block, mask in zip(img_blocks, mask_blocks) if np.any(mask)]
np.random.shuffle(white_blocks)

# rebuild the image
new_arr = np.zeros_like(img)
index = 0
for i in range(0, img_size[0], block_size):
    for j in range(0, img_size[1], block_size):
        block = img_blocks[index]
        if np.any(mask_blocks[index]):
            block = white_blocks.pop(0)
        new_arr[i:i+block_size, j:j+block_size, :] = block
        index += 1

# remove padded areas if added
if img_size[0] % block_size != 0:
    new_arr = new_arr[:img_size[0], :, :]
if img_size[1] % block_size != 0:
    new_arr = new_arr[:, :img_size[1], :]

cv2.imwrite('/users/yiyichen/Desktop/shuffled_image_15.png', new_arr)
