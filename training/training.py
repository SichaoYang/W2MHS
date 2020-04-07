from os.path import isfile
from scipy.io import loadmat, savemat
from sklearn.preprocessing import Normalizer
from keras.models import Sequential
from keras.layers import Dense, Activation, BatchNormalization, Dropout
from keras.optimizers import Adam


def load_data():
    if not isfile('features_training.mat') or not isfile('labels_training.mat'):
        raise Exception('"features_training.mat" and "labels_training.mat" not found in the current path.')
    print('Loading features_training.mat...')
    features = loadmat('features_training.mat')['features']
    features = Normalizer().fit_transform(features)  # row normalization: ||x(i)|| = 1
    print('Loading labels_training.mat...')
    labels = loadmat('labels_training.mat')['labels'] > 0  # {-1,1} -> {0,1}
    return features, labels


def build_model():
    model = Sequential()
    # model.add(BatchNormalization(name='bn0'))  # column normalization
    # hidden layer 1
    model.add(Dense(1000, input_dim=2000, kernel_initializer='he_normal', name='l1'))
    model.add(BatchNormalization(name='bn1'))
    model.add(Activation('relu'))
    model.add(Dropout(0.5))
    # hidden layer 2
    model.add(Dense(1000, kernel_initializer='he_normal', name='l2'))
    model.add(BatchNormalization(name='bn2'))
    model.add(Activation('relu'))
    model.add(Dropout(0.5))
    # hidden layer 3
    model.add(Dense(500, kernel_initializer='he_normal', name='l3'))
    model.add(BatchNormalization(name='bn3'))
    model.add(Activation('relu'))
    model.add(Dropout(0.5))
    # output layer
    model.add(Dense(1, kernel_initializer='glorot_normal', name='l4'))
    model.add(Activation('sigmoid'))

    model.compile(optimizer=Adam(lr=0.001, decay=0.01, amsgrad=True),
                  loss='binary_crossentropy',
                  metrics=['accuracy'])
    return model


def save_params():
    p = {'epsilon': 0.001}  # batch normalization epsilon
    for i in range(1, 4):   # batch normalization parameters
        p[f'gamma{i}'], p[f'beta{i}'], p[f'mean{i}'], p[f'std{i}'] = model.get_layer(f'bn{i}').get_weights()
    for i in range(1, 5):   # weights and biases
        p[f'W{i}'], p[f'b{i}'] = model.get_layer(f'l{i}').get_weights()
    savemat('model.mat', p)


if __name__ == '__main__':
    model = build_model()
    X, Y = load_data()
    model.fit(X, Y, validation_split=0.1, epochs=10, batch_size=256)
    save_params()
