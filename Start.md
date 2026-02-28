# Needo: Service Marketplace Mobile Application Technical Design and Architecture Document

## 1. Project Definition and Purpose
**Needo** is a cross-platform mobile application developed using **Flutter** that functions as a location-based, real-time digital marketplace connecting service seekers with professional service providers (e.g., home repairs, cleaning, transportation).

The primary objective of this project is to address the inefficiencies, lack of price transparency, and accessibility issues inherent in the traditional service sector by establishing a digital ecosystem. By leveraging **Google Cloud Platform (GCP)** and **Firebase** infrastructure within a **serverless architecture**, the project aims to deliver a highly scalable, secure, and high-performance solution.

## 2. Problem Statement and Solution Approach
### 2.1. Problem Statement
In the current service industry, consumers face significant time costs in finding qualified professionals and encounter trust issues due to a lack of standardization in pricing and service quality. Conversely, service providers struggle with marketing costs and the inability to optimize their workforce capacity due to fluctuating demand.

### 2.2. Solution Approach
Needo adopts an "On-Demand Service" model to provide the following technical solutions:
* **Algorithmic Matching:** Automated filtering of service providers based on request parameters (location, time, budget) using geospatial queries.
* **Reputation Management System:** A trust score mechanism based on weighted user reviews and ratings.
* **Serverless Infrastructure:** A cloud-native architecture that minimizes operational overhead and dynamically auto-scales in response to traffic spikes.

## 3. Target Audience Analysis
* **Service Requesters (Customers):** Individuals seeking rapid, reliable, and price-competitive services, possessing basic mobile technology literacy.
* **Service Providers (Professionals):** Freelancers, SMEs, and gig economy workers aiming to digitize their operations and increase business volume.

## 4. System Architecture

The system is architected not as a monolithic structure, but as a modern, scalable **Serverless Microservices** architecture.

### 4.1. Flutter Frontend Structure
The application interface and client-side logic will be developed using Google’s UI toolkit, Flutter.
* **Architecture Pattern:** Strictly adhering to **Clean Architecture** principles, the project will utilize **MVVM (Model-View-ViewModel)** or **BLoC (Business Logic Component)** for state management. This ensures a strict separation of concerns between the UI (User Interface) and Business Logic.
* **Layers:**
    * *Presentation Layer:* Widgets and UI components.
    * *Domain Layer:* Use cases and abstract business rules (Repository Interfaces).
    * *Data Layer:* API implementations, Firebase SDK integrations, and local caching mechanisms (Hive/Drift).
    
* **UI Framework:** Use standard Material Design 3 widgets. Avoid complex custom UI components to ensure maintainability and strictly follow standard Flutter patterns.

### 4.2. Backend (Firebase / Google Cloud)
The backend infrastructure will be implemented using a "Backend-as-a-Service" (BaaS) model via Firebase.
* **Serverless Computing:** Complex business logic (e.g., triggering notifications upon bid expiration, payment verification loops) will be executed on **Google Cloud Functions** (Node.js or Python environments).

### 4.3. REST API and Data Flow
While the application will primarily utilize Firebase SDKs for real-time data synchronization, specific **RESTful API** endpoints will be exposed via Cloud Functions to handle third-party integrations (e.g., Payment Gateways, SMS providers).

### 4.4. Database Design
Given the unstructured nature of the data and the requirement for high-velocity reads, **Cloud Firestore**—a scalable NoSQL database—will be utilized. Data will be structured in hierarchical Collections and Documents.

## 5. User Roles

### 5.1. Customer (Service Requester)
* Browsing and filtering service categories.
* Service Request Creation (incorporating multimedia attachments, geolocation, and descriptions).
* Bid Evaluation and Acceptance.
* Post-service Rating and Review submission.

### 5.2. Service Provider
* Profile Management (Portfolio, Certification upload, Service Areas).
* Listing relevant requests and utilizing the **Bidding Mechanism**.
* Earnings Dashboard and Calendar Management.

### 5.3. Admin Panel
* User Verification (KYC - Know Your Customer) and Management.
* Dispute Resolution and Complaint Management.
* Category and Commission Rate Configuration.
* System-wide Analytics and Monitoring.

## 6. MVP (Minimum Viable Product) Features
1.  **Authentication:** Multi-factor authentication via Phone (SMS) and Email.
2.  **Request Generation:** Standardized forms for service inquiries.
3.  **Bidding System:** Mechanism for providers to submit price quotes.
4.  **In-App Messaging:** Text-based chat functionality initiated upon bid acceptance (Firestore-based).
5.  **Basic Profile:** Visualization of user credentials and transaction history.
6.  **Push Notifications:** Implementing push notifications for critical events (e.g., bid acceptance, service completion).

