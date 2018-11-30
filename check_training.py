import os

'''
checks if the necessay files are present within the training_path
'''


def main(training_path):
    training_model_file = os.path.join(training_path, 'Training_model.meta')
    training_index_file = os.path.join(training_path, 'Training_model.index')
    training_data_file = os.path.join(training_path, 'Training_model.data-00000-of-00001')
    training_check_point = os.path.join(training_path, 'checkpoint')

    # checks if the output files from the training script present
    if os.path.exists(training_model_file) and os.path.exists(training_index_file) and os.path.exists(
            training_data_file) and os.path.exists(training_check_point):
        print("Files present in the directory")
        print("Training not required")
        return 1
    print('Some outputs from training are missing')

    features_train_file = os.path.join(training_path, 'features_training.mat')
    labels_train_file = os.path.join(training_path, 'labels_training.mat')

    # checks if feature_training and labels_training are present
    if os.path.exists(features_train_file) and os.path.exists(labels_train_file):
        print('Start the training process')
        return 0

    # if the features and labels training file not present, exit
    raise Exception('features_training.mat and labels_training.mat not present in the training_path.')


if __name__ == '__main__':
    main('training')
