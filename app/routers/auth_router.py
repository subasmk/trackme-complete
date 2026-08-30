# auth_router.py - Authentication endpoints

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.services.auth_service import AuthService
from app.dependencies import get_db, get_current_user_id

router = APIRouter(prefix="/auth", tags=["auth"])

class UserRegister(BaseModel):
    username: str
    email: str
    password: str

class UserLogin(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    token: str
    token_type: str = "bearer"
    user_id: int
    username: str
    email: str

@router.post("/register", response_model=TokenResponse)
async def register(user_data: UserRegister, db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    try:
        user = auth_service.register_user(
            username=user_data.username,
            email=user_data.email,
            password=user_data.password
        )
        token_data = auth_service.authenticate_user(user_data.username, user_data.password)
        return TokenResponse(
            token=token_data["token"],
            user_id=user.id,
            username=user.username,
            email=user.email
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/login", response_model=TokenResponse)
async def login(user_data: UserLogin, db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    try:
        token_data = auth_service.authenticate_user(
            username=user_data.username,
            password=user_data.password
        )
        return TokenResponse(
            token=token_data["token"],
            user_id=token_data["user_id"],
            username=token_data["username"],
            email=token_data["email"]
        )
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))

@router.get("/me")
async def get_me(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    auth_service = AuthService(db)
    user = auth_service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return {
        "id": user.id,
        "username": user.username,
        "email": user.email,
        "bio": user.bio,
        "avatar_url": user.avatar_url,
        "is_public": user.is_public,
        "created_at": user.created_at
    }