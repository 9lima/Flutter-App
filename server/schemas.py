import pydantic as _pydantic
    

class PublicKeyRequest_Base(_pydantic.BaseModel):
    owner_id: str
    clientPublicKeyBase64: str
    hkdfNonce: str
    
    model_config = _pydantic.ConfigDict(from_attributes=True)


class PublicKeyResponse(_pydantic.BaseModel):
    owner_id: str
    pub_key: str
    jwt: str

    model_config = _pydantic.ConfigDict(from_attributes=True)

class DataResponse(_pydantic.BaseModel):
    owner_id: str
    client_pub: str
    hkdfNonce: str
    img: bytes | None | list = None
    jwt: str= None
    nonce: str| list= None
    tag: str= None
    
    model_config = _pydantic.ConfigDict(from_attributes=True)

