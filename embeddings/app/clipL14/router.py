from fastapi import APIRouter

from clipL14.model import get_text_sentence_embedding

from embeddings import EmbeddingsTextRequest, OutputFormat

router = APIRouter()


@router.post("/text/")
def get_text_embedding(req_text: EmbeddingsTextRequest):
    emb = get_text_sentence_embedding(req_text.text, req_text.normalize)
    val = req_text.separator.join(map(str,emb)) if req_text.output_format == OutputFormat.STRING else emb.tolist()
    return {"embedding": val}
