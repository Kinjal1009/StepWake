# StepWake ⏰🚶‍♂️ - A Flutter Vibe Coding Project

> **The alarm clock that makes you walk to wake up**

StepWake is a behavioral-intervention alarm app designed for ambitious individuals who struggle with chronic oversleeping. Unlike traditional alarms that can be snoozed endlessly, StepWake requires users to physically walk for a defined duration before the alarm stops ringing—turning wake-up willpower into automated action.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![AI-Powered](https://img.shields.io/badge/Built%20with-AI%20Vibe%20Coding-purple)](https://aistudio.google.com/)

---
## 🎯 Problem Statement

**Target User:** Ambitious but sleep-loving individuals who:
- Set 10+ alarms in a row (15-minute intervals)
- Repeatedly hit snooze without waking up
- Have goals but struggle with early mornings
- Experience the "snooze-loop" cycle

**The Challenge:** Traditional alarms fail because they don't address the behavioral pattern of semi-conscious alarm dismissal.

---

## 💡 Solution

StepWake uses **motion sensor technology** to enforce a simple rule:

> **Walk for 5+ minutes = Alarm stops ringing**

### How It Works

1. **Set Your Alarm** - Configure wake-up time and walking duration
2. **Alarm Rings** - Loud, persistent alarm at scheduled time
3. **Get Moving** - Phone detects motion via accelerometer/pedometer
4. **Track Progress** - Real-time walking duration counter
5. **Earn Silence** - Alarm stops only after completing required walk time

### Key Features

- 🚶 **Motion-Activated Dismissal** - No walking, no silence
- ⏱️ **Customizable Walk Duration** - Set 1-15 minute requirements
- 📊 **Progress Tracking** - Visual feedback on walking time completed
- 🔒 **Anti-Cheat Mechanisms** - Prevents fake motion or device manipulation
- 📱 **Hybrid Flutter App** - Works on iOS and Android
- 🎨 **Clean, Intuitive UI** - Easy to configure, impossible to bypass

---

## 🚀 Tech Stack

### Development Approach: AI-Powered "Vibe Coding"

This project demonstrates an **end-to-end AI-native development workflow**:

```
User Problem → Google AI Studio (Design) → Gemini (Code Generation) → Flutter Production App
```

### Technologies

- **Framework:** Flutter (Hybrid Mobile Development)
- **Sensors:** Accelerometer, Pedometer APIs
- **AI Tools:** 
  - Google AI Studio (Prototyping & Design)
  - Google Gemini (Code Generation via Prompt Engineering)
- **State Management:** [Your choice - Provider/Riverpod/Bloc]
- **Platform:** iOS & Android

### AI Development Methodology

**"Vibe Coding"** - Using conversational AI to transform natural language requirements into production-ready code:

1. **Problem Discovery** - User research and pain point analysis
2. **AI-Assisted Design** - Google AI Studio for UI/UX prototyping
3. **Prompt-Driven Development** - Gemini for code generation
4. **Iterative Refinement** - Conversational debugging and feature additions
5. **Production Deployment** - Flutter build and app store publishing

---

## 📦 Installation

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / Xcode
- Device with motion sensors

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/stepwake.git

# Navigate to project directory
cd stepwake

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🎮 Usage

### Basic Setup

1. Open StepWake app
2. Grant motion sensor permissions
3. Set your wake-up time
4. Configure walking duration (default: 5 minutes)
5. Enable the alarm

### Advanced Settings

- **Walking Sensitivity** - Adjust motion detection threshold
- **Alarm Sound** - Choose from multiple wake-up tones
- **Vibration Patterns** - Customize haptic feedback
- **Snooze Options** - Disable snooze or set strict limits

## 🤖 AI Development Insights

### Prompt Engineering Examples

**Design Phase:**
```
"Design a mobile alarm app UI where users must walk to dismiss the alarm. 
Include: alarm time selector, walking duration slider, progress indicator, 
and motion detection visualization. Style: minimal, calming colors."
```

**Code Generation:**
```
"Create a Flutter service that uses the sensors_plus package to track 
step count and walking duration. Integrate with flutter_local_notifications 
to trigger alarms and only dismiss when walking threshold is met."
```

### Lessons Learned

- **Iterative Prompting:** Breaking complex features into smaller, testable components
- **Context Preservation:** Maintaining conversation history for consistent code generation
- **AI Limitations:** Manual integration required for sensor calibration and edge cases
- **Time Savings:** ~60% faster development compared to traditional coding

---

## 🛣️ Roadmap

- [ ] **v1.0** - Core alarm + motion detection (Current)
- [ ] **v1.1** - Sleep cycle tracking integration
- [ ] **v1.2** - Smart wake windows (wake within optimal sleep phase)
- [ ] **v2.0** - Gamification (streaks, achievements, leaderboards)
- [ ] **v2.1** - Social accountability features
- [ ] **v3.0** - ML-powered wake-up pattern analysis

---

## 🤝 Contributing

Contributions are welcome! This project serves as a case study in AI-assisted development.

### AI-Assisted Contributions

If you're using AI tools (Claude, Gemini, Google AI Studio, AntiGravity) to contribute:
- Document your prompts in PR descriptions
- Share what worked/didn't work
- Help build a knowledge base for AI-native development

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google AI Studio & Gemini** - For enabling rapid prototyping through conversational AI
- **Flutter Team** - For the excellent cross-platform framework
- **Sensors Plus Package** - For reliable motion detection APIs
- **The Chronic Oversleepers** - For inspiring this solution

---

## 📊 Project Stats

- **Development Time:** [3 Days] (with AI assistance)
- **Lines of Code:** [~3,000]
- **AI-Generated Code:** [~85%]
- **Manual Code:** [~15%]
- **Prompts Used:** [~25 total]

---

## 🌟 Star History

If this project helps you wake up on time (or inspires your AI-PM journey), consider starring it! ⭐

---

**Built with ❤️ and AI-powered vibe coding**

![WhatsApp Image 2026-02-15 at 10 57 28 PM](https://github.com/user-attachments/assets/9f4d7009-3e58-48a7-be96-5b35ea60b736)
![WhatsApp Image 2026-02-15 at 10 57 27 PM](https://github.com/user-attachments/assets/f9f17ebc-582b-4bfb-b3c6-f6528a3fed55)
![WhatsApp Image 2026-02-15 at 11 01 35 PM](https://github.com/user-attachments/assets/2c4cefe2-3d19-4c25-bce5-c60c41007071)
