# 🚀 Version 2.0 - Quick Start Guide

**Welcome to JetStream V2.0 Development!**

You're now on the `version-2.0-dev` branch. This guide will help you get started with V2 development.

---

## 📍 Current Status

- ✅ V2 branch created (`version-2.0-dev`)
- ✅ Documentation updated
- ✅ Roadmap defined
- 🔨 Ready to start Phase 1: Backend Foundation

---

## 🎯 Your Current Focus: Phase 1 - Backend Foundation

### What You'll Build (Weeks 1-4)

1. **Backend API Server**
   - Node.js with Express
   - TypeScript setup
   - RESTful API structure

2. **Database**
   - PostgreSQL setup
   - Schema design
   - Migrations

3. **Authentication**
   - User registration/login
   - JWT tokens
   - Password security

---

## 🛠️ Setup Instructions

### 1. Install Additional Tools

You'll need these for V2 development:

```powershell
# PostgreSQL Database
# Download from: https://www.postgresql.org/download/windows/
# Install with default settings

# Postman (for API testing)
# Download from: https://www.postman.com/downloads/

# Optional: Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop
```

### 2. Create Backend Structure

```powershell
# You're in the project root
cd backend

# Install dependencies (if not already done)
npm install

# Create environment file
Copy-Item .env.example .env

# Edit .env with your settings
notepad .env
```

### 3. Configure Database

```env
# Add to backend/.env
DATABASE_URL="postgresql://postgres:yourpassword@localhost:5432/jetstream"
JWT_SECRET="your-super-secret-jwt-key-change-this"
PORT=3001
```

### 4. Start Development

```powershell
# Terminal 1: Run backend
cd backend
npm run dev

# Terminal 2: Run frontend (web app)
cd web
npm run dev
```

---

## 📁 Backend Structure (To Be Created)

```
backend/
├── src/
│   ├── controllers/        # Request handlers
│   │   ├── authController.ts
│   │   ├── userController.ts
│   │   └── playlistController.ts
│   ├── models/            # Database models
│   │   ├── User.ts
│   │   ├── Playlist.ts
│   │   └── Song.ts
│   ├── routes/            # API routes
│   │   ├── authRoutes.ts
│   │   ├── userRoutes.ts
│   │   └── playlistRoutes.ts
│   ├── middleware/        # Custom middleware
│   │   ├── auth.ts
│   │   ├── errorHandler.ts
│   │   └── validator.ts
│   ├── services/          # Business logic
│   │   ├── authService.ts
│   │   ├── userService.ts
│   │   └── lyricsService.ts
│   ├── utils/             # Helper functions
│   │   ├── jwt.ts
│   │   ├── password.ts
│   │   └── logger.ts
│   ├── config/            # Configuration
│   │   ├── database.ts
│   │   └── env.ts
│   └── index.ts           # Entry point
├── prisma/                # Database schema
│   ├── schema.prisma
│   └── migrations/
├── tests/                 # Test files
├── .env.example          # Example environment
├── .env                  # Your settings (git ignored)
├── package.json
└── tsconfig.json
```

---

## 🎓 Learning Path

### Week 1: Node.js & Express Basics

**Goal**: Set up basic API server

**Tasks**:
1. ✅ Read Express.js documentation
2. ✅ Set up TypeScript with Node.js
3. ✅ Create basic "Hello World" API
4. ✅ Set up nodemon for auto-restart
5. ✅ Test with Postman

**Resources**:
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)

### Week 2: Database & ORM

**Goal**: Connect to PostgreSQL and define models

**Tasks**:
1. Install PostgreSQL
2. Set up Prisma ORM
3. Design database schema
4. Create migrations
5. Test CRUD operations

