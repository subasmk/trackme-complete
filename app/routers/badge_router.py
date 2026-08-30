# badge_router.py - Badge system endpoints

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.models import Badge, UserBadge
from app.dependencies import get_db, get_current_user_id

router = APIRouter(prefix="/badges", tags=["badges"])

@router.get("", response_model=List[dict])
async def get_all_badges(db: Session = Depends(get_db)):
    """Get all available badges"""
    badges = db.query(Badge).all()
    result = []
    for badge in badges:
        count = db.query(UserBadge).filter(UserBadge.badge_id == badge.id).count()
        result.append({
            "id": badge.id,
            "name": badge.name,
            "description": badge.description,
            "icon_url": badge.icon_url,
            "rarity": badge.rarity,
            "criteria": badge.criteria,
            "awarded_to_users": count
        })
    return result

@router.get("/user/{user_id}", response_model=List[dict])
async def get_user_earned_badges(user_id: int, db: Session = Depends(get_db)):
    """Get badges earned by a specific user"""
    user_badges = db.query(UserBadge).filter(UserBadge.user_id == user_id).all()
    result = []
    for ub in user_badges:
        badge = db.query(Badge).filter(Badge.id == ub.badge_id).first()
        if badge:
            result.append({
                "id": badge.id,
                "name": badge.name,
                "description": badge.description,
                "icon_url": badge.icon_url,
                "rarity": badge.rarity,
                "earned_at": ub.earned_at
            })
    return result

@router.post("/award/{user_id}")
async def award_badges_to_user(user_id: int, db: Session = Depends(get_db)):
    """Trigger badge checking and award any earned badges"""
    from app.services.badge_service import BadgeService
    badge_service = BadgeService(db)
    earned = badge_service.check_and_award_badges(user_id)
    return {
        "message": f"Awarded {len(earned)} new badges to user {user_id}",
        "earned_badges": [{"name": e.badge.name, "rarity": e.badge.rarity} for e in earned]
    }
