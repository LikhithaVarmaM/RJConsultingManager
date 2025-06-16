# RJConsultingManager

RJConsultingManager is an internal iOS application built for consulting firms to manage clients, consultants, projects, and associated tasks and documents. The app provides a centralized interface for efficient resource management, collaboration, and project tracking.

---

## 📱 Features

### 🔐 Authentication
- Secure login and sign-up using Firebase Authentication
- Role-based access for admin and consultant users

### 🧑‍💼 Consultant Management
- Add, edit, view, and delete consultants
- Assign consultants to projects
- View consultant skills and contact information

### 👥 Client Management
- Add, edit, view, and delete clients
- Upload and manage client-related documents
- View associated projects

### 📂 Project Management
- Create projects with deadlines
- Assign clients and consultants to projects
- Upload and preview project-specific documents

### ✅ Task Management
- Add and assign tasks to consultants
- Track task status: Completed, Incomplete, Overdue
- View all tasks related to a project

### 📊 Dashboard
- Visual summary of clients, projects, tasks
- Role-based visibility: admins see everything; consultants see their own data

### 📁 Document Management
- Upload PDFs, Word files to Firebase Storage
- Preview documents using QuickLook
- Organized by project or client

### 🧾 Profile Management
- View and edit user profile
- Logout and account deletion options

---

## 🛠️ Tech Stack

- **Frontend:** SwiftUI (iOS 16+)
- **Backend:** Firebase Firestore, Firebase Auth, Firebase Storage
- **Architecture:** MVVM
- **Other Tools:** QuickLook, FileImporter, UUIDs for file names

---

## 📦 Folder Structure (Views)
RJConsultingManager/
├── Views/
│   ├── Auth/
│   ├── Dashboard/
│   ├── Consultant/
│   ├── Client/
│   ├── Project/
│   ├── Tasks/
│   ├── Profile/
│   └── Shared Components/
├── Models/
├── ViewModels/
├── Assets/
├── Persistence/
└── App Entry/

---

## 🧪 Installation & Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/LikhithaVarmaM/RJConsultingManager.git

2.	Open the .xcodeproj in Xcode
   
3. Install Firebase:
	•	Ensure GoogleService-Info.plist is added to your project
	•	Run on iOS 16+

4. Build & Run

---

🔒 Security
	•	Firebase Authentication for secure access
	•	Role-based access logic
	•	Firebase Security Rules (suggested in production)

---

🚀 Future Enhancements
	•	Push Notifications for deadlines and updates
	•	Role-based admin dashboard analytics
	•	Offline access with caching
	•	Chat/comments per project
	•	Dark mode support

---

👩‍💻 Developed By
	•	Likhitha Mandapati
	•	Nikhil Varma Sagiraju

---

📄 License

This project is licensed for internal use only. Contact the authors for reuse or contributions.
