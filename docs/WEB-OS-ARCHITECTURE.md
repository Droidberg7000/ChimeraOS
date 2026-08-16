# Web-Based OS Architecture (ChimeraOS)

## Overview

ChimeraOS is a **full web-based OS simulation and interactive launcher shell** that provides a BB10 Cascades-style user experience in any modern browser, backed by a real Node.js/Express server running in a Linux container (e.g., Cloud Run).

This is **not** a bare-metal firmware replacement for physical BlackBerry hardware. Instead, it acts as a **sovereign web-based operating system hub** accessible from any browser or desktop.

## Architecture Components

### 1. Frontend (Vite/TypeScript)

- **UI Paradigm:** BB10 Cascades-style launcher shell
  - Active frame windowing
  - Swipe gesture navigation
  - Status bar notifications
  - App drawer grids
  - Customizable themes
- **Technology Stack:**
  - Vite + TypeScript
  - WebSocket client for real-time sync
  - Local state management for UI responsiveness
- **Key Features:**
  - Real-time active frames
  - Gesture-based navigation
  - Notification system
  - App launcher with grid view
  - Theme customization

### 2. Backend (Node.js/Express)

- **Runtime:** Node.js in Linux container (Cloud Run or similar)
- **Core Services:**
  - **Terminal Execution:** Sandboxed command execution for real terminal operations
  - **Filesystem API:** File operations for projects, configs, artifacts
  - **WebSocket Server:** Real-time bidirectional communication with frontend
  - **API Proxy:** Secure proxy for AI/API requests (OpenAI, OpenRouter, Telegram, etc.)
  - **Git Manager:** Repository sync operations (clone, pull, commit, push)
- **Security Model:**
  - Sandboxed execution environment
  - API key management via environment variables
  - Rate limiting and access controls

### 3. Deployment Model

- **Primary Host:** Google Cloud Run (Linux container)
- **Alternative Hosts:** Any Node.js-compatible container platform
- **Access:** Any modern web browser or desktop client
- **Persistence:**
  - Cloud storage for filesystem operations
  - Git repositories for code persistence
  - Environment variables for configuration

## Relationship to Other Components

### Q20 Native Launcher (BB10)

- **Purpose:** Native companion shell for actual BlackBerry Classic (Q20) hardware
- **Technology:** WebWorks/Cordova `.bar` application
- **Relationship:**
  - Can embed or link to the web-based OS
  - Provides device-specific optimizations for Q20
  - Shares launcher UI paradigms and package vault concepts
- **Documentation:** See `docs/Q20-FULL-LAUNCHER-SPEC.md`

### JavaBoyChimera

- **Purpose:** Game Boy Color/Java emulator sub-project
- **Technology:** Gradle-based Android app and/or Java ME
- **Relationship:**
  - Appears as an app tile in web-based OS launcher
  - Referenced in Q20 launcher package vault
  - Operates as independent emulator project
- **Repository:** `agentb113-jpg/JavaBoyChimera`

### ChimeraCarPal and Other Sub-projects

- **Purpose:** Additional Chimera-branded applications
- **Relationship:**
  - Referenced in web-based OS and Q20 launcher
  - Maintain independent development tracks
  - Can be integrated as launcher tiles or services

## Security Considerations

- **Never commit real API keys or secrets**
- Use environment variables for all sensitive configuration
- Implement proper authentication for API proxy endpoints
- Sandboxed terminal execution with resource limits
- Regular security audits and key rotation

## File Structure

```
web-os/
  src/              # Vite frontend application
  server.ts         # Express backend server
  public/           # Static assets
  package.json      # Node.js dependencies
  tsconfig.json     # TypeScript configuration
  vite.config.ts    # Vite build configuration
  firebase-*.json   # Firebase configuration (if used)
  MIGRATION_BLUEPRINT.md  # Migration documentation
```

## Development Workflow

1. **Frontend Development:**
   - Vite dev server for hot reload
   - WebSocket client for real-time testing
   - Theme and gesture testing in browser

2. **Backend Development:**
   - Local Node.js server for testing
   - Sandboxed terminal for command testing
   - API proxy endpoint validation

3. **Deployment:**
   - Container build and push
   - Cloud Run deployment
   - Environment variable configuration

## Future Enhancements

- Enhanced gesture recognition
- Additional theme options
- Extended API proxy capabilities
- Improved terminal sandboxing
- Multi-user support with authentication
