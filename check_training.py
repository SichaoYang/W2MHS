import os

'''
checks if the necessay files are present within the training_path
'''


def main(training_path):

    features_train_file = os.path.join(training_path, 'features_training.mat')
    labels_train_file = os.path.join(training_path, 'labels_training.mat')

    # checks if the feature_training and labels_training files are present
    if os.path.exists(features_train_file) and os.path.exists(labels_train_file):
        Training_model_file = os.path.join(training_path, 'Training_model.meta')
        Training_index_file = os.path.join(training_path, 'Training_model.index')
        Training_data_file = os.path.join(training_path, 'Training_model.data-00000-of-00001')
        Training_check_point = os.path.join(training_path, 'checkpoint')

        # checks if the output files from the training script present
        if os.path.exists(Training_data_file) and os.path.exists(Training_index_file) and os.path.exists(
                Training_data_file) and os.path.exists(Training_check_point):
            print("Files present in the directory")
            print("Training not required")
            # return the chk value (chk = 1)
            chk = 1


        else:
            print('Some outputs from training our missing')
            print('Start the training process')
            chk = 0

    # if the features and labels training file not present exit
    else:
        raise Exception('features_training.mat and labels_training.mat not present in the training_path.')

    return chk


if __name__ == '__main__':
    main('training')
