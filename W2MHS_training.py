import tensorflow as tf
import numpy as np
from sklearn.preprocessing import Normalizer
from sklearn.preprocessing import OneHotEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix
import scipy.io as scio
from performance_metrics import plot_roc_curve, plot_confusion_matrix
import os
import sys

'''
Training module: this module is used to train the nueral network. Along with the implementation of the ROC curve and 
confusion matrix as performance metrics for the model.
'''


class batch_kfold_training():
    def __init__(self, training_features, training_labels):
        self.training_features = training_features
        self.training_labels = training_labels
        self.index_in_epoch = 0
        self.num_instances = training_features.shape[0]

    # mini-batching method
    def next_batch(self, batch_size):
        start = self.index_in_epoch
        self.index_in_epoch += batch_size

        # When all the training data is ran, shuffles it
        if self.index_in_epoch > self.num_instances:
            perm = np.arange(self.num_instances)
            np.random.shuffle(perm)
            self.training_features = self.training_features[perm]
            self.training_labels = self.training_labels[perm]
            # Start next epoch
            start = 0
            self.index_in_epoch = batch_size
            assert batch_size <= self.num_instances
        end = self.index_in_epoch

        return self.training_features[start:end], self.training_labels[start:end]

'''
Method used to perform batch normalization. Increases the speed of backpropogation training and improves accuracy of 
model. Method is called only during training.
'''
def batch_normalization_process(inputs,is_training, decay = 0.999):
    epsilon = 0.001
    scale = tf.Variable(tf.ones([inputs.get_shape()[-1]]))
    beta = tf.Variable(tf.zeros([inputs.get_shape()[-1]]))
    pop_mean = tf.Variable(tf.zeros([inputs.get_shape()[-1]]), trainable=False)
    pop_var = tf.Variable(tf.ones([inputs.get_shape()[-1]]), trainable=False)

    if is_training:
        print("Enter batch_norm")
        batch_mean, batch_var = tf.nn.moments(inputs,[0])
        training_mean = tf.assign(pop_mean, pop_mean * decay + batch_mean * (1 - decay))
        training_var = tf.assign(pop_var, pop_var * decay + batch_var * (1 - decay))

        with tf.control_dependencies([training_mean, training_var]):
            return tf.nn.batch_normalization(inputs, batch_mean, batch_var, scale, beta, epsilon)
    else:
        return tf.nn.batch_normalization(inputs, pop_mean, pop_var, scale, beta, epsilon)


