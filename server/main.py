
from pathlib import Path
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
import schemas as _schemas
import services as _services
import fastapi as _fastapi
import db, services, os
import sqlalchemy.orm as _orm
from db import Base, engine, SessionLocal
from models import Keys
from fastapi.middleware.cors import CORSMiddleware
import base64
from sqlalchemy.ext.asyncio import AsyncSession
import sqlalchemy as _sql

app = _fastapi.FastAPI()


# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  
#     allow_methods=["*"],  
#     allow_headers=["*"],
# )



    



class payload_to_server:
    pass

first = payload_to_server()

fields = {"title":"Server_Key",
        "date":"21.01.2026@1856PM",
        "ext": "21.01.2026@1858PM",
        "pub_key": "435r4v43vt4rcr4",
        "jwt": "svfidvrEGve32"}


for field, value in fields.items():
  setattr(first, field, value)



    
@app.post("/key")
async def create_user(user: _schemas.PublicKeyRequest_Base, db: AsyncSession = _fastapi.Depends(_services.get_async_db())):
    owner_id_onepadded = _services.one_pad_encrypt(user.owner_id).encrypt()
    db_user = _services.get_user_by_owner_id(owner_id_onepadded, db)
    if(db_user):
        # raise _fastapi.HTTPException(status_code=400, detail="there is the user with owner_id")
        owner_id_onepadded = db_user.owner_id_onepadded
        private_key = db_user.pv_key
        public_key = db_user.pub_key
        data_created = db_user.data_created
        expires_in = db_user.expires_in
        jwt = db_user.jwt
    else:
        jwt_token = await _services.generate_token(user)
        user_obj = Keys(pub_key=os.getenv("SERVER_PUB_KEY"), owner_id=user.owner_id, jwt=jwt_token)

        await db.add(user_obj)
        await db.commit(user_obj)
        await db.refresh(user_obj)
    
        # payload = 

    return {"pub_key": f"{'done'}"}
    
    
@app.post("/")
async def create_user(payload: _schemas.DataResponse, db: AsyncSession = _fastapi.Depends(_services.get_async_db())):

    stmt = _sql.select(Keys.pub_key).where(Keys.owner_id == payload.owner_id)
    result = await db.execute(stmt)
    _services.verify_token()
    
    decoded_jwt = _services.verify_token(payload.jwt, )
    db_user = _services.get_user_by_owner_id(owner_id_onepadded, db)
    if(db_user):
        # raise _fastapi.HTTPException(status_code=400, detail="there is the user with owner_id")
        owner_id_onepadded = db_user.owner_id_onepadded
        private_key = db_user.pv_key
        public_key = db_user.pub_key
        data_created = db_user.data_created
        expires_in = db_user.expires_in
        jwt = db_user.jwt
    else:
        private_key, public_key = key_generating().key_pair_str()  
        user_obj = Keys(pv_key=private_key, pub_key=public_key, owner_id=owner_id_onepadded)

        await db.add(user_obj)
        await db.commit(user_obj)
        await db.refresh(user_obj)
    
    return {"pub_key": f"{'done'}"}
    
    
# @app.post("/")
# async def save_text(file: _fastapi.UploadFile = _fastapi.File()):
#     path = Path.cwd()/f"{str(uuid.uuid4())}.jpg"
#     content = await file.read()
#     with open (path, "wb") as f:
#         f.write(content)
#     return
