from enum import Enum
from pydantic import BaseModel


class OutputFormat(str,Enum):
    FLOAT_LIST = "float_list"
    STRING = "string"


class EmbeddingsRequest(BaseModel):
    output_format: OutputFormat = OutputFormat.FLOAT_LIST
    separator: str | None = None
    normalize: bool = True


class EmbeddingsTextRequest(EmbeddingsRequest):
    text: str


class EmbeddingsImageRequest(EmbeddingsRequest):
    url: str
