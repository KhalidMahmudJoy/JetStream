# Security Documentation

## 1. Security Overview

### 1.1 Security Principles

| Principle | Implementation |
|-----------|----------------|
| **Defense in Depth** | Multiple layers of security |
| **Least Privilege** | Minimal permissions required |
| **Secure by Default** | Safe default configurations |
| **Data Protection** | Encryption and secure storage |

### 1.2 Threat Model

```
┌─────────────────────────────────────────────────────────────┐
│                    THREAT LANDSCAPE                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  External Threats:                                          │
│  ├── XSS (Cross-Site Scripting)                            │
│  ├── CSRF (Cross-Site Request Forgery)                     │
│  ├── Clickjacking                                          │
│  └── Data Exfiltration                                     │
│                                                              │
│  Client-Side Risks:                                         │
│  ├── LocalStorage tampering                                │
│  ├── Browser extension attacks                             │
│  └── Man-in-the-middle (MITM)                              │
│                                                              │
│  API Risks:                                                 │
│  ├── Rate limiting bypass                                  │
│  └── API key exposure                                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Browser Security

### 2.1 Content Security Policy (CSP)

```html
<!-- index.html -->
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  font-src 'self' https://fonts.gstatic.com;
  img-src 'self' data: https: blob:;
  media-src 'self' https: blob:;
  connect-src 'self' https://api.deezer.com https://corsproxy.io;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
">
```

### 2.2 Security Headers

```nginx
# nginx.conf security headers
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

### 2.3 HTTPS Enforcement

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}

# HSTS Header
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

---

## 3. Data Security

### 3.1 LocalStorage Security

```typescript
// src/utils/secureStorage.ts

// Validate data before storing
const validateTrack = (track: unknown): track is Track => {
  if (!track || typeof track !== 'object') return false;
  const t = track as Record<string, unknown>;
  return (
    typeof t.id === 'string' &&
    typeof t.title === 'string' &&
    typeof t.artist === 'string'
  );
};

// Sanitize before display
const sanitizeString = (str: string): string => {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
};

// Safe storage operations
export const secureStorage = {
  set: (key: string, data: unknown): void => {
    try {
      const serialized = JSON.stringify(data);
      localStorage.setItem(key, serialized);
    } catch (error) {
      console.error('Storage error:', error);
    }
  },
  
  get: <T>(key: string, validator: (data: unknown) => data is T): T | null => {
    try {
      const item = localStorage.getItem(key);
      if (!item) return null;
      
      const parsed = JSON.parse(item);
      if (validator(parsed)) {
        return parsed;
      }
      return null;
    } catch {
      return null;
    }
  },
};
```

### 3.2 Input Sanitization

```typescript
// src/utils/sanitize.ts

// Sanitize user input for display
export const sanitizeForDisplay = (input: string): string => {
  return input
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
};

// Sanitize for URL parameters
export const sanitizeForUrl = (input: string): string => {
  return encodeURIComponent(input.trim());
};

// Validate playlist name
export const validatePlaylistName = (name: string): boolean => {
  const trimmed = name.trim();
  return (
    trimmed.length >= 1 &&
    trimmed.length <= 100 &&
    !/[<>\"\'`]/.test(trimmed)
  );
};
```

### 3.3 No Sensitive Data in Client

```typescript
// ❌ NEVER store in client
// API keys
// User credentials
// Personal identifiable information (PII)

// ✅ Safe to store in client
// User preferences (theme, volume)
// Liked song IDs
// Playlist data
// Cached search results
```

---

## 4. API Security

### 4.1 CORS Configuration

```typescript
// src/services/api.ts

const ALLOWED_ORIGINS = [
  'https://api.deezer.com',
];

const fetchWithCORS = async (url: string): Promise<Response> => {
  const parsedUrl = new URL(url);
  
  // Validate origin
  if (!ALLOWED_ORIGINS.some(origin => url.startsWith(origin))) {
    throw new Error('Invalid API origin');
  }
  
  return fetch(url, {
    method: 'GET',
    headers: {
      'Accept': 'application/json',
    },
  });
};
```

### 4.2 Rate Limiting (Client-Side)

```typescript
// src/utils/rateLimiter.ts

class RateLimiter {
  private timestamps: number[] = [];
  private limit: number;
  private window: number;

  constructor(limit: number, windowMs: number) {
    this.limit = limit;
    this.window = windowMs;
  }

  canMakeRequest(): boolean {
    const now = Date.now();
    this.timestamps = this.timestamps.filter(t => now - t < this.window);
    return this.timestamps.length < this.limit;
  }

