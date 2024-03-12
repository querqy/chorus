import finetuner

from finetuner.callback import EvaluationCallback

# To use finetuner an account for the Jina AI Cloud is required.
finetuner.login()

DATASET_RUN_NAME = 'ecommerce-synthesis'  # should be the same as in data_synthesis.py

train_dataset_name = finetuner.get_run(DATASET_RUN_NAME).train_data

training_run = finetuner.fit(
    model='sbert-base-en',
    train_data=train_dataset_name,
    loss='MarginMSELoss',
    # This loss function is specific for the unsupervised training
    # on generated data. It expects triplet of a query and two
    # documents associated with a margin relevance score.
    optimizer='Adam',
    learning_rate=1e-5,
    # choose a small learning rate since the model is already pre-trained
    epochs=1,
    # for fine-tuning usually one epoch is enough
    batch_size=16,
    # too high batch-sizes can lead to memory issues
)

print(training_run.name)

# print logs
for entry in training_run.stream_logs():
    print(entry)

# download model
training_run.save_artivact('finetuned_sbert_model')
