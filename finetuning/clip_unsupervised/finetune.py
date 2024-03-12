import finetuner
from docarray import DocumentArray

# To use finetuner an account for the Jina AI Cloud is required.
finetuner.login()

training_data = DocumentArray.from_bytes('clip_unsupervised/clip_train_dataset.da')

training_run = finetuner.fit(
    model='clip-large-en',
    # name of the pre-trained model
    train_data=training_data,
    # path to the prepared training dataset
    loss='CLIPLoss',
    # contrastive loss function for text-image pairs
    optimizer='AdamW',
    learning_rate=1e-7,
    # choose a small learning rate since the model is already pre-trained
    batch_size=8,
    # too high batch-sizes can lead to memory issues
    epochs=1,
    # for fine-tuning usually a low number of epochs is enough
)

print(training_run.name)

# print logs
for entry in training_run.stream_logs():
    print(entry)

# download model
training_run.save_artifact('finetuned_clip_model')
