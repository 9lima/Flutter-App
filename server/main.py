# from cryptography.hazmat.primitives.asymmetric import x25519
# from cryptography.hazmat.primitives import serialization

import uuid, os, shutil
from pathlib import Path
from typing import List, Optional, Annotated
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from pydantic import BaseModel
import schemas as _schemas
import fastapi as _fastapi
import fastapi.security as _security
import sqlalchemy.orm as _orm

app = _fastapi.FastAPI(title='Fast API',description='Flutter Client')

UPLOAD_DIR = "uploaded_images"

# def generate_key_pair():
#     private_key = x25519.X25519PrivateKey.generate()
#     private_key_bytes = private_key.private_bytes(
#                 encoding=serialization.Encoding.PEM,
#                 format=serialization.PrivateFormat.PKCS8,
#                 encryption_algorithm=serialization.NoEncryption())

#     public_key = private_key.public_key()
#     public_key_bytes = public_key.public_bytes(
#                 encoding=serialization.Encoding.PEM,
#                 format=serialization.PublicFormat.SubjectPublicKeyInfo)
    
#     return private_key_bytes, public_key_bytes



# @app.put("/")
# async def to_client(file: Annotated[bytes, File(description="A file read as bytes")]):

#     return 'to client'


@app.get("/")
def root():
    return "FastAPIdddd"


class Payload(BaseModel):
    text: str

@app.post("/key")
async def create_user(key: _schemas.):
    path = Path.cwd()/"text.txt"
    path.write_text(request.text, encoding="utf-8")
    data = await request.read()
    print(data)



# @app.post("/")
# async def save_text(file: _fastapi.UploadFile = _fastapi.File()):
#     path = Path.cwd()/f"{str(uuid.uuid4())}.jpg"
#     content = await file.read()
#     with open (path, "wb") as f:
#         f.write(content)
#     return



