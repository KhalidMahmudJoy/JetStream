# Deployment Documentation

## 1. Build Process

### 1.1 Build Configuration

**Build Tool**: Vite 5.4.21

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
    sourcemap: true,
    minify: 'esbuild',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom', 'react-router-dom'],
          motion: ['framer-motion'],
        },
      },
    },
  },
  server: {
    port: 5173,
    host: true,
  },
});
```

### 1.2 Build Commands

```bash
# Development build with hot reload
npm run dev

# Production build
npm run build

# Preview production build locally
npm run preview

# Type checking
npm run typecheck

# Lint check
npm run lint
```

### 1.3 Build Output

```
dist/
├── index.html
├── assets/
│   ├── index-[hash].js      # Main bundle
│   ├── vendor-[hash].js     # Vendor dependencies
│   ├── motion-[hash].js     # Framer Motion
│   └── index-[hash].css     # Compiled styles
└── favicon.ico
```

---

## 2. Environment Configuration

### 2.1 Environment Variables

```bash
# .env.development
VITE_API_BASE_URL=https://api.deezer.com
VITE_CORS_PROXY=https://corsproxy.io/?
VITE_APP_NAME=JetStream
VITE_APP_VERSION=1.0.0

# .env.production
VITE_API_BASE_URL=https://api.deezer.com
VITE_CORS_PROXY=https://corsproxy.io/?
VITE_APP_NAME=JetStream
VITE_APP_VERSION=1.0.0
```

### 2.2 Using Environment Variables

```typescript
// Access in code
const apiUrl = import.meta.env.VITE_API_BASE_URL;
const appName = import.meta.env.VITE_APP_NAME;

// Type definitions (env.d.ts)
interface ImportMetaEnv {
  readonly VITE_API_BASE_URL: string;
  readonly VITE_CORS_PROXY: string;
  readonly VITE_APP_NAME: string;
  readonly VITE_APP_VERSION: string;
}
```

---

## 3. Deployment Options

### 3.1 Static Hosting (Recommended)

The application is a static SPA and can be deployed to any static hosting service.

#### Vercel Deployment

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Production deployment
vercel --prod
```

**Vercel Configuration** (`vercel.json`):
```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "framework": "vite",
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

#### Netlify Deployment

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy

# Production deployment
netlify deploy --prod
```

**Netlify Configuration** (`netlify.toml`):
```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

#### GitHub Pages Deployment

```bash
# Install gh-pages
npm install --save-dev gh-pages

# Add to package.json scripts
"deploy": "npm run build && gh-pages -d dist"

# Deploy
npm run deploy
```

**Vite Config for GitHub Pages**:
```typescript
export default defineConfig({
  base: '/jetstream/',  // Repository name
  // ... other config
});
```

---

### 3.2 Docker Deployment

**Dockerfile**:
```dockerfile
# Build stage
FROM node:18-alpine AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

**nginx.conf**:
```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

**Docker Commands**:
```bash
# Build image
docker build -t jetstream-web .

# Run container
docker run -d -p 8080:80 jetstream-web

# With docker-compose
docker-compose up -d
```

---

### 3.3 Cloud Platform Deployment

#### AWS S3 + CloudFront

```bash
# Install AWS CLI
pip install awscli

# Sync build to S3
aws s3 sync dist/ s3://jetstream-bucket --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id XXXXXX --paths "/*"
```

**S3 Bucket Policy**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::jetstream-bucket/*"
    }
  ]
}
```

#### Azure Static Web Apps

```yaml
# azure-static-web-apps.yml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches: [main]

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          app_location: "/"
          output_location: "dist"
```

---

## 4. CI/CD Pipeline

### 4.1 GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck
      - run: npm run test:coverage

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - run: npm ci
      - run: npm run build
      
      - uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: dist
          path: dist
      
      # Deploy to your hosting service
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

---

## 5. Performance Optimization

### 5.1 Build Optimizations

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    // Enable minification
    minify: 'esbuild',
    
    // Generate sourcemaps for debugging
    sourcemap: true,
    
    // Chunk splitting
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom', 'react-router-dom'],
          motion: ['framer-motion'],
          icons: ['lucide-react'],
        },
      },
    },
    
    // Asset size warnings
    chunkSizeWarningLimit: 500,
  },
});
```

### 5.2 Asset Optimization

```typescript
// Image optimization
import imagemin from 'vite-plugin-imagemin';

export default defineConfig({
  plugins: [
    react(),
    imagemin({
      gifsicle: { optimizationLevel: 7 },
      optipng: { optimizationLevel: 7 },
      mozjpeg: { quality: 80 },
      svgo: {
        plugins: [{ removeViewBox: false }],
      },
    }),
  ],
});
```

### 5.3 Caching Strategy

```nginx
# nginx.conf
location ~* \.(js|css)$ {
    expires 1y;
    add_header Cache-Control "public, max-age=31536000, immutable";
}

location ~* \.(png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, max-age=31536000, immutable";
}

location = /index.html {
    expires -1;
    add_header Cache-Control "no-store, must-revalidate";
}
```

---

## 6. Monitoring & Analytics

### 6.1 Error Tracking

```typescript
// src/utils/errorTracking.ts
import * as Sentry from '@sentry/react';

Sentry.init({
  dsn: import.meta.env.VITE_SENTRY_DSN,
  environment: import.meta.env.MODE,
  tracesSampleRate: 0.1,
});

export const captureError = (error: Error, context?: object) => {
  console.error(error);
  Sentry.captureException(error, { extra: context });
};
```

### 6.2 Analytics Integration

```typescript
// src/utils/analytics.ts
export const trackEvent = (eventName: string, properties?: object) => {
  if (import.meta.env.PROD) {
    // Google Analytics
    window.gtag?.('event', eventName, properties);
  }
};

// Usage
trackEvent('track_played', { trackId: track.id, title: track.title });
trackEvent('playlist_created', { playlistId: playlist.id });
```

---

## 7. Rollback Procedures

### 7.1 Vercel Rollback

```bash
# List deployments
vercel ls

# Rollback to specific deployment
vercel rollback [deployment-url]
```

### 7.2 GitHub Actions Rollback

```yaml
# Manual rollback workflow
name: Rollback

on:
  workflow_dispatch:
    inputs:
      commit_sha:
        description: 'Commit SHA to rollback to'
        required: true

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          ref: ${{ github.event.inputs.commit_sha }}
      
      - run: npm ci
      - run: npm run build
      - name: Deploy
        # ... deployment steps
```

---

## 8. Health Checks

### 8.1 Application Health

```typescript
// public/health.json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### 8.2 Monitoring Script

```bash
#!/bin/bash
# health-check.sh

URL="https://jetstream.example.com"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ $RESPONSE -eq 200 ]; then
    echo "Application is healthy"
    exit 0
else
    echo "Application is unhealthy (HTTP $RESPONSE)"
    exit 1
fi
```

---

## 9. Security Checklist

### Pre-Deployment

- [ ] All dependencies updated
- [ ] No known vulnerabilities (`npm audit`)
- [ ] Environment variables secured
- [ ] CORS properly configured
- [ ] CSP headers configured
- [ ] HTTPS enforced

### Post-Deployment

- [ ] SSL certificate valid
- [ ] Security headers present
- [ ] No sensitive data in client bundle
- [ ] Error messages don't leak info
- [ ] Rate limiting enabled (if applicable)
