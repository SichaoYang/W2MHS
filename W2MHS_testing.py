import tensorflow as tf
import numpy as np
import csv
import os


def main():
    """Testing module: imports the trained variables from the training file to perform testing on the new feature set"""
    training_path = os.path.join(os.path.dirname(__file__), 'training')

    with open(os.path.join(training_path, 'feature_set.csv'), 'r') as f:
        feature_set = np.asarray(list(csv.reader(f))).astype(np.float32)
    transposed_feature_set = np.transpose(feature_set)

    new_graph = tf.Graph()
    with tf.Session(graph=new_graph) as sess:
        # restores the saved model
        saver = tf.train.import_meta_graph(os.path.join(training_path, 'Training_model.meta'))
        saver.restore(sess, tf.train.latest_checkpoint(training_path))
        graph = tf.get_default_graph()
        # restores the trained parameters and variables for testing on the new feature set
        X = graph.get_tensor_by_name("features:0")
        Accuracy = graph.get_tensor_by_name("Output_Layer:0")
        predict = tf.argmax(Accuracy, 1)
        output = sess.run(predict, feed_dict={X: transposed_feature_set})
        return output


if __name__ == '__main__':
    os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # suppress TensorFlow warnings
    output = main()
    for i in output[:-1]:
        print(i, end=" ")
    print(output[-1])
