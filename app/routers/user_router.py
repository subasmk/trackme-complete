# user_router.py - User profile endpoints

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import List, Optional
from app.models import User, Goal, Badge, UserBadge
from app.dependencies import get_db, get_current_user_id

router = APIRouter(prefix="/users", tags=["users"])

class PublicProfile(BaseModel):
    id: int
    username: str
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    is_public: bool
    created_at: str

class PublicProfileResponse(BaseModel):
    id: int
    username: str
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    stats: dict
    badges: List[dict]

class UserSearch(BaseModel):
    id: int
    username: str
    avatar_url: Optional[str] = None
    is_public: bool

@router.get("/{username}", response_model=PublicProfileResponse)
async def get_user_profile(username: str, db: Session = Depends(get_db)):
    """Get public profile"""
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_public:
        raise HTTPException(status_code=403, detail="This profile is private")
    
    # Get goals stats
    goals = db.query(Goal).filter(Goal.user_id == user.id).all()
    total_goals = len(goals)
    current_streaks = sum(g.current_streak or 0 for g in goals)
    longest_streak = max((g.longest_streak or 0) for g in goals) if goals else 0
    
    # Get badge collection
    user_badges = db.query(UserBadge).filter(UserBadge.user_id == user.id).all()
    badges = []
    for ub in user_badges:
        badge = db.query(Badge).filter(Badge.id == ub.badge_id).first()
        if badge:
            badges.append({
                "name": badge.name,
                "description": badge.description,
                "icon_url": badge.icon_url,
                "rarity": badge.rarity,
                "earned_at": ub.earned_at
            })
    
    return PublicProfileResponse(
        id=user.id,
        username=user.username,
        bio=user.bio,
        avatar_url=user.avatar_url,
        stats={
            "total_goals": total_goals,
            "current_streaks": current_streaks,
            "longest_streak": longest_streak,
            "member_since": user.created_at
        },
        badges=badges
    )

@router.get("/search", response_model=List[UserSearch])
async def search_users(q: str, limit: int = 20, db: Session = Depends(get_db)):
    """Search users by username"""
    users = db.query(User).filter(
        User.username.ilike(f"%{q}%")
    ).limit(limit).all()
    
    return [
        UserSearch(
            id=u.id,
            username=u.username,
            avatar_url=u.avatar_url,
            is_public=u.is_public
        ) for u in users
    ]

@router.get("/{user_id}/public")
async def get_public_data(user_id: int, db: Session = Depends(get_db)):
    """Get public data for a user by ID"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_public:
        raise HTTPException(status_code=403, detail="This profile is private")
    
    return {
        "id": user.id,
        "username": user.username,
        "bio": user.bio,
        "avatar_url": user.avatar_url,
        "created_at": user.created_at
    }