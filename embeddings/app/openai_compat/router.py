from functools import lru_cache

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from minilm.model import get_text_sentence_embedding as get_minilm_embedding
from clipL14.model import get_text_sentence_embedding as get_clip_embedding
from finetuned.model import get_sbert_embedding, get_clip_text_embedding

# OpenAI compatible embeddings endpoint, so that Solr's language-models module
# (dev.langchain4j.model.openai.OpenAiEmbeddingModel) can vectorise queries with our models.

router = APIRouter()

MODELS = {
    "minilm": get_minilm_embedding,
    "clip": get_clip_embedding,
    "ftbert": get_sbert_embedding,
    "ftclip": get_clip_text_embedding,
}


class OpenAiEmbeddingsRequest(BaseModel):
    model: str
    input: list[str] | str


# Solr vectorises the query text again on each shard and in each phase of a distributed search,
# so remember recent embeddings rather than running the model several times per search.
@lru_cache(maxsize=1024)
def embed(model: str, text: str) -> tuple:
    return tuple(MODELS[model](text, False).tolist())


@router.post("/embeddings")
def get_embeddings(req: OpenAiEmbeddingsRequest):
    if req.model not in MODELS:
        raise HTTPException(status_code=404, detail=f"Unknown model {req.model}, use one of {list(MODELS)}")
    texts = [req.input] if isinstance(req.input, str) else req.input
    data = [{"object": "embedding", "index": i, "embedding": list(embed(req.model, text))}
            for i, text in enumerate(texts)]
    return {"object": "list", "model": req.model, "data": data, "usage": {"prompt_tokens": 0, "total_tokens": 0}}
