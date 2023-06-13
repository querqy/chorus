# Train Models with Jina's Finetuner

This folder contains some example scripts to fine-tune embedding (vector search) models.
More details on the models produced by these scripts and fine-tuning in general are provided in the 13th kata.

All the commands displayed below are meant to be executed from within the folder `finetuning`.

## Setup the Environment

Finetuner runs with Python.
Accordingly, you need a Python environment to run it.
We recommend you to create also a virtual environment by running:
``python3 -m venv venv``
Afterward, you can activate the environment by running:
``source venv/bin/activate``
To install the dependencies, to run the fine-tuning examples, run
``pip install -r requirements.txt``

## Run Unsupervised SBERT fine-tuning (Text-to-Text Search)

To automatically create training data finetuner needs a dataset of documents and a set of queries.
For the corpus we use the product data in `data-encoder/ecommerce/vectors/data`.
Since this dataset does not come with a set of queries (which can usually be extracted from a query log), we generate some queries.
To download them one can execute the following command:
```
wget https://finetuner-ecommerce-experiment.s3.eu-central-1.amazonaws.com/generated-queries.jsonl -P sbert_unsupervised/
```
To extract queries and documents and transform them into Finetuner's preferred format for finetuner execute the following command*:
```
python3 sbert_unsupervised/data_preparation.py
```
*While running the script, a browser window will open up and ask you to log into your Jina account. If you don't have one, you need to sign up to run the script.
After you logged into your account, a session token will be sent back to the script. This token is then used to authenticate the script to the Jina Cloud in order to download or upload models and datasets.

After that, you can run a job to generated training data for a text-to-text embedding model automatically by running:
```
python3 sbert_unsupervised/data_synthesis.py
```

If you terminated the script or the connection to the log stream got interrupted (which happens from time to time),
you can execute the following code in a script or the Python interpreter to get the current status the logs of the job:

```python
import finetuner

finetuner.login()

run = finetuner.get_run('ecommerce-synthesis')
print(f'Status: {run.status()["status"]}')
print('Logs:\n', run.logs())

```


Finally, you can run the fine-tuning job by running:
```
python3 sbert_unsupervised/finetune.py
```
This will save a fine-tuned model in the `finetuning` folder with the name `sbert_unsupervised`.

## Run Unsupervised CLIP fine-tuning (Text-to-Image Search)

For fine-tuning a CLIP model we directly create a dataset with text image pairs from the product dataset.
This can be executed with the following command:
```
python3 clip_unsupervised/data_preparation.py
```
After that the fine-tuning job can be executed with the following command:
```
python3 clip_unsupervised/finetune.py
```

## Integrate the Fine-Tuned Models into Chorus

After running the scripts mentioned above, you obtain fine-tuned embedding models which can be integrated into Chorus.
If you are only interested in the integration, you can download the final models from the following links:
- [sbert_unsupervised](https://finetuner-ecommerce-experiment.s3.eu-central-1.amazonaws.com/fine-tuned-sbert-model.zip)
- [clip_unsupervised](https://finetuner-ecommerce-experiment.s3.eu-central-1.amazonaws.com/fine-tuned-clip-model.zip)
