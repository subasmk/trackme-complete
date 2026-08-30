# goal_router.py - Goals management endpoints

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from pydantic import BaseModel
from app.models import Goal, Checkin
from app.dependencies import get_db, get_current_user_id

router = APIRouter(prefix="/goals", tags=["goals"])

class GoalCreate(BaseModel):
    title: str
    description: Optional[str] = None
    category: Optional[str] = None
    target_streak: Optional[int] = 0

class GoalUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    target_streak: Optional[int] = None
    is_active: Optional[bool] = None

class GoalResponse(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    category: Optional[str] = None
    target_streak: int
    current_streak: int
    longest_streak: int
    last_checkin_date: Optional[str] = None
    is_active: bool
    created_at: str

@router.post("", response_model=GoalResponse)
async def create_goal(
    goal_data: GoalCreate,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id)
):
    new_goal = Goal(
        user_id=user_id,
        title=goal_data.title,
        description=goal_data.description,
        category=goal_data.category,
        target_streak=goal_data.target_streak or 0,
        current_streak=0,
        longest_streak=0
    )
    db.add(new_goal)
    db.commit()
    db.refresh(new_goal)
    return new_goal

@router.get("", response_model=List[GoalResponse])
async def list_goals(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id)
):
    goals = db.query(Goal).filter(
        Goal.user_id == user_id,
        Goal.is_active == True
    ).all()
    
    result = []
    for goal in goals:
        # Get latest checkin info
        latest = db.query(Checkin).filter(
            Checkin.goal_id == goal.id
        ).order_by(Checkin.date.desc()).first()
        
        result.append(GoalResponse(
            id=goal.id,
            title=goal.title,
            description=goal.description,
            category=goal.category,
            target_streak=goal.target_streak,
            current_streak=goal.current_streak or 0,
            longest_streak=goal.longest_streak or 0,
            last_checkin_date=goal.last_checkin_date,
            is_active=goal.is_active,
            created_at=goal.created_at
        ))
    
    return result

@router.get("/stats")
async def get_goal_stats(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id)
):
    goals = db.query(Goal).filter(
        Goal.user_id == user_id,
        Goal.is_active == True
    ).all()
    
    return {
        "total_goals": len(goals),
        "total_streak_days": sum(g.current_streak or 0 for g in goals),
        "active_goals": len([g for g in goals if g.is_active]),
        "total_completed": len([g for g in goals if g.current_streak and g.current_streak >= (g.target_streak or 0)])
    }