# AgeEstimAI

#### Project for the course Applied Deep Learning 2023 at the TU Vienna. 

In this deep learning project a model is developed to estimate a persons age from a face image. Age estimation (AE) has been a subject of research for many years. Over time, various features have been investigated for their relevance in age prediction, ranging from activity and blood data to medical imaging outputs. Historically, the predominant methods involved manual feature extraction combined with traditional machine learning techniques. However, newer approaches often shifted to deep learning. One prominent application of deep learning in this domain is the use of facial images for age estimation.

The UTKFace dataset, detailed in Chapter 2, was chosen for training the model. Ten- sorFlow was used as the primary framework for implementing the models. The initial model implemented was EfficientNetB0, with hyperparameter tuning covering optimiz- ers, loss functions, batch sizes, learning rate schedules, augmentation, and model scaling, as described in Chapter 4.

After optimizing the EfficientNet model, several strategies were considered to improve the performance. These included (1) Extending the training dataset with other available face datasets or using pre-training for transfer learning. A common approach is perform- ing face recognition as a pre-training task. These approaches are well deonstrated to improve a models performance. (2) Doing more systematic hyperparameter tuning and experimenting with different augmentation techniques. This option is very computation- ally intensive. (3) Splitting the dataset based on specific demographic criteria, such as gender or ethnicity, and developing seperate models for each subgroup. (4) Implementing more advanced model architectures.

In this work I chose to focus on reimplementing a novel architecture that yielded a significant improvement in age estimation performance on the MORPH2 dataset, reducing the mean absolute error (MAE) from 1.97 years to 1.3 years. The architecture combines the generation of multiple augmented versions of a single image, processing each through a convolutional neural network and then aggregating the image embeddings via transformer- encoders. This architecture is described in more details in section 3.

#### The full project report can be found in "Project_Report_AgeEstimAI.pdf".
