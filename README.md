# TrackMe Backend

A social learning streak tracker API with privacy controls and a rich badge system.

## Overview

TrackMe is a complete backend solution for the Flutter mobile app that enables:
- User authentication and profiles
- Social features with privacy controls
- Goal tracking and streak management
- Comprehensive badge system
- Public profile browsing and search

## Project Structure

```
trackme_backend/
├── app/
│   ├── __init__.py              # Package initialization
│   ├── main.py                  # FastAPI application entry point
│   ├── models.py                # SQLAlchemy models
│   ├── routers/                 # API endpoints
│   │   ├── auth_router.py       # Authentication endpoints
│   │   ├── user_router.py       # User profile endpoints
│   │   ├── goal_router.py       # Goals management endpoints
│   │   └── badge_router.py      # Badge system endpoints
│   └── services/                # Business logic services
│       ├── auth_service.py      # Authentication logic
│       ├── badge_service.py     # Badge award logic
│       └── email_service.py     # Email utilities (if needed)
├── migrations/
│   ├── alembic.ini            # Alembic configuration
│   └── script.py.migrations/  # Migration scripts
├── docker/                    # Docker configuration
│   ├── Dockerfile
│   └── docker-compose.yml
├── scripts/                   # Utility scripts
│   ├── init_db.py            # Database initialization
│   └── requirements.txt      # Backend dependencies
└── README.md                 # Project documentation
```

## Features

### 🎯 Core Features

1. **JWT Authentication**
   - Secure user registration and login
   - Token-based authentication
   - Session management

2. **Privacy-First Profiles**
   - Public vs private profile controls
   - Selective data sharing
   - Privacy settings management

3. **Goal Management**
   - Create, update, delete goals
   - Streak tracking and history
   - Category organization
   - Progress monitoring

4. **Badge System**
   - Multiple badge rarities (Common, Rare, Epic, Legendary)
   - Dynamic badge awarding based on achievements
   - Badge collection management
   - Social badge flexing

5. **Social Features**
   - Public profile browsing
   - User search
   - Follow/friend relationships (planned)
   - Social comparison features

### 🛡️ Security

- **JWT Authentication**: Secure token-based auth
- **Input Validation**: Comprehensive validation
- **Rate Limiting**: API protection
- **CORS**: Cross-origin resource sharing
- **Environment Variables**: Secure secret management

### 📱 API Design

#### Authentication
```http
POST /auth/register
POST /auth/login
GET /auth/me
```

#### User Profiles
```http
GET /users/{username}          # Public profile
GET /users/search?q={query}    # User search
PUT /users/{id}                # Update profile
```

#### Goals Management
```http
GET /goals                     # List user's goals
POST /goals                   # Create new goal
PUT /goals/{id}               # Update goal
DELETE /goals/{id}            # Delete goal
```

#### Badges & Achievements
```http
GET /badges                   # All available badges
GET /user-badges              # User's earned badges
```

## Technology Stack

### Backend
- **Framework**: FastAPI
- **Database**: PostgreSQL
- **ORM**: SQLAlchemy
- **Auth**: JWT (PyJWT)
- **Security**: werkzeug.security
- **Deployment**: Docker + systemd

### Deployment
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Service Management**: systemd
- **Reverse Proxy**: Caddy (with HTTPS/SSL)

### API Design
- **RESTful**: RESTful API design
- **Documentation**: Auto-generated Swagger UI
- **Error Handling**: Consistent error responses
- **Testing**: Comprehensive API testing setup

## Quick Start

### Prerequisites

```bash
# Install Docker
curl https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Clone this repository
git clone https://github.com/your-username/trackme-backend.git
cd trackme-backend

# Set up environment variables
# Copy .env.example to .env and fill in secrets
cp .env.example .env

# Start the application
./scripts/start.sh
```

### Running Locally

```bash
# Start with Docker Compose
docker-compose up -d

# Or run directly with Python
pip install -r requirements.txt
python -m uvicorn app.main:app --reload
```

### Database Setup

```bash
# Initialize database with sample data
python scripts/init_db.py
```

## API Documentation

The API is documented with Swagger UI. Visit:
- `http://localhost:8000/docs` (Swagger UI)
- `http://localhost:8000/redoc` (ReDoc)

## Docker Compose

The Docker setup includes:
- PostgreSQL database
- FastAPI application
- Reverse proxy with HTTPS

```yaml
docker-compose.yml
docker/
Dockerfile
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support, please create an issue in the repository.
