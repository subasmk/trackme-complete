# init_db.py - Database initialization script

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models import Base, User, Goal, Badge, UserBadge, Checkin
from werkzeug.security import generate_password_hash
from datetime import datetime

# Database URL
DATABASE_URL = "sqlite:///./trackme.db"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)

def init_database():
    """Initialize database with tables and sample data"""
    # Create all tables
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created")
    
    db = SessionLocal()
    
    # Check if admin user already exists
    existing_admin = db.query(User).filter(User.username == "admin").first()
    if not existing_admin:
        # Create admin user
        admin_user = User(
            username="admin",
            email="admin@trackme.com",
            password_hash=generate_password_hash("admin123"),
            is_public=True
        )
        db.add(admin_user)
        db.commit()
        print("✅ Admin user created (username: admin, password: admin123)")
    
    # Create sample badges
    badges = [
        {"name": "Streak Warrior", "description": "Achieve a 7-day streak on any goal",
         "icon_url": "🏆", "rarity": "rare", "criteria": {"type": "streak", "value": 7}},
        {"name": "Consistency King", "description": "Maintain 30+ combined streak days",
         "icon_url": "👑", "rarity": "epic", "criteria": {"type": "total_streak", "value": 30}},
        {"name": "Goal Crusher", "description": "Complete 10 goals",
         "icon_url": "🎯", "rarity": "epic", "criteria": {"type": "goals_completed", "value": 10}},
        {"name": "Category Master", "description": "Complete goals in 5+ different categories",
         "icon_url": "📚", "rarity": "rare", "criteria": {"type": "category_specialization", "value": 5}},
        {"name": "Early Bird", "description": "Check-in before 7 AM for 5 days",
         "icon_url": "🌅", "rarity": "common", "criteria": {"type": "early_checkin", "value": 5}},
        {"name": "Night Owl", "description": "Check-in after 10 PM for 5 days",
         "icon_url": "🦉", "rarity": "common", "criteria": {"type": "late_checkin", "value": 5}},
        {"name": "First Steps", "description": "Complete your first goal",
         "icon_url": "🎉", "rarity": "common", "criteria": {"type": "first_goal", "value": 1}},
        {"name": "Perfectionist", "description": "Achieve a 100-day streak",
         "icon_url": "💎", "rarity": "legendary", "criteria": {"type": "perfect_streak", "value": 100}},
    ]
    
    for badge_data in badges:
        badge = Badge(
            name=badge_data["name"],
            description=badge_data["description"],
            icon_url=badge_data["icon_url"],
            rarity=badge_data["rarity"],
            criteria=badge_data["criteria"]
        )
        db.add(badge)
    
    db.commit()
    print(f"✅ {len(badges)} sample badges created")
    
    db.close()
    print("✅ Database initialized successfully!")
    print("🚀 Ready to serve TrackMe API")

if __name__ == "__main__":
    init_database()