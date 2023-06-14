from fastapi import APIRouter

from finetuned import model

from embeddings import EmbeddingsTextRequest, OutputFormat

sbert_router = APIRouter()


@sbert_router.post("/text/")
def get_sbert_embedding(req_text: EmbeddingsTextRequest):
    emb = model.get_sbert_embedding(req_text.text, req_text.normalize)
    val = req_text.separator.join(map(str,emb)) if req_text.output_format == OutputFormat.STRING else emb.tolist()
    return {"embedding": val}


clip_router = APIRouter()

@clip_router.post("/text/")
def get_clip_text_embedding(req_text: EmbeddingsTextRequest):
    emb = model.get_clip_text_embedding(req_text.text, req_text.normalize)
    val = req_text.separator.join(map(str,emb)) if req_text.output_format == OutputFormat.STRING else emb.tolist()
    return {"embedding": val}