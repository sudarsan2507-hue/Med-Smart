# 🩺 MedSmart - Holistic Remote Health Monitoring

MedSmart is a comprehensive healthcare platform built with **Flutter** and **Firebase**, designed to bridge the gap between Elders, Caregivers, and Doctors. It provides real-time health monitoring, medication management, and clinical control in one unified ecosystem.

---

## 🚀 Key Features

### 👴 For Elders (Patients)
- **Vitals Logger:** Easily record Heart Rate, Blood Pressure, and Oxygen Levels.
- **Health Dashboard:** Visual summary of latest health metrics and upcoming medications.
- **Medication Wallet:** Track daily doses and view instructions from doctors.
- **Smart Profile:** Store vital info like blood group and chronic medical conditions.

### 👨‍👩‍👧 For Caregivers (Family)
- **Real-time Monitoring:** View live updates of an elder's vitals from anywhere.
- **Multi-Elder Management:** Link and monitor multiple family members.
- **Medication Audit:** See which medications have been prescribed and their schedules.

### 🩺 For Doctors (Professionals)
- **Clinical Portal:** Manage a dedicated list of patients.
- **Digital Prescriptions:** Prescribe medications directly within the app (marked as clinically verified).
- **Metric History:** Analyze vital trends to make better-informed clinical decisions.

---

## 🛠 Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Authentication, Cloud Firestore)
- **Database:** Real-time NoSQL (Firestore) with optimized composite indexing.

---

## 📸 UI Screenshots
*(Add your screenshots here to showcase the premium UI design)*

---

## 🏁 Getting Started

### Prerequisites
- Flutter SDK (3.x or higher)
- Firebase Account
- Google Services JSON (already configured for this project)

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/sudarsan2507-hue/Med-Smart.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the app:**
   ```bash
   flutter run -d edge # or your preferred device
   ```

---

## ⚙️ Backend Configuration
This project uses **Firestore Composite Indexes** for high-performance health data sorting. Ensure the following index is enabled in your Firebase Console:
- Collection: `vitals`
- Fields: `elderId` (Ascending), `timestamp` (Descending)

---

## 📄 License
Project developed for modern healthcare accessibility.
