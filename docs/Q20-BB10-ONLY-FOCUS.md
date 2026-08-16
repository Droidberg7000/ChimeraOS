# ChimeraOS Q20 BB10-Only Focus

## Critical Clarification

**This project is focused EXCLUSIVELY on the BlackBerry Classic Q20 running BB10 OS.**

While the web-based OS simulation serves as a development and testing platform, the **primary and only production target** is the **BlackBerry Classic Q20 (BB10 10.3.x)**.

## What This Project IS

✅ **BB10 Native Launcher** for Q20 Classic
- WebWorks/Cordova `.bar` application
- Full-screen launcher UI replacing stock home experience
- BB10 Cascades-style interface
- Package vault with JavaBoyChimera integration
- Telemetry, diagnostics, and AI companion features

✅ **Web-Based Development Hub** (Supporting Role)
- Development and testing environment
- BB10 Cascades UI simulation in browser
- Cloud Run deployment for accessibility
- NOT the production target

✅ **Q20-Specific Optimizations**
- 720×²720 display optimization
- Physical keyboard integration
- Trackpad gesture support
- BB10 notification LED control (red/blue strobing)
- BB10-specific APIs and services

## What This Project IS NOT

❌ **NOT Android** - No APK, no Android runtime (except JavaBoyChimera sub-project)
❌ **NOT iOS** - No iPhone/iPad support
❌ **NOT Desktop** - No Windows/Mac/Linux native apps
❌ **NOT Generic BB10** - Q20 Classic ONLY (not Z10, Z30, Q10, Passport, etc.)
❌ **NOT Bare-Metal OS** - Does NOT replace BB10 kernel/bootloader

## The Three Q20 Paths (Refocused)

### Path 1: Full Launcher (PRIMARY FOCUS) ✅

**Target:** Stock BB10 10.3.x on Q20 Classic

**What It Is:**
- WebWorks/Cordova `.bar` application
- Full-screen launcher that users live in
- Replaces stock home screen experience
- Uses official BB10 APIs only
- No bootloader exploits required

**Status:** ✅ Already implemented in `q20-launcher/`

**Next Steps:**
1. Complete UI polish for Q20
2. Integrate JavaBoyChimera as launcher tile
3. Add AngieAI companion features
4. Optimize for keyboard/trackpad
5. Sign and deploy to real Q20 device

### Path 2: BB10-Derivative OS (SECONDARY/EXPERIMENTAL) 🔄

**Target:** Modified BB10 image for Q20

**What It Is:**
- Custom BB10 autoloader with ChimeraOS components pre-installed
- Keeps QNX kernel and BB10 drivers intact
- Modifies user-space to make ChimeraOS dominant
- Requires careful testing and recovery planning

**Status:** 🔄 Research phase

**Requirements:**
- Exact Q20 variant matching (SQC100-1/2/3)
- Stock autoloader backup and recovery
- Device-specific testing

**NOT a priority** until Path 1 is complete and polished

### Path 3: Standalone OS (RESEARCH ONLY) 🔬

**Target:** Theoretical bare-metal Linux on Q20

**What It Is:**
- Long-term research project only
- Would require bootloader exploit
- Custom kernel with MSM8960 support
- NOT a production goal

**Status:** 🔬 Research only, no timeline

**Reality Check:**
- Q20 lacks public bootloader exploit
- Driver availability is limited
- **This is NOT the focus of the project**

## Web-Based OS Role Clarification

The web-based OS simulation (`web-os/`) serves as:

1. **Development Environment**
   - Rapid UI prototyping
   - BB10 Cascades-style design testing
   - Gesture and animation testing

2. **Testing Platform**
   - Test launcher concepts before Q20 deployment
   - Debug UI/UX issues in browser
   - Iterate quickly without device flashing

3. **Demonstration Tool**
   - Show ChimeraOS concepts to others
   - Live demo at `chimeraos.ai.studio` (when deployed)
   - Documentation and screenshots

