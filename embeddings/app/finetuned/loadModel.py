import requests


def download_url(url, save_path, chunk_size=128):
    r = requests.get(url, stream=True)
    with open(save_path, 'wb') as fd:
        for chunk in r.iter_content(chunk_size=chunk_size):
            fd.write(chunk)

download_url('https://finetuner-ecommerce-experiment.s3.eu-central-1.amazonaws.com/fine-tuned-sbert-model.zip', '/code/app/fine-tuned-sbert-model.zip')
download_url('https://finetuner-ecommerce-experiment.s3.eu-central-1.amazonaws.com/fine-tuned-clip-model.zip', '/code/app/fine-tuned-clip-model.zip')

# transformers 4.20 (pinned by finetuner) can't follow the Hugging Face hub's relative redirects any more, so we
# download what the fine-tuned models need from their base models up front. transformers looks for a local directory
# named after the model first, and the service runs from /code/app.
from huggingface_hub import snapshot_download

for repo_id in ['sentence-transformers/msmarco-distilbert-base-v3', 'openai/clip-vit-large-patch14']:
    snapshot_download(repo_id, local_dir=f'/code/app/{repo_id}', allow_patterns=['*.json', '*.txt'])
