# JetStream Web Application Documentation

## Table of Contents

1. [Project Overview](./01-PROJECT-OVERVIEW.md) - Introduction, scope, and objectives
2. [Architecture](./02-ARCHITECTURE.md) - System design and component hierarchy
3. [Tech Stack](./03-TECH-STACK.md) - Technologies and dependencies
4. [Requirements](./04-REQUIREMENTS.md) - Functional & non-functional requirements
5. [Components](./05-COMPONENTS.md) - React component documentation
6. [API Reference](./06-API-REFERENCE.md) - Services, hooks, and interfaces
7. [Use Cases](./07-USE-CASES.md) - User scenarios and diagrams
8. [Database Schema](./08-DATABASE.md) - LocalStorage schema and data models
9. [Testing](./09-TESTING.md) - Testing strategies and examples
10. [Deployment](./10-DEPLOYMENT.md) - Build and deployment procedures
11. [Security](./11-SECURITY.md) - Security guidelines and best practices
12. [Glossary](./12-GLOSSARY.md) - Terms and abbreviations

---

## Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Project Structure

```
web/
├── docs/                    # Documentation
├── public/                  # Static assets
├── src/
│   ├── components/          # Reusable UI components
│   ├── contexts/            # React Context providers
│   ├── hooks/               # Custom React hooks
│   ├── pages/               # Page components
│   ├── services/            # API and utility services
│   ├── store/               # Redux store configuration
│   ├── styles/              # Global styles and themes
│   └── main.tsx             # Application entry point
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## Version

- **Current Version**: 2.0.0
- **Last Updated**: December 2025
- **Status**: Active Development

## Contributors

- Development Team - EWU CSE412 Project

## License

MIT License - See LICENSE file for details
