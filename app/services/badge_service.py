# badge_service.py - Badge awarding and management logic

from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import and_
from app.models import Badge, UserBadge, User, Goal, Checkin

class BadgeService:
    def __init__(self, db: Session):
        self.db = db
    
    def get_all_badges(self):
        """Get all available badges"""
        return self.db.query(Badge).all()
    
    def get_user_badges(self, user_id: int):
        """Get all badges earned by a user"""
        return self.db.query(UserBadge).filter(UserBadge.user_id == user_id).all()
    
    def check_and_award_badges(self, user_id: int):
        """Check and award badges based on user activity"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return []
        
        goals = self.db.query(Goal).filter(Goal.user_id == user_id).all()
        checkins = self.db.query(Checkin).filter(Checkin.user_id == user_id).all()
        
        earned_badges = []
        
        # Check for streak-based badges
        for goal in goals:
            streak = goal.current_streak or 0
            if streak >= 7:
                earned_badges.extend(self._award_badge(user_id, "Streak Warrior", 
                    "Achieve a 7-day streak on any goal", "🏆", "rare", 
                    {"type": "streak", "value": streak}))
            
            if streak >= 30:
                earned_badges.extend(self._award_badge(user_id, "Consistency King", 
                    "Maintain 30+ combined streak days", "👑", "epic", 
                    {"type": "total_streak", "value": streak}))
        
        # Check for goals completed
        total_completed = sum(1 for goal in goals if (goal.target_streak and goal.current_streak >= goal.target_streak))
        if total_completed >= 10:
            earned_badges.extend(self._award_badge(user_id, "Goal Crusher", 
                "Complete 10 goals", "🎯", "epic", 
                {"type": "goals_completed", "value": total_completed}))
        
        # Check for category specialization
        if len(goals) >= 5:
            categories = [goal.category for goal in goals if goal.category]
            unique_categories = len(set(categories))
            if unique_categories >= 5:
                earned_badges.extend(self._award_badge(user_id, "Category Master", 
                    "Complete goals in 5+ different categories", "📚", "rare", 
                    {"type": "category_specialization", "value": unique_categories}))
        
        # Check for early bird patterns
        from datetime import datetime
        early_checkins = sum(1 for c in checkins 
                           if c.date and c.date.hour < 7)  # Check-in before 7 AM
        if early_checkins >= 5:
            earned_badges.extend(self._award_badge(user_id, "Early Bird", 
                "Check-in before 7 AM for 5 days", "🌅", "common", 
                {"type": "early_checkin", "value": early_checkins}))
        
        return earned_badges
    
    def _award_badge(self, user_id: int, badge_name: str, description: str, 
                    icon: str, rarity: str, criteria: dict):
        """Award a badge to a user if not already earned"""
        # Get or create badge
        badge = self.db.query(Badge).filter(Badge.name == badge_name).first()
        if not badge:
            badge = Badge(
                name=badge_name,
                description=description,
                icon_url=icon,
                criteria=criteria,
                rarity=rarity
            )
            self.db.add(badge)
            self.db.commit()
        
        # Check if user already has this badge
        existing = self.db.query(UserBadge).filter(
            and_(UserBadge.user_id == user_id, UserBadge.badge_id == badge.id)
        ).first()
        
        if not existing:
            user_badge = UserBadge(
                user_id=user_id,
                badge_id=badge.id
            )
            self.db.add(user_badge)
            self.db.commit()
            return [user_badge]
        
        return []
