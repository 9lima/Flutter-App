import models as _models
import sqlalchemy.orm as _orm
import sqlalchemy as _sql
import random,string
import asyncio, os, dotenv, pathlib, threading
import datetime as _dt
import jwt, base64, time, base64
from secrets import choice   
from string import printable
import schemas as _schemas
from sqlalchemy import ForeignKey, func, select
from dotenv import load_dotenv, find_dotenv


from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey,Ed25519PublicKey
from cryptography.hazmat.primitives.serialization import load_pem_public_key, load_pem_private_key
from models import engine

class one_pad_encrypt:
    def __init__(self, message:str):
        self.message = message
        self.pad=""
        self.ciphertext = ""
        self.plaintext = ""
        self.pad = ''.join(choice(string.printable) for _ in range(len(self.message)))

    def encrypt(self) -> str:
        self.ciphertext = ''.join(chr(ord(m) ^ ord(p)) for m, p in zip(self.message, self.pad))
        return self.ciphertext

    def decrypt(self) -> str:
        decrypted = ''.join(chr(ord(c) ^ ord(p)) for c, p in zip(self.ciphertext, self.pad))
        return decrypted



def create_get_db():
    if not (_sql.inspect(_models.engine).has_table("keys") and _sql.inspect(_models.engine).has_table("users")):
        _models.Base.metadata.drop_all(_models.engine)
        _models.Base.metadata.create_all(_models.engine)

    db = _models.SessionLocal()
    try:
        yield db
    finally:
        db.close()



async def get_user_by_owner_id(owner_id: str , db: _orm.Session):
    result = db.execute(select(_models.User).where(_models.User.owner_id == owner_id))
    if result:
        return result.first()
    else:
        return None

def get_newest_KeyRow(db: _orm.Session):
    stmt = (select(_models.Key).order_by(_models.Key.created_at.desc()).limit(1))
    result = db.execute(stmt).scalar_one_or_none()
    return result



class key_generating:
    __slots__ = ('pv_bytes', 'pub_bytes', 'pv_str', 'pub_str', 'aes_key','private_key_Ed25519','public_key_Ed25519')

    def __init__(self):

        private_key = x25519.X25519PrivateKey.generate()
        public_key = private_key.public_key()

        # Store keys as Base64 strings for easy transport / JSON
        self.pv_bytes = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption())

        self.pub_bytes = public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo)

    def key_pair_bytes(self) -> tuple[bytes, bytes]:
        return self.pv_bytes, self.pub_bytes

    def key_pair_str(self) -> tuple[str, str]:
        self.pv_str=str(self.pv_bytes.decode().splitlines()[1])
        self.pub_str = str(self.pub_bytes.decode().splitlines()[1])
        return self.pv_str, self.pub_str

    def generate_aes_key(self, remote_public_key_b64: str) -> bytes:
        remote_pub_bytes = base64.b64encode(remote_public_key_b64)
        remote_public_key = x25519.X25519PublicKey.from_public_bytes(remote_pub_bytes)

        shared_secret = self.pv_bytes.exchange(remote_public_key)

        self.aes_key = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=b"handshake data",
        ).derive(shared_secret)

        return self.aes_key
    

    def generate_Ed25519(self):

        private_key = Ed25519PrivateKey.generate()
        public_key = private_key.public_key()

        self.private_key_Ed25519 = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption())
        
        self.public_key_Ed25519 = public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo)

        return self.private_key_Ed25519, self.public_key_Ed25519



def generate_token_payload(payload: dict, expire:int, private_key) -> str:

    payload = jwt.encode(payload, private_key, algorithm="EdDSA")
    return payload


def verify_token(jwt_token: str, secret: bytes) -> dict:
    try:
        payload = jwt.decode(jwt_token, load_pem_public_key(bytes(secret)), algorithms=["EdDSA"])
        return payload
    except jwt.exceptions.ExpiredSignatureError:
        print("Token expired")




def generating_keys():
    if not (_sql.inspect(_models.engine).has_table("keys") and _sql.inspect(_models.engine).has_table("users")):
        _models.Base.metadata.drop_all(_models.engine)
        _models.Base.metadata.create_all(_models.engine)

    while True:
        db: _orm.Session = _models.SessionLocal()
        try:
            a = key_generating()
            server_pv, server_pub = a.key_pair_str()
            ed25519_pv, ed25519_pub = a.generate_Ed25519()

            new_keys = _models.Key(
                pv_key=server_pv,
                pub_key=server_pub,
                pv_key_Ed25519=ed25519_pv,
                pub_key_Ed25519=ed25519_pub,
            )

            db.add(new_keys)
            db.commit()
            db.refresh(new_keys)

        except Exception as e:
            db.rollback()
            print("Key generation error:", e)

        finally:
            db.close()

        time.sleep(60)



def manage_keys(db: _orm.Session):
    


# if __name__ == "__main__":
#     thread = threading.Thread(
#         target=generating_keys
#     )
#     thread.start()
    


    

    
    
    