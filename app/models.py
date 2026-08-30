# models.py - Database models for TrackMe backend

from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, ForeignKey, JSON, Index
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    bio = Column(Text)
    avatar_url = Column(String(500))
    is_public = Column(Boolean, default=True)  # Privacy control
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    goals = relationship("Goal", back_populates="user", cascade="all, delete-orphan")
    user_badges = relationship("UserBadge", back_populates="user", cascade="all, delete-orphan")
    checkins = relationship("Checkin", back_populates="user", cascade="all, delete-orphan")

class Goal(Base):
    __tablename__ = "goals"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String(100), nullable=False)
    description = Column(Text)
    category = Column(String(50))
    target_streak = Column(Integer, default=0)
    current_streak = Column(Integer, default=0)
    longest_streak = Column(Integer, default=0)
    last_checkin_date = Column(DateTime)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="goals")
    checkins = relationship("Checkin", back_populates="goal", cascade="all, delete-orphan")

class Badge(Base):
    __tablename__ = "badges"
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    icon_url = Column(String(500))
    criteria = Column(JSON)  # JSON structure for badge criteria
    rarity = Column(String(20), default="common")  # common, rare, epic, legendary
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user_badges = relationship("UserBadge", back_populates="badge", cascade="all, delete-orphan")

class UserBadge(Base):
    __tablename__ = "user_badges"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    badge_id = Column(Integer, ForeignKey("badges.id"), nullable=False)
    earned_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="user_badges")
    badge = relationship("Badge", back_populates="user_badges")

class Checkin(Base):
    __tablename__ = "checkins"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    goal_id = Column(Integer, ForeignKey("goals.id"), nullable=False)
    date = Column(DateTime, default=datetime.utcnow)
    notes = Column(Text)  # Private content - only visible to user
    learning_summary = Column(Text)
    mood = Column(Integer, default=3)  # 1-5 rating scale
    location = Column(String(100))
    evidence_url = Column(String(500))  # URL to image/audio file
    
    # Relationships
    user = relationship("User", back_populates="checkins")
    goal = relationship("Goal", back_populates="checkins")

# Create indexes for performance
Index("idx_user_username", User.username)
Index("idx_goal_user", Goal.user_id)
Index("idx_checkin_user", Checkin.user_id)
Index("idx_checkin_date", Checkin.date)