# TaskWise: Intelligent Task & Habit Manager 🚀

TaskWise is a cross-platform productivity application developed with **Flutter** that goes beyond traditional to-do lists. It utilizes a deterministic rule-based engine to prioritize tasks and a temporal logic system to manage long-term habit formation through streaks.

## 🧠 The Intelligence Layer

The core of TaskWise is an **Urgency Scoring Algorithm** that mitigates decision fatigue by mathematically calculating the "next best task."

### 1. Priority Scoring Engine
Every task is assigned an Urgency Score ($S$) calculated in real-time:
$$S = (Priority \times 10) + W_t + \delta_{daily}$$
- **Dynamic Weighting ($W_t$):** Tasks automatically "climb" the list as deadlines approach.
- **Overdue Handling:** Tasks that pass their deadline are assigned maximum weight ($100$) and highlighted to signal critical status.

### 2. Temporal Habit Maintenance
Unlike static trackers, TaskWise implements a state-transition model for habits:
- **Consistency Tracking:** Automatically manages daily **streaks** based on a 24-hour cycle.
- **Simulation Mode:** Includes a high-frequency simulation toggle (1-minute cycles) for rapid feature validation and testing.

## 🛠️ Technical Stack

- **Framework:** Flutter (Material 3 Design)
- **State Management:** [Provider](https://pub.dev/packages/provider) — Implements the Observer pattern for a reactive, single-source-of-truth UI.
- **Database:** [Hive NoSQL](https://pub.dev/packages/hive) — A lightning-fast, key-value storage engine using binary serialization for 100% offline persistence.
- **Visualizations:** [FL Chart](https://pub.dev/packages/fl_chart) — Data-driven analytics showing user efficiency and streak history.

## 📊 Key Features

- **Smart Dashboard:** Real-time productivity metrics including Efficiency Ratios and the "Streak Champion" metric.
- **Intelligent Alerts:** Context-aware notifications that trigger only when a newly added task disrupts the current priority stack.
- **Offline-First:** No external server dependency; all data is serialized locally for maximum privacy and speed.
- **Modern UI:** A "Midnight" palette designed for high focus and reduced eye strain during long academic sessions.

## 🚀 Installation & Setup
1. **Clone the repo:**
   ```bash
   git clone [https://github.com/Lakshmihollat/TaskWise.git](https://github.com/Lakshmihollat/TaskWise.git)

2. **Install dependencies:**
   ```bash
   flutter pub get
3. **Run the app:**
   ```bash
   flutter pub get


1. **Clone the repo:**
   ```bash
   git clone [https://github.com/Lakshmihollat/TaskWise.git](https://github.com/Lakshmihollat/TaskWise.git)
