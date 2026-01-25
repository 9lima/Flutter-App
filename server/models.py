import datetime as _dt
import sqlalchemy as _sql
import sqlalchemy.orm as _orm
from sqlalchemy.orm import DeclarativeBase
import sqlalchemy.orm as _orm

engine = _sql.create_engine("sqlite:///database.db", connect_args={"check_same_thread": False}, pool_pre_ping=True,pool_size=10,max_overflow=20,)
SessionLocal = _orm.sessionmaker(autocommit=False, bind=engine)




class Base(DeclarativeBase):
    pass


class Key(Base):
    __tablename__ = "keys"

    id = _sql.Column(_sql.Integer, primary_key=True, index=True)

    pv_key = _sql.Column(_sql.String, unique=True, index=True)
    pub_key = _sql.Column(_sql.String, unique=True, index=True)
    
    pv_key_Ed25519 = _sql.Column(_sql.String, unique=True, index=True)
    pub_key_Ed25519 = _sql.Column(_sql.String, unique=True, index=True)

    created_at = _sql.Column(_sql.Integer, default=int(_dt.datetime.now().timestamp()))
    users = _orm.relationship("User", back_populates="key", cascade="all, delete-orphan")


class User(Base):
    __tablename__ = "users"

    id = _sql.Column(_sql.Integer, primary_key=True, index = True, unique=True)
    owner_id = _sql.Column( _sql.Integer, nullable=False, index=True )

    jwt = _sql.Column(_sql.String, unique=True, index = True)
    data_created = _sql.Column(_sql.Integer, default=int(_dt.datetime.now().timestamp()))
    exp = _sql.Column(_sql.Integer)
    image = _sql.Column(_sql.LargeBinary, nullable=True)

    key_id = _sql.Column(_sql.Integer,_sql.ForeignKey("keys.id"))

    key = _orm.relationship("Key", back_populates="users")


# if __name__ == "__main__":


