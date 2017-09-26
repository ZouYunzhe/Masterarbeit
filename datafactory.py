import numpy as np
from skimage import io
import glob
import os
import tensorflow as tf
import matplotlib.pyplot as plt

# file_dir
# cwd = os.path.join(os.getcwd(),'imagetest')
# classes = {'test','test1','test2'}
#
# os.chdir(cwd)
# for files in glob.glob("*.jpg"):
#     print(files)

file_dir = '/home/zouyunzhe/PycharmProjects/myNet/imagetest'


# A function to Load images
def load_image(addr):
    # read an image
    img = io.imread(addr)
    img = img.astype(np.float32)
    return img


# convert data to features
def _int64_feature(value):
    return tf.train.Feature(int64_list=tf.train.Int64List(value=[value]))


def _bytes_feature(value):
    return tf.train.Feature(bytes_list=tf.train.BytesList(value=[value]))


def _float_feature(value):
    return tf.train.Feature(float_list=tf.train.FloatList(value=[value]))


# create TFRecord
def create_record():
    writer = tf.python_io.TFRecordWriter("/home/zouyunzhe/PycharmProjects/myNet/train.tfrecords")
    for img_name in os.listdir(file_dir):
        print(img_name)
        img_path = os.path.join(file_dir, img_name)

        # load image
        img_raw = load_image(img_path)
        # img_raw = img_raw.tostring()
        img_shape = np.array(img_raw.shape)
        img_height = img_raw.shape[0]
        img_width = img_raw.shape[1]
        img_n_channel = img_raw.shape[2]
        img_shape = img_shape.reshape([1, 3])
        print(img_shape)
        # Create a feature
        feature = {'img_raw': _bytes_feature(tf.compat.as_bytes(img_raw.tostring())),
                   'img_raw2': _bytes_feature(tf.compat.as_bytes(img_raw.tostring())),
                   'img_shape': _bytes_feature(tf.compat.as_bytes(img_shape.tostring())),
                   'height': _int64_feature(img_height),
                   'width': _int64_feature(img_width),
                   'n_channel': _int64_feature(img_n_channel)
                   }
        # Create an example protocol buffer
        example = tf.train.Example(features=tf.train.Features(feature=feature))
        writer.write(example.SerializeToString())
    writer.close()
    print('Transform done!')


# read and decode
def read_and_decode(filename):
    feature = {'img_raw': tf.FixedLenFeature([], tf.string),
               'img_raw2': tf.FixedLenFeature([], tf.string),
               'img_shape': tf.FixedLenFeature([], tf.string),
               'height': tf.FixedLenFeature([], tf.int64),
               'width': tf.FixedLenFeature([], tf.int64),
               'n_channel': tf.FixedLenFeature([], tf.int64)}

    # Create a list of filenames and pass it to a queue
    filename_queue = tf.train.string_input_producer([filename])

    # Define a reader and read the next record
    reader = tf.TFRecordReader()
    _, serialized_example = reader.read(filename_queue)

    # Decode the record read by the reader
    features = tf.parse_single_example(serialized_example, features=feature)

    # Convert the image data from string back to the numbers
    image1 = tf.decode_raw(features['img_raw'], tf.float32)

    # Cast label data into int32
    image2 = tf.decode_raw(features['img_raw2'], tf.float32)

    image_shape = tf.decode_raw(features['img_shape'], tf.int64)

    # Reshape image data into the original shape
    image_height = tf.cast(features['height'], tf.int32)
    image_width = tf.cast(features['width'], tf.int32)
    image_n_channel = tf.cast(features['n_channel'], tf.int32)
    image_shape = tf.stack([image_height, image_width, image_n_channel])
    # image_1 = tf.reshape(image1, image_shape)  # [720, 1280, 3]
    image_1 = tf.reshape(image1, [720, 1280, 3])  # [720, 1280, 3]
    # Any preprocessing here ...
    # re_image = tf.image.resize_image_with_crop_or_pad(image=image_1,
    #                                                   target_height=384,
    #                                                   target_width=384)
    # Creates batches by randomly shuffling tensors
    image_end = tf.train.shuffle_batch([image_1], batch_size=3, capacity=30, num_threads=1,
                                       min_after_dequeue=10)
    sess = tf.Session()
    init_op = tf.group(tf.global_variables_initializer(), tf.local_variables_initializer())
    sess.run(init_op)
    # Create a coordinator and run all QueueRunner objects
    # coord = tf.train.Coordinator()
    # threads = tf.train.start_queue_runners(coord=coord),
    tf.train.start_queue_runners(sess=sess)
    img1 = sess.run([image_end])
    sess.close()
    return img1  # , img2


if __name__ == '__main__':
    create_record()
    img1 = read_and_decode("train.tfrecords")
    img1 = np.squeeze(np.array(img1)).astype(np.uint8)
    # img1, img2 = read_and_decode("train.tfrecords")
    # img1 = img1.astype(np.uint8)
    # img2 = img2.astype(np.uint8)
    # io.imshow(img)
    # img1_tmp = io.imread('/home/zouyunzhe/PycharmProjects/myNet/imagetest/02111.jpg')
    for i in range(0,3):
        plt.figure(i)
        plt.imshow(img1[i])
    # plt.figure(2)
    # plt.imshow(img2)

    plt.show()
