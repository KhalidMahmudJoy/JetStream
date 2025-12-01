# Glossary & Terminology

## A

**API (Application Programming Interface)**
A set of protocols and tools for building software applications. In JetStream, we use the Deezer API for music data.

**AudioContext**
A Web Audio API interface representing an audio processing graph. Used for equalizer, volume control, and audio visualization.

**AnalyserNode**
A Web Audio API node that provides real-time frequency and time-domain analysis. Used for the audio visualizer.

---

## B

**BiquadFilterNode**
A Web Audio API node that represents a second-order filter. Used for the 10-band equalizer.

**Build**
The process of compiling source code into production-ready static files.

**Bundle**
A single JavaScript file containing all application code and dependencies.

---

## C

**Cache**
Temporary storage of data for faster access. JetStream caches API responses to improve performance.

**Component**
A reusable piece of UI in React. Examples: GlassPlayer, QueuePanel, SearchPage.

**Context (React)**
A way to pass data through the component tree without props. Used for PlayerContext.

**CORS (Cross-Origin Resource Sharing)**
A security feature that restricts web page requests to different domains. JetStream uses a CORS proxy for Deezer API.

**CSP (Content Security Policy)**
A security standard to prevent XSS attacks by specifying allowed content sources.

---

## D

**Deezer**
A music streaming service. JetStream uses Deezer's API for music metadata and preview streams.

**Dependency**
External code library used by the application. Listed in package.json.

**DOM (Document Object Model)**
The programming interface for HTML documents. React manipulates the DOM to update the UI.

---

## E

**Equalizer**
An audio processor that adjusts the volume of different frequency ranges. JetStream has a 10-band equalizer.

**ESM (ECMAScript Modules)**
The official standard format for packaging JavaScript code for reuse.

---

## F

**Framer Motion**
A React animation library. Used for page transitions, drag-and-drop, and UI animations.

**Functional Component**
A React component defined as a JavaScript function. All JetStream components are functional.

---

## G

**GainNode**
A Web Audio API node that controls volume. Used for master volume control.

**Glass Morphism**
A UI design style with transparent, blurred backgrounds. Used in JetStream's player.

---

## H

**Hook**
A React function that lets you use state and lifecycle features. Examples: useState, useEffect, useContext.

**Hot Module Replacement (HMR)**
A development feature that updates code in the browser without full page reload.

---

## I

**Interface (TypeScript)**
A TypeScript construct defining the shape of an object. Example: `interface Track { id: string; title: string; }`

---

## J

**JSX**
A syntax extension for JavaScript that looks like HTML. Used in React components.

---

## L

**LocalStorage**
Browser storage API for persisting data between sessions. JetStream stores playlists, liked songs, and settings.

**Lucide**
An icon library. JetStream uses lucide-react for UI icons.

---

## M

**Minification**
The process of removing unnecessary characters from code to reduce file size.

**Module**
A JavaScript file that exports code for use in other files.

---

## N

**Node.js**
A JavaScript runtime used for development tools and build processes.

**npm (Node Package Manager)**
A package manager for JavaScript. Used to install dependencies.

---

## P

**Preview URL**
A 30-second audio clip URL provided by Deezer API for track previews.

**Props**
Short for properties. Data passed from parent to child components in React.

**PWA (Progressive Web App)**
A web application that provides native app-like features.

---

## Q

**Queue**
An ordered list of tracks to be played. Users can add, remove, and reorder tracks.

---

## R

**React**
A JavaScript library for building user interfaces. JetStream's frontend framework.

**React Router**
A routing library for React. Handles navigation between pages.

**Reorder (Framer Motion)**
Components for creating drag-to-reorder lists. Used in QueuePanel.

---

## S

**SPA (Single Page Application)**
A web application that loads a single HTML page and dynamically updates content.

**State**
Data that can change over time and triggers UI updates when modified.

**Shuffle**
Random playback order mode for the queue.

---

## T

**Track**
A single music piece with metadata (title, artist, album, duration, audio URL).

**TypeScript**
A typed superset of JavaScript. JetStream is written in TypeScript for type safety.

---

## U

**UUID (Universally Unique Identifier)**
A unique identifier. Used for playlist IDs.

**useCallback**
A React hook that memoizes callback functions.

**useEffect**
A React hook for side effects (API calls, subscriptions).

**useMemo**
A React hook that memoizes computed values.

**useState**
A React hook for component state management.

---

## V

**Vite**
A fast build tool for modern web development. JetStream's bundler.

**Volume Normalization**
Automatically adjusting volume levels for consistent loudness across tracks.

---

## W

**Web Audio API**
A browser API for processing and synthesizing audio. Used for equalizer and visualizer.

**Webpack**
A module bundler (alternative to Vite).

---

## X

**XSS (Cross-Site Scripting)**
A security vulnerability where malicious scripts are injected into web pages.

---

## Abbreviations

| Abbr | Full Form |
|------|-----------|
| API | Application Programming Interface |
| CSS | Cascading Style Sheets |
| DOM | Document Object Model |
| HMR | Hot Module Replacement |
| HTML | HyperText Markup Language |
| HTTP | HyperText Transfer Protocol |
| HTTPS | HTTP Secure |
| JSON | JavaScript Object Notation |
| JSX | JavaScript XML |
| PWA | Progressive Web App |
| SPA | Single Page Application |
| SSR | Server-Side Rendering |
| UI | User Interface |
| URL | Uniform Resource Locator |
| UUID | Universally Unique Identifier |
| XSS | Cross-Site Scripting |
