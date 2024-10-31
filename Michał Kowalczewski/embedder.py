import uvicorn
from sentence_transformers import SentenceTransformer
from fastapi import FastAPI
from typing import List
from pydantic import BaseModel

app = FastAPI(openapi_url="/v3/api-docs/nlm-service")

class Request(BaseModel):
    data: List[str]

class Vector(BaseModel):
    values: List[float]

class Response(BaseModel):
    vectors: List[Vector]

@app.post("/embeddings")
async def embeddings(request: List[str]):
    model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')
    respone = []
    for v in model.encode(request):
        respone.append(Vector(values= v))
    return respone

if __name__ == "__main__":
    uvicorn.run("embedder:app", port=8081, reload=False, log_level="debug")

