import finetuner

sbert_model = finetuner.get_model('/code/app/fine-tuned-sbert-model.zip', device='cpu')


def get_sbert_embedding(text: str, normalize: bool = True):
    return finetuner.encode(model=sbert_model, data=[text])[0]


clip_text_model = finetuner.get_model('/code/app/fine-tuned-clip-model.zip', select_model='clip-text', device='cpu')
def get_clip_text_embedding(text: str, normalize: bool = True):
    return finetuner.encode(model=clip_text_model, data=[text])[0]