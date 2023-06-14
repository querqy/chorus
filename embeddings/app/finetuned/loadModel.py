import requests


def download_url(url, save_path, chunk_size=128):
    r = requests.get(url, stream=True)
    with open(save_path, 'wb') as fd:
        for chunk in r.iter_content(chunk_size=chunk_size):
            fd.write(chunk)

download_url('https://finetuner-ecommerce-experiment.s3.eu-central-1.amazonaws.com/fine-tuned-sbert-model.zip', '/code/app/fine-tuned-sbert-model.zip')
download_url('https://finetuner-ecommerce-experiment.s3.eu-central-1.amazonaws.com/fine-tuned-clip-model.zip', '/code/app/fine-tuned-clip-model.zip')