import finetuner
from finetuner.model import synthesis_model_en

from docarray import DocumentArray

DATASET_RUN_NAME = 'ecommerce-synthesis'

finetuner.login(force=True)

# load the datasets pre-prepared for Finetuner
queries = DocumentArray.load_binary('sbert_unsupervised/queries.da')
corpus = DocumentArray.load_binary('sbert_unsupervised/corpus.da')

# upload the data to the Jina AI Cloud
queries.push('ecommerce-queries')
corpus.push('ecommerce-corpus')

# start the data synthesis cloud job
synthesis_run = finetuner.synthesize(
    query_data='ecommerce-queries',
    corpus_data='ecommerce-corpus',
    run_name=DATASET_RUN_NAME,
    models=synthesis_model_en,
    num_relations=10,
)

# print the name of the run (should be the same as DATASET_RUN_NAME)
print(synthesis_run.name)

# print logs
for entry in synthesis_run.stream_logs():
    print(entry)

# download results
train_data_name = synthesis_run.train_data
train_data = DocumentArray.pull(train_data_name)
train_data.summary()
