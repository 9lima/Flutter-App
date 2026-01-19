import db as _database
import models
import sqlalchemy.orm as _orm


def create_db():
    return _database.Base.metadata.create_all(bind=_database.engine)

def get_db():
    db = _database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Optional

# -------------------------------
# Schemas for Incomming
# -------------------------------

class IncommingBase(BaseModel):
    owner_id: int


class IncommingRead(IncommingBase):
    id: int
    data_created: datetime

    class Config:
        orm_mode = True

class IncommingData(IncommingBase):
    data_created: datetime
    in_token:
    image:

    class Config:
        orm_mode = True

# -------------------------------
# Schemas for Keys
# -------------------------------

class KeysBase(BaseModel):
    pv_key: str = Field(..., example="private_key_here")
    pub_key: str = Field(..., example="public_key_here")
    expires_in: datetime


class KeysCreate(IncommingBase):
    pv_key: str
    pub_key: str
    hashed_token: str
    data_created: datetime

class KeysRead(KeysBase):
    id: int
    data_created: datetime
    incomming: List[IncommingRead] = []  # nested incoming images

    class Config:
        orm_mode = True




async def get_user_by_email():
    return db.query(_models.)