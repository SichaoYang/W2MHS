import matplotlib.pyplot as plt
import numpy as np
import itertools
from sklearn.metrics import roc_curve, roc_auc_score
import os

'''
measures the performance of the training model by plotting the confusion matrix and roc curve, with the raw auc score.
The higher the auc score, the higher the accuracy is.
'''
training_path = os.path.join(os.path.dirname(__file__), 'training')


# plots the roc curve
def plot_roc_curve(true_labels, predict_prob, file_path=""):
    # calling the ROC function to print the ROC curve
    fpr, tpr, threshold = roc_curve(true_labels, predict_prob)
    # calculating the ROC score
    roc_auc = roc_auc_score(true_labels, predict_prob)
    print("auc score:", roc_auc)
    # plotting
    plt.figure()
    plt.plot(fpr, tpr, label='ROC curve (area = %f)' % roc_auc)
    plt.plot([0, 1], [0, 1], 'k--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.0])
    plt.xlabel("False positive rate")
    plt.ylabel("True positive rate")
    plt.title("ROC curve")
    plt.legend(loc='lower right')
    if file_path == "":
        plt.show()
    else:
        plt.savefig(file_path)


# plots the confusion matrix
def plot_confusion_matrix(cm, target_names, title='Confusion Matrix', cmap=None, normalize=True, file_path=""):
    accuracy_rate = np.trace(cm) / float(np.sum(cm))
    misclass = 1 - accuracy_rate

    if cmap is None:
        cmap = plt.get_cmap('Blues')

    plt.figure(figsize=(8, 6))
    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title)
    plt.colorbar()

    if target_names is not None:
        tick_marks = np.arange(len(target_names))
        plt.xticks(tick_marks, target_names, rotation=45)
        plt.yticks(tick_marks, target_names)

    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]

    thresh = cm.max() / 1.5 if normalize else cm.max() / 2
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        if normalize:
            plt.text(j, i, "{:0.4f}".format(cm[i, j]),
                     horizontalalignment="center",
                     color="white" if cm[i, j] > thresh else "black")
        else:
            plt.text(j, i, "{:,}".format(cm[i, j]),
                     horizontalalignment="center",
                     color="white" if cm[i, j] > thresh else "black")

    plt.tight_layout()
    plt.ylabel('True label')
    plt.xlabel('Predicted label\naccuracy={:0.4f}; misclass={:0.4f}'.format(accuracy_rate, misclass))
    if file_path == "":
        plt.show()
    else:
        plt.savefig(file_path)

