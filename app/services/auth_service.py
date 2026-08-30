# auth_service.py - Authentication and authorization logic

from datetime import datetime, timedelta
from jose import JWTError, jwt
from werkzeug.security import generate_password_hash, check_password_hash
from sqlalchemy.orm import Session
from .models import User

# JWT Configuration
SECRET_KEY = "trackme-super-secret-key-change-in-production-2024"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_HOURS = 24

class AuthService:
    def __init__(self, db: Session):
        self.db = db
    
    def register_user(self, username: str, email: str, password: str) -> User:
        """Register a new user"""
        # Check if user already exists
        existing_user = self.db.query(User).filter(
            (User.username == username) | (User.email == email)
        ).first()
        
        if existing_user:
            if existing_user.username == username:
                raise ValueError("Username already taken")
            else:
                raise ValueError("Email already registered")
        
        # Create new user
        password_hash = generate_password_hash(password)
        new_user = User(
            username=username,
            email=email,
            password_hash=password_hash,
            is_public=True  # Default to public profile
        )
        
        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        
        return new_user
    
    def authenticate_user(self, username: str, password: str) -> dict:
        """Authenticate user and return token"""
        user = self.db.query(User).filter(User.username == username).first()
        
        if not user:
            raise ValueError("Invalid username or password")
        
        if not check_password_hash(user.password_hash, password):
            raise ValueError("Invalid username or password")
        
        # Generate JWT token
        token = self._generate_token(user.id)
        
        return {
            "token": token,
            "user_id": user.id,
            "username": user.username,
            "email": user.email
        }
    
    def verify_token(self, token: str) -> int:
        """Verify JWT token and return user_id"""
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            user_id = payload.get("sub")
            if user_id is None:
                raise ValueError("Invalid token")
            return int(user_id)
        except JWTError:
            raise ValueError("Invalid or expired token")
    
    def get_user_by_id(self, user_id: int) -> User:
        """Get user by ID"""
        return self.db.query(User).filter(User.id == user_id).first()
    
    def update_user(self, user_id: int, **kwargs) -> User:
        """Update user profile"""
        user = self.get_user_by_id(user_id)
        if not user:
            raise ValueError("User not found")
        
        # Update allowed fields
        allowed_fields = ['bio', 'avatar_url', 'is_public', 'username', 'email']
        for key, value in kwargs.items():
            if key in allowed_fields and value is not None:
                setattr(user, key, value)
        
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def _generate_token(self, user_id: int) -> str:
        """Generate JWT access token"""
        payload = {
            "sub": user_id,
            "exp": datetime.utcnow() + timedelta(hours=ACCESS_TOKEN_EXPIRE_HOURS),
            "iat": datetime.utcnow()
        }
        return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    
    def get_public_profile(self, username: str, requesting_user_id: int = None) -> dict:
        """Get public profile data for a user"""
        user = self.db.query(User).filter(User.username == username).first()
        
        if not user:
            raise ValueError("User not found")
        
        # If profile is private and not the owner, raise error
        if not user.is_public and (requesting_user_id != user.id):
            raise ValueError("This profile is private")
        
        return {
            "id": user.id,
            "username": user.username,
            "bio": user.bio,
            "avatar_url": user.avatar_url,
            "is_public": user.is_public,
            "created_at": user.created_at.isoformat() if user.created_at else None
        }