**NOT a production target** - The web OS is a means to an end, not the end goal.

## Q20 Hardware Specifications

### BlackBerry Classic Q20 (SQC100)

- **OS:** BlackBerry 10.3.x (QNX-based)
- **SoC:** Qualcomm Snapdragon S4 Plus (MSM8960)
- **Display:** 3.5" 720×²720 (1:1 aspect ratio)
- **Input:** Physical QWERTY keyboard, trackpad
- **Memory:** 2GB RAM, 16GB storage
- **Cameras:** 8MP rear, 2MP front
- **Battery:** 2515 mAh removable
- **Notification LED:** RGB LED (customizable colors)

### Q20-Specific Features to Implement

1. **Notification LED Control**
   - Red/blue strobing (police car effect)
   - Custom colors per notification type
   - Breathing light effects
   - Integration with launcher notifications

2. **Keyboard Integration**
   - Hardware keyboard shortcuts
   - Key remapping options
   - Keyboard-driven navigation
   - Terminal-style input support

3. **Trackpad Gestures**
   - Swipe up/down for scrolling
   - Swipe left/right for navigation
   - Long-press for context menus
   - Haptic feedback integration

4. **BB10 Cascades UI**
   - Native BB10 look and feel
   - Active frames for multitasking
   - Hub-style notifications
   - Quick settings panel

## Deployment Priority

### Immediate (Q4 2026)

1. ✅ Complete `q20-launcher/` implementation
2. ✅ Test on real Q20 device
3. ✅ Sign and deploy `.bar` package
4. ✅ Integrate JavaBoyChimera
5. ✅ Add AngieAI features

### Near-Term (Q1 2027)

1. 🔄 Enhance notification LED control
2. 🔄 Optimize keyboard shortcuts
3. 🔄 Improve trackpad gestures
4. 🔄 Add more BB10-native features

### Long-Term (Q2+ 2027)

1. 📋 BB10-Derivative OS research (optional)
2. 📋 Advanced Q20 hardware integration
3. 📋 Community features and sharing

## Success Criteria

### Q20 Launcher Success

- ✅ Runs smoothly on Q20 Classic
- ✅ Replaces stock home as primary UI
- ✅ JavaBoyChimera accessible from launcher
- ✅ Notification LED works with custom colors
- ✅ Keyboard and trackpad fully integrated
- ✅ Signed `.bar` package for easy deployment

### Web OS Success (Supporting Role)

- ✅ Accurate BB10 Cascades simulation
- ✅ Useful for development and testing
- ✅ Live demo available online
- ✅ Helps iterate UI/UX quickly

## Documentation Focus

All documentation should prioritize Q20 BB10:

1. **`Q20-FULL-LAUNCHER-SPEC.md`** - Primary implementation guide
2. **`Q20-THREE-PATHS-INDEX.md`** - Path comparison (emphasize Path 1)
3. **`Q20-BB10-ONLY-FOCUS.md`** - This document (scope clarification)
4. **`Q20-RECOVERY-AND-ROLLBACK.md`** - Safety procedures
5. **`WEB-OS-ARCHITECTURE.md`** - Web OS as dev tool (clearly labeled)

## Community Messaging

When discussing ChimeraOS:

- **Always clarify:** "BB10 launcher for Q20 Classic"
- **Avoid confusion:** Not Android, not iOS, not desktop
- **Emphasize:** Q20-specific optimizations
- **Web OS role:** Development tool, not production target

## Conclusion

ChimeraOS is **first and foremost a BB10 launcher for the BlackBerry Classic Q20**. The web-based OS, Android/iOS/desktop transition strategies, and other platforms are either:

1. **Development tools** (web OS)
2. **Future possibilities** (not current focus)
3. **Out of scope** (Android, iOS, desktop)

**Stay focused on Q20 BB10.** That's where the project delivers real value.