  recordRequest(): void {
    this.timestamps.push(Date.now());
  }
}

// 100 requests per minute
export const apiLimiter = new RateLimiter(100, 60000);

// Usage
const fetchData = async (url: string) => {
  if (!apiLimiter.canMakeRequest()) {
    throw new Error('Rate limit exceeded. Please try again later.');
  }
  apiLimiter.recordRequest();
  return fetch(url);
};
```

### 4.3 Error Handling

```typescript
// Don't expose internal errors to users
const handleApiError = (error: unknown): string => {
  console.error('API Error:', error); // Log for debugging
  
  // Return generic message to user
  if (error instanceof Error) {
    if (error.message.includes('network')) {
      return 'Network error. Please check your connection.';
    }
    if (error.message.includes('rate limit')) {
      return 'Too many requests. Please wait a moment.';
    }
  }
  
  return 'Something went wrong. Please try again.';
};
```

---

## 5. XSS Prevention

### 5.1 React's Built-in Protection

```tsx
// ✅ Safe - React escapes by default
const TrackTitle = ({ title }: { title: string }) => {
  return <h3>{title}</h3>; // Automatically escaped
};

// ❌ Dangerous - Avoid dangerouslySetInnerHTML
const UnsafeComponent = ({ html }: { html: string }) => {
  return <div dangerouslySetInnerHTML={{ __html: html }} />; // XSS risk!
};
```

### 5.2 Safe Dynamic Content

```tsx
// src/components/SafeText.tsx

interface SafeTextProps {
  text: string;
  maxLength?: number;
}

export const SafeText: React.FC<SafeTextProps> = ({ text, maxLength = 100 }) => {
  // Truncate and display safely
  const displayText = text.length > maxLength 
    ? `${text.slice(0, maxLength)}...` 
    : text;
  
  return <span>{displayText}</span>; // React auto-escapes
};
```

### 5.3 URL Validation

```typescript
// src/utils/urlValidator.ts

const ALLOWED_PROTOCOLS = ['https:', 'http:'];
const ALLOWED_DOMAINS = [
  'api.deezer.com',
  'cdns-preview-d.dzcdn.net',
  'e-cdns-images.dzcdn.net',
];

export const isValidImageUrl = (url: string): boolean => {
  try {
    const parsed = new URL(url);
    return (
      ALLOWED_PROTOCOLS.includes(parsed.protocol) &&
      ALLOWED_DOMAINS.some(domain => parsed.hostname.endsWith(domain))
    );
  } catch {
    return false;
  }
};

export const isValidAudioUrl = (url: string): boolean => {
  try {
    const parsed = new URL(url);
    return (
      parsed.protocol === 'https:' &&
      parsed.hostname.endsWith('.dzcdn.net')
    );
  } catch {
    return false;
  }
};
```

---

## 6. Dependency Security

### 6.1 Audit Commands

```bash
# Check for vulnerabilities
npm audit

# Fix automatically where possible
npm audit fix

# Generate detailed report
npm audit --json > audit-report.json
```

### 6.2 Dependabot Configuration

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "security"
```

### 6.3 Lock File Integrity

```bash
# Verify lock file integrity
npm ci # Uses package-lock.json exactly

# Never use in CI/CD:
# npm install # Can modify lock file
```

---

## 7. Security Checklist

### Development

- [ ] Input validation on all user inputs
- [ ] Output encoding for display
- [ ] No hardcoded secrets in code
- [ ] Dependencies regularly updated
- [ ] Code reviewed for security issues

### Build

- [ ] Production build without source maps (optional)
- [ ] Environment variables not in bundle
- [ ] Minified and obfuscated code
- [ ] No debug code in production

### Deployment

- [ ] HTTPS enabled and enforced
- [ ] Security headers configured
- [ ] CSP policy implemented
- [ ] CORS properly configured
- [ ] Rate limiting in place

### Monitoring

- [ ] Error tracking enabled
- [ ] Logging without sensitive data
- [ ] Alerts for suspicious activity
- [ ] Regular security audits

---

## 8. Incident Response

### 8.1 Security Incident Procedure

1. **Identify**: Detect and confirm the security issue
2. **Contain**: Limit the impact immediately
3. **Eradicate**: Remove the vulnerability
4. **Recover**: Restore normal operations
5. **Learn**: Document and improve

### 8.2 Contact Information

For security concerns, contact:
- **Email**: security@jetstream.example.com
- **Response Time**: Within 24 hours

### 8.3 Vulnerability Disclosure

We follow responsible disclosure:
1. Report privately to security team
2. Allow 90 days for fix
3. Coordinate public disclosure