**Resources**:
- [Prisma Documentation](https://www.prisma.io/docs)
- [PostgreSQL Tutorial](https://www.postgresqltutorial.com/)

### Week 3: Authentication

**Goal**: Implement user registration and login

**Tasks**:
1. Create User model
2. Hash passwords with bcrypt
3. Generate JWT tokens
4. Implement register endpoint
5. Implement login endpoint
6. Test with Postman

**Resources**:
- [JWT Introduction](https://jwt.io/introduction)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

### Week 4: API Endpoints

**Goal**: Build core API endpoints

**Tasks**:
1. User profile endpoints
2. Playlist CRUD endpoints
3. User preferences endpoints
4. Error handling middleware
5. API documentation

**Resources**:
- [REST API Tutorial](https://restfulapi.net/)
- [Swagger/OpenAPI](https://swagger.io/docs/)

---

## 🧪 Testing Your Work

### Test Backend API

```powershell
# Run tests
cd backend
npm test

# Manual testing with curl
curl http://localhost:3001/api/health
```

### Test with Postman

1. Create a new collection: "JetStream V2 API"
2. Add requests:
   - POST `/api/auth/register`
   - POST `/api/auth/login`
   - GET `/api/users/me`
   - GET `/api/playlists`

---

## 📊 Phase 1 Checklist

Track your progress:

### Backend Setup
- [ ] Node.js and npm installed
- [ ] PostgreSQL installed and running
- [ ] Backend folder structure created
- [ ] Dependencies installed
- [ ] Environment variables configured
- [ ] TypeScript configured

### Database
- [ ] Prisma ORM installed
- [ ] Database connection working
- [ ] Schema designed
- [ ] Migrations created
- [ ] Can perform CRUD operations

### Authentication
- [ ] User model created
- [ ] Password hashing implemented
- [ ] JWT token generation working
- [ ] Register endpoint functional
- [ ] Login endpoint functional
- [ ] Token validation working

### API Endpoints
- [ ] User registration works
- [ ] User login works
- [ ] Get user profile works
- [ ] Update user profile works
- [ ] Create playlist works
- [ ] Get user playlists works

### Quality Assurance
- [ ] Error handling implemented
- [ ] Input validation added
- [ ] API tested with Postman
- [ ] Basic unit tests written
- [ ] Code documented

---

## 🐛 Common Issues & Solutions

### Issue: PostgreSQL won't start
**Solution**: 
```powershell
# Check if service is running
Get-Service -Name postgresql*

# Start service
Start-Service -Name postgresql-x64-14
```

### Issue: Port 3001 already in use
**Solution**:
```powershell
# Find process using port
netstat -ano | findstr :3001

# Kill process (replace PID)
taskkill /PID <process-id> /F
```

### Issue: Database connection fails
**Solution**:
- Check PostgreSQL is running
- Verify credentials in .env
- Check DATABASE_URL format
- Test connection: `psql -U postgres`

### Issue: JWT token not working
**Solution**:
- Verify JWT_SECRET is set in .env
- Check token format (Bearer token)
- Validate token expiration time
- Test token generation separately

---

## 📚 Recommended VS Code Extensions

Install these for better development experience:

```
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension Prisma.prisma
code --install-extension humao.rest-client
code --install-extension ms-vscode.vscode-typescript-next
```

---

## 🎯 Next Steps

After completing Phase 1:

1. **Review your work**
   - All endpoints tested
   - Documentation complete
   - Code reviewed

2. **Create PR (if working with team)**
   ```bash
   git add .
   git commit -m "feat: Complete Phase 1 - Backend Foundation"
   git push origin feature/backend-foundation
   ```

3. **Move to Phase 2**
   - See [V2_ROADMAP.md](V2_ROADMAP.md)
   - Integrate frontend with backend
   - Add authentication flow to web app

---

## 💡 Tips for Success

1. **Commit Often**
   - Commit after each feature
   - Use descriptive commit messages
   - Push to remote regularly

2. **Test Everything**
   - Test each endpoint as you build
   - Don't wait until the end
   - Use Postman collections

3. **Document as You Go**
   - Add comments to complex code
   - Update API documentation
   - Keep README current

4. **Ask for Help**
   - Check GitHub Issues
   - Ask teammates
   - Search Stack Overflow
   - Read official documentation

---

## 📞 Need Help?

- 📖 **Documentation**: [V2_ROADMAP.md](V2_ROADMAP.md)
- 💬 **Questions**: Create GitHub Issue
- 🐛 **Bugs**: Report in Issues
- 📧 **Email**: jetstream-dev@example.com

---

<div align="center">

**🚀 Happy Coding! Let's build V2.0! 🚀**

[V2 Roadmap](V2_ROADMAP.md) | [Main README](README.md) | [Changelog](CHANGELOG.md)

</div>