## 7. Advanced Features
1.  **Geolocation Tracking:** Real-time tracking of the service provider via Google Maps SDK.
2.  **In-App Payments:** Secure credit card storage and transaction processing (Integration with Stripe or Iyzico).
3.  **AI-Powered Recommendations:** Service suggestions based on historical user behavior using **TensorFlow Lite**.
4.  **Story Mode:** Ephemeral content sharing for providers to showcase recent work (similar to Instagram Stories).

## 8. Database Schema Example (Firestore NoSQL)

```json
users (Collection)
 ├── userId (Document)
 │    ├── role: "customer" | "provider" | "admin"
 │    ├── profileData: { name, email, phone, avatarUrl }
 │    └── ratings: { average: 4.8, count: 50 }
 │
services (Collection)
 ├── serviceId (Document)
 │    ├── category: "Cleaning"
 │    ├── requesterId: "ref(users/userId)"
 │    ├── status: "open" | "accepted" | "completed"
 │    ├── location: GeoPoint(lat, long)
 │    └── details: { description, photos: [] }
 │
bids (Collection)
 ├── bidId (Document)
 │    ├── serviceId: "ref(services/serviceId)"
 │    ├── providerId: "ref(users/userId)"
 │    ├── price: 500.00
 │    └── timestamp: FieldValue.serverTimestamp()
```

## 9. Security Architecture
* **Authentication:** Secure session management via Firebase Auth.
* **Authorization:** Granular access control using **Firestore Security Rules** (e.g., `allow write: if request.auth.uid == userId`).
* **Custom Claims:** Embedding user roles (Admin vs. User) into auth tokens for backend verification.
* **Data Security:** All data in transit is encrypted via SSL/TLS. Sensitive data (PII) is masked or tokenized via Cloud Functions.

## 10. Scalability and Performance Plan
* **CDN Utilization:** Static assets (images/media) are distributed via Firebase Hosting and Cloud Storage CDN to reduce latency.
* **Pagination:** Implementation of "Infinite Scroll" in list views to optimize database read costs and memory usage.
* **Denormalization:** Strategic data duplication to optimize read performance, adhering to NoSQL best practices.
* **App Check:** Implementation of Firebase App Check to prevent unauthorized bot traffic and API abuse.

## 11. CI/CD and Deployment Process
DevOps pipelines will be managed using **Codemagic** or **GitHub Actions**.
1.  **Commit:** Code is pushed to the GitHub repository.
2.  **Build & Test:** CI pipeline triggers static analysis (Linter) and Unit tests.
3.  **Deploy:**
    * Backend logic (Cloud Functions) is automatically deployed.
    * Mobile artifacts (APK/IPA) are built and distributed to the QA team via **Firebase App Distribution**.
4.  **Release:** Approved builds are pushed to Google Play Console and App Store Connect.

## 12. Testing Strategy
* **Unit Tests:** Isolated testing of business logic functions (e.g., commission calculations, input validation).
* **Widget Tests:** Component-level testing of Flutter UI elements (buttons, lists).
* **Integration Tests:** End-to-End (E2E) testing of critical user flows on simulators using **Flutter Driver** or **Patrol**.

## 13. Project Calendar (Sample Weekly Milestone Plan)

| Week | Phase | Tasks & Deliverables |
| :--- | :--- | :--- |
| **1-2** | **Analysis & Design** | Requirements gathering, UI/UX Design (Figma), Database Schema Definition. |
| **3-4** | **Infrastructure Setup** | Flutter project initialization, Firebase configuration, Auth module integration. |
| **5-6** | **Customer Module** | Service request screens, Home dashboard, Category listing. |
| **7-8** | **Provider Module** | Bidding mechanism implementation, Provider dashboard development. |
| **9** | **Backend Logic** | Cloud Functions development (Notifications, Bid matching algorithms). |
| **10** | **Integration** | Chat module, Map integration, and Storage operations. |
| **11** | **Test & Bugfix** | Writing Unit and Integration tests, bug tracking and fixing. |
| **12** | **Doc & Finalization** | Thesis writing, code documentation, and presentation preparation. |

## 14. Future Scope
* **Web Platform:** Porting the Admin Panel and Customer Interface to the web using Flutter Web.
* **Subscription Models:** Introducing "Premium Membership" tiers for service providers to gain visibility.
* **Localization (i18n):** Implementing multi-language support to expand the market reach.
