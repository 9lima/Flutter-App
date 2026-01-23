import datetime as _dt
import random,string
import sqlalchemy as _sql
import sqlalchemy.orm as _orm
import passlib.hash as _hash
from passlib.context import CryptContext
import jwt
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.ext.asyncio import AsyncSession, AsyncAttrs


import db as _database

class Base(AsyncAttrs, DeclarativeBase):
    pass


class Keys(Base):
    __tablename__ = "keys"
    id = _sql.Column(_sql.Integer, primary_key=True, index = True)
    pv_key = _sql.Column(_sql.String, unique=True, index = True)
    pub_key = _sql.Column(_sql.String, unique=True, index = True)
    owner_id_onepadded = _sql.Column(_sql.Integer, unique=True, index = True)
    owner_id = _sql.Column(_sql.Integer, unique=True, index = True)
    jwt = _sql.Column(_sql.String, unique=True, index = True)
    in_token = _sql.Column(_sql.String, unique=True, index = True)
    data_created = _sql.Column(_sql.Integer, default=_dt.datetime.now())
    exp = _sql.Column(_sql.Integer, default=_dt.datetime.now()+ _dt.timedelta(minutes=3))
    image = _sql.Column(_sql.LargeBinary)