'''
performs preprocessing on the data before passing the data through the neural network
'''
def main(flag):
    training_path = os.path.join(os.path.dirname(__file__), 'training')

    print("Loading features_training.mat...")
    features = scio.loadmat(os.path.join(training_path, 'features_training.mat'))['features']
    print("Loading labels_training.mat...")
    labels = scio.loadmat(os.path.join(training_path, 'labels_training.mat'))['labels']

    # normalizes the features matrix
    features = Normalizer().fit_transform(np.matrix(features, dtype=np.float32))
    # generates one hot encoded labels
    labels = OneHotEncoder().fit_transform(np.where(np.array(labels, dtype=np.int32) > 0, 1, 0)).toarray()

    # splits the data into training and testing sets
    X_train, X_test, Y_train, Y_test = train_test_split(features, labels, test_size=0.2, random_state=42)

    # declares the necessary inputs for creating a neural network
    input_size, hidden_1_size, hidden_2_size, hidden_3_size, output_size = X_train.shape[1], 1000, 1000, 500, 2
    TRAINING_ITERATIONS = 500
    BATCH_SIZE = 300
    log_path = os.path.join(training_path, 'log')

    # used for dropout regularization
    keep_prob = tf.placeholder_with_default(1.0, shape=(), name="keep_prob")

    # construction of the DNN framework
    def NeuralNetwork(is_training):
        # placeHolders for features and labels
        X = tf.placeholder(dtype=tf.float32, shape=[None, input_size], name='features')
        Y = tf.placeholder(dtype=tf.int32, name='labels')

        # xavier intializer to distribute the randomization of weights evenly.
        Xint = tf.contrib.layers.xavier_initializer()

        # initializes the weights and biases of the network
        with tf.name_scope("Initializaton"):
            Hidden_Layer = {
                'Weights': tf.Variable(tf.random_normal(shape=[input_size, hidden_1_size]), Xint, name="W1"),
                'Biases': tf.Variable(tf.zeros(shape=[hidden_1_size]), tf.float32, name="B1")}
            Hidden_Layer1 = {
                'Weights': tf.Variable(tf.random_normal(shape=[hidden_1_size, hidden_2_size]), Xint, name="W2"),
                'Biases': tf.Variable(tf.zeros(shape=[hidden_2_size]), tf.float32, name="B2")}
            Hidden_Layer2 = {
                'Weights': tf.Variable(tf.random_normal(shape=[hidden_2_size, hidden_3_size]), Xint, name="W3"),
                'Biases': tf.Variable(tf.zeros(shape=[hidden_3_size]), tf.float32, name="B3")}
            Output_Layer = {
                'Weights': tf.Variable(tf.random_normal(shape=[hidden_3_size, output_size]), Xint, name="WO"),
                'Biases': tf.Variable(tf.zeros(shape=[output_size]), tf.float32, name="BO")}
        # initializes layer 1 of the neural network
        with tf.name_scope("layer1"):
            X = tf.nn.dropout(X, keep_prob)
            z1 = tf.add(tf.matmul(X, Hidden_Layer['Weights']), Hidden_Layer['Biases'])
            l1_batch = batch_normalization_process(z1, is_training)
            # Applies the activation function
            l1 = tf.nn.relu(l1_batch, name="Layer1")
        # initializes layer 2 of the neural network
        with tf.name_scope("layer2"):
            l1 = tf.nn.dropout(l1, keep_prob)
            z2 = tf.add(tf.matmul(l1, Hidden_Layer1['Weights']), Hidden_Layer1['Biases'])
            l2_batch = batch_normalization_process(z2, is_training)
            l2 = tf.nn.relu(l2_batch, name="Layer2")
        # initializes layer 3 of the neural network
        with tf.name_scope("layer3"):
            l2 = tf.nn.dropout(l2, keep_prob)
            z3 = tf.add(tf.matmul(l2, Hidden_Layer2['Weights']), Hidden_Layer2['Biases'])
            l3_batch = batch_normalization_process(z3, is_training)
            # Applies softmax function on the output(logits)
            l3 = tf.nn.relu(l3_batch, name="Layer3")

        l3 = tf.nn.dropout(l3, keep_prob)
        # final output layer for the4 neural network
        output = tf.add(tf.matmul(l3, Output_Layer['Weights']), Output_Layer['Biases'], name="result")
        # applies softmax function on the output (logits)
        Output = tf.nn.softmax(output, name="Output_Layer")

        # predicting the loss in the training model
        with tf.name_scope("loss"):
            loss = tf.nn.softmax_cross_entropy_with_logits(labels=Y, logits=output, name="loss")
            Entropy = tf.reduce_mean(loss, name="loss_function")

        # training the model using adam optimizer
        with tf.name_scope("Train"):
            optimizer = tf.train.AdamOptimizer(learning_rate=0.01)
            training_step = optimizer.minimize(Entropy, name="training")

        # predicting the accuracy of the model
        with tf.name_scope("Accuracy"):
            prediction = tf.equal(tf.argmax(Y, 1), tf.argmax(output, 1), name="prediction")
            Accuracy = tf.reduce_mean(tf.cast(prediction, tf.float32), name="Accuracy")

        # storing the results to visualize it on tensorboard
        tf.summary.scalar("Xentropy", Entropy)
        tf.summary.scalar("Accuracy", Accuracy)
        Merged = tf.summary.merge_all()

        return (X, Y), training_step, Accuracy, Output, tf.train.Saver()

    (X, Y), training_step, Accuracy, y_pred, saver = NeuralNetwork(is_training=True)
    clf = batch_kfold_training(X_train, Y_train)
    #predict_labels = tf.arg_max(y_pred, 1, name='y_pred')
    # running the tensorflow session
    with tf.Session()as sess:
        Writer = tf.summary.FileWriter(log_path, graph=tf.get_default_graph())
        sess.run(tf.global_variables_initializer())
        # batch_wise cross validation training
        print('Starting training...')
        for i in range(TRAINING_ITERATIONS):
            batch_xs, batch_ys = clf.next_batch(BATCH_SIZE)

            # Logs every 10 iterations
            if i % 10 == 0:
                train_accuracy = sess.run(Accuracy, feed_dict={X: batch_xs, Y: batch_ys, keep_prob: 1.0})
                print("step %d, training accuracy %g" % (i, train_accuracy))

            sess.run(training_step, feed_dict={X: batch_xs, Y: batch_ys, keep_prob: 0.5})

        print('Training finished')
        cv_accuracy = sess.run(Accuracy, feed_dict={X: X_test, Y: Y_test, keep_prob: 1.0})
        predict_probability = sess.run(y_pred, feed_dict={X: X_test, keep_prob: 1.0})
        saver.save(sess, os.path.join(training_path, 'Training_model'))
        sess.close()


        print('validation_accuracy => %.4f' % cv_accuracy)

        if flag == 'True':
       # print(predict_probability)
            prediction = np.argmax(predict_probability, axis=1)
            true_labels = np.argmax(Y_test, axis=1)
            print(prediction[100:150])
            print(true_labels[100:150])
            cm = confusion_matrix(true_labels, prediction)
            true_pred = predict_probability[:, 1]

            print(cm)
            cm_path = os.path.join(training_path, 'confusion_matrix.png')
            plot_confusion_matrix(cm, target_names=['WHM', 'NON_WHM'], normalize=False, file_path=cm_path)
            roc_path = os.path.join(training_path, 'roc_curve.png')
            plot_roc_curve(true_labels, true_pred, file_path=roc_path)

        #return np.asarray(prediction, dtype=np.float32)


if __name__ == '__main__':
    os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # suppress TensorFlow warnings
    if len(sys.argv) > 1:
        main(sys.argv[1])
    else:
        main('False')
    # np.savetxt(os.path.join(training_path, 'DNN_training_file.csv'), main())
