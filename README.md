# Needo - Mobile Marketplace for On-Site Services

Needo is a cross-platform mobile marketplace application designed to seamlessly connect customers with local service providers. Developed as part of a BEng Engineering Thesis, this project demonstrates the implementation of modern cloud-native architectures and real-time distributed systems.

## 🏗 System Architecture

The application strictly adheres to **Clean Architecture** principles, ensuring a robust separation of concerns:
- **Presentation Layer:** Flutter UI components integrated with the **BLoC/Cubit** state management pattern.
- **Domain Layer:** Pure Dart business logic containing Use Cases and Entity models.
- **Data Layer:** Repository implementations and remote data sources handling Firebase APIs.

## 🚀 Tech Stack

- **Frontend:** Flutter & Dart
- **Backend (BaaS):** Google Firebase (Serverless)
- **Database:** Cloud Firestore (NoSQL Document Database)
- **Authentication:** Firebase Auth (Email/Password)
- **State Management:** `flutter_bloc`
- **Functional Programming:** `fpdart`

## ✨ Core Features

- **Role-Based Access Control (RBAC):** Distinct interfaces and capabilities for 'Customers' and 'Service Providers'.
- **Real-Time Bidding System:** Providers can discover open requests and submit competitive bids.
- **Atomic Transactions:** Secure bid acceptance utilizing Firestore `WriteBatch`.
- **Real-Time Chat Engine:** Built-in messaging system using Firestore `snapshots()`.
- **Lifecycle Management:** Complete state machine tracking for service requests (Open -> In Progress -> Completed).

## 📚 Technical Documentation

For an in-depth understanding of the system's design and development lifecycle, please refer to the following documents included in this repository:

1. **[System Architecture & Technical Design (Start.md)](Start.md):** Detailed problem statement, target audience, advanced database schema, MVP boundaries, and security architecture.
2. **[Thesis Development Log (THESIS_DEV_LOG.md)](THESIS_DEV_LOG.md):** A phase-by-phase engineering diary explaining the academic justification behind every technical decision, including Clean Architecture adoption and Serverless infrastructure.
