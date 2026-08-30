# main.py - FastAPI application entry point

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.models import Base
from app.dependencies import engine, SessionLocal
from app.routers import auth_router, user_router, goal_router, badge_router

# Create tables on startup
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Create database tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    # Shutdown
    await engine.dispose()

# Initialize FastAPI app
app = FastAPI(
    title="TrackMe Backend",
    description="Social learning streak tracker API",
    version="1.0.0",
    lifespan=lifespan
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router)
app.include_router(user_router)
app.include_router(goal_router)
app.include_router(badge_router)

# Health check endpoint
@app.get("/")
async def root():
    return {"status": "TrackMe Backend is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}