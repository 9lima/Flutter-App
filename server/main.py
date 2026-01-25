
import schemas as _schemas
import services as _services
from contextlib import asynccontextmanager
from models import Key, User
import fastapi as _fastapi
import sqlalchemy.orm as _orm
import threading
from fastapi.middleware.cors import CORSMiddleware
import sqlalchemy as _sql
import datetime as _dt


app = _fastapi.FastAPI()
thread = threading.Thread(target=_services.generating_keys, daemon=True)
thread.start()

@app.post("/")
async def create_user(user: _schemas.PublicKeyRequest_Base, db: _orm.Session = _fastapi.Depends(_services.create_get_db)):
    user_exist = await _services.get_user_by_owner_id(user.owner_id, db)
    if user_exist:

        raise _fastapi.HTTPException(status_code=400, detail="User exists")
    
        
    row_object = _services.get_newest_KeyRow(db)
    server_pub, ed25519_pv = (row_object.pub_key, row_object.pv_key_Ed25519)
    expire = int(_dt.datetime.now().timestamp() + 360)
    payload = {"pub_key":server_pub, "exp":expire}
    token = _services.generate_token_payload(payload, expire, ed25519_pv)
    payload.update({"jwt":token})
    res_payload = _schemas.PublicKeyResponse.model_validate(payload)

    db_user = User(owner_id=user.owner_id, jwt=token, key_id = row_object.id, exp=expire)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return res_payload
    


@app.get("/")
async def get_users(db: _orm.Session = _fastapi.Depends(_services.create_get_db)):
    results = db.execute(_sql.select(User))
    users = results.scalars().first()
    return {"users": users}

