import datetime as _dt

import sqlalchemy as _sql
import sqlalchemy.orm as _orm
import passlib.hash as _hash
from sqlalchemy_imageattach.entity import Image, image_attachment


import db as _database

class Keys(_database.Base, Image):
    __tablename__ = "keys"
    id = _sql.Column(_sql.Integer, primary_key=True, index = True)
    pv_key = _sql.Column(_sql.String, unique=True, index = True)
    pub_key = _sql.Column(_sql.String, unique=True, index = True)
    owner_id = _sql.Column(_sql.Integer, _sql.ForeignKey("incomming.owner_id"))
    hashed_token = _sql.Column(_sql.String, unique=True, index = True)
    data_created = _sql.Column(_sql.DateTime, default=_dt.datetime.utcnow)
    expires_in = _sql.Column(_sql.DateTime, default=_dt.datetime.utcnow)

    incomming = _orm.relationship("Image", back_populates="owner")


class Incomming(_database.Base):
    __tablename__ = "incomming"
    id = _sql.Column(_sql.Integer, primary_key=True, index = True)
    image = _sql.Column(_sql.LargeBinary)
    owner_id = _sql.Column(_sql.Integer, _sql.ForeignKey("keys.owner_id"))
    in_token = _sql.Column(_sql.String, unique=True, index = True)
    data_created = _sql.Column(_sql.DateTime, default=_dt.datetime.utcnow)

    owner = _orm.relationship("Keys", back_populates="incomming")

    def verify_token(self, token:str):
        return _hash.bcrypt.verify(token, self.hashed_token)


