import pydantic as _pydantic
    

class PublicKeyRequest_Base(_pydantic.BaseModel):
    owner_id: str

    model_config = _pydantic.ConfigDict(from_attributes=True)


class PublicKeyResponse(PublicKeyRequest_Base):
    pub_key: str
    jwt: str

    model_config = _pydantic.ConfigDict(from_attributes=True)

class DataResponse(PublicKeyRequest_Base):
    owner_id: str
    encrypted_aes: str
    img: bytes | None
    jwt: str
    
    model_config = _pydantic.ConfigDict(from_attributes=True)

