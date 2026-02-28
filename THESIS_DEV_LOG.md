# Needo - Thesis Development Log

## [2026-02-19] Initialization & Architectural Strategy

### Decision: Adoption of Clean Architecture & Serverless Infrastructure
**Context:** The project "Needo" is a real-time service marketplace requiring high scalability and maintainability.
**Decision:** We have selected **Flutter** for the frontend and **Google Cloud Platform (Firebase)** for the backend, architected using **Clean Architecture** principles.

### Academic Justification
1.  **Separation of Concerns (Modularity):** Clean Architecture enforces a strict boundary between the Presentation, Domain, and Data layers. This ensures that business logic (Domain) remains independent of UI changes or external data sources, facilitating easier testing and future modifications—a key requirement for academic software engineering standards.
2.  **Scalability (Serverless):** The "Backend-as-a-Service" (BaaS) model with Firebase and Cloud Functions allows the system to auto-scale in response to demand spikes (e.g., concurrent service requests) without manual server provisioning. This demonstrates a modern "Cloud-Native" approach.
3.  **Cost-Efficiency:** The ephemeral nature of Cloud Functions and the pay-as-you-go model of Firestore align with the budgetary constraints of a thesis project while mimicking real-world startup resource management.

### Next Steps
1.  GCP Safety Setup (Billing Alerts & API Restrictions) [COMPLETED].
2.  Implementation of the core folder structure [COMPLETED].

## [2026-02-20] Project Initialization & Structure

### Action: Flutter Project Created & Structured
**Command Executed:** `flutter create --project-name needo --org com.needo .`
**Structure Implemented:**
-   `lib/core/`: Application-wide utilities (error handling, usecase interfaces).
-   `lib/config/`: Configuration (theme, routes).
-   `lib/features/`: Modular business logic (Auth, ServiceRequest, etc.).

**Academic Justification:**
This structure implements **Clean Architecture**, ensuring:
1.  **Independence of Frameworks:** The core business logic doesn't depend on the UI.
2.  **Testability:** Business rules can be tested without the UI, database, or network.
3.  **Independence of UI:** The UI can change easily, without changing the rest of the system.


### [2026-02-20] Core Configuration Implementation

### Action: Theme & Routing Setup
**Files Created:**
*   `lib/config/theme.dart`: Implemented **Material 3** Theme Data.
*   `lib/config/routes.dart`: Defined application routes string constants and map.
*   `lib/main.dart`: Updated to use the new theme and route configuration.

**Academic Justification:**
1.  **Strict Material 3 Compliance:** Ensuring modern UI standards as per Google's design guidelines.
2.  **Centralized Configuration:** By decoupling theme and routes from the main app widget, we maintain the single responsibility principle.


### [2026-02-20] Auth Feature: Domain Layer Implemented

### Action: Core & Auth Domain Setup
**Added Dependencies:** `fpdart` (functional error handling), `equatable` (value equality).
**Core Abstractions Created:**
*   `lib/core/error/failures.dart`: Base failure classes.
*   `lib/core/usecases/usecase.dart`: Functional interface (`Either`) for all business operations.
**Auth Domain Implemented:**
*   `UserEntity`: Pure Dart model.
*   `AuthRepository` (Interface): Contracts for login, register.
*   `LoginUseCase`: Specific business rule execution.

**Academic Justification:**
1.  **Dependency Inversion Principle:** The Domain Layer is 'pure' Dart. It dictates the rules to the Data layer via interfaces (Repositories). It has zero knowledge of Firebase or Flutter.
### [2026-02-20] Auth Feature: Data Layer Implemented

### Action: Firebase Integration & Repositories
**Added Dependencies:** `firebase_auth`, `cloud_firestore`
**Data Layer Implemented:**
*   `UserModel`: Extends `UserEntity`. Added `fromJson` and `toJson` logic out of the Domain layer.
*   `AuthRemoteDataSource`: Directly interacts with Firebase to fetch/write DocumentSnapshots.
*   `AuthRepositoryImpl`: The critical bridge. It calls the Data Source resulting in a `UserModel`, catches raw Firebase exceptions, and translates them to `Either<Failure, UserEntity>` for the Domain layer.

**Academic Justification:**
### [2026-02-20] Auth Feature: Presentation Layer Implemented

### Action: State Management & UI Integration
**Added Dependencies:** `flutter_bloc`
**Presentation Layer Implemented:**
*   `AuthEvent` & `AuthState`: Defined the strict inputs (e.g., `LoginRequestedEvent`) and outputs (e.g., `AuthLoading`, `Authenticated`) of the Auth feature.
*   `AuthBloc`: The state machine. It listens to Events, executes the Domain `LoginUseCase`, and emits new States based on the `Either` result.
*   `LoginScreen`: A purely declarative UI that listens to `AuthBloc` state changes (to show loading spinners or snappers) and triggers events on button press.
*   `main.dart` (Dependency Injection): Initialized Firebase, instantiated the repositories/usecases, and injected the `AuthBloc` into the widget tree via `MultiBlocProvider`.

**Academic Justification:**
1.  **Unidirectional Data Flow:** By strictly using BLoC (Events in -> State out), the UI is completely predictable and easy to debug. The UI cannot randomly change state; it must dispatch an Event.
2.  **Dependency Injection (IoC):** Instantiating the Repositories at the top level (`main.dart`) and passing them down demonstrates Inversion of Control. The BLoC doesn't know *how* `LoginUseCase` is created, it just uses it. This is a hallmark of enterprise-grade software architectures.

### [2026-02-20] Phase 3: External Integrations

### Action: FlutterFire Auto-Configuration
**Implemented Setup:**
*   Utilized **FlutterFire CLI** to automatically generate platform-specific API configurations into `lib/firebase_options.dart`.
*   Modified `main.dart` to execute `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` before `runApp`.

**Academic Justification:**
*   **Decoupling Configuration:** Instead of hard-coding API keys in Android/iOS native files (legacy method), FlutterFire keeps configuration strictly within the Dart/Flutter environment. This minimizes platform-specific bugs and ensures API keys are not accidentally pushed to source control (if `firebase_options.dart` is added to `.gitignore`).

### [2026-02-20] Application Feature Extension: Registration Flow

### Action: Implement Sign Up
**Implementation Pipeline:**
1.  **Domain:** `RegisterUseCase` executing `AuthRepository.registerCustomer()`.
2.  **Presentation (State):** `RegisterRequestedEvent` added to `AuthEvent`, handled by `AuthBloc` which yields standard `AuthLoading` and `Authenticated`/`AuthError` states.
3.  **Presentation (UI):** `SignUpScreen` created, providing name/email/password inputs.
4.  **Integration:** Provided `RegisterUseCase` to `AuthBloc` via `main.dart` dependency injection. Button added to `LoginScreen` for navigation.

**Academic Justification:**
*   **Feature Expansion Resilience:** This addition demonstrated how Clean Architecture absorbs new features. We added Registration *without changing the Data Layer* (since `registerCustomer` was already defined in the interface and implemented in Firebase). We only extended Domain (UseCase) and Presentation (BLoC/UI). This proves the architecture's maintainability.


### [2026-02-20] Application Feature Extension: Main Dashboard Layout

### Action: Implement IndexedStack Architecture
**Implementation Pipeline:**
1.  **Screens:** Created placeholder UI screens for Home, Service Requests, and Profile.
2.  **Layout Manager:** Created `MainLayout.dart` acting as the root scaffold post-login.
3.  **State Retention:** Implemented `IndexedStack` linked to a `BottomNavigationBar`.

**Academic Justification:**
*   **Performance Optimization (IndexedStack):** Using `IndexedStack` instead of constantly pushing/popping routes using `Navigator` ensures that the state of each tab (e.g., scroll position in the Requests list) is preserved in memory. It prevents unnecessary widget rebuilds and network re-fetches, which is crucial for a responsive mobile application.

### [2026-02-20] Application Feature Extension: Home Screen UI

### Action: Implement Home Screen Layout and Cubit
**Implementation Pipeline:**
1.  **Domain:** Created abstract `CategoryEntity` and `ServiceProviderEntity` to define the shape of marketplace data.
2.  **State Management:** Created `HomeCubit` to simulate an asynchronous network request that fetches and emits dummy categories and featured providers.
3.  **Presentation (UI):** Built `HomeScreen` featuring a search bar in the `AppBar`, a `GridView` for categorized services, and a horizontal `ListView` for Popular Services. 

### [2026-02-20] Application Feature Extension: Service Request Flow (Customer)

### Action: Implement Domain, Data, and Presentation Layers
**Implementation Pipeline:**
1.  **Domain:** Created `ServiceRequestEntity` (id, userId, categoryId, etc.) and `ServiceRequestRepository` interface with `createRequest`.
2.  **Data:** 
    *   Created `ServiceRequestModel` with `fromJson`/`toJson` mappings for Firestore (including translating standard `DateTime` to Firestore `Timestamp`).
    *   Implemented `ServiceRequestRemoteDataSourceImpl` pointing to a `'requests'` top-level collection.
    *   Implemented `ServiceRequestRepositoryImpl` to catch Firebase exceptions and return Clean Architecture `Failure` objects via `Either`.
    *   Added `ServerException` class for robust error handling.
3.  **Presentation (UI):** Built `CreateServiceRequestScreen` featuring form validation, Date Pickers, and `TextFormField`s.
4.  **Routing:** Adjusted `routes.dart` to use `onGenerateRoute` for `/create-request`, allowing passing of the `categoryId` payload extracted from the Home Screen category grid.

### Action: Inject Service Request BLoC and Wire UI
**Implementation Pipeline:**
1.  **Domain:** Created `CreateRequestUseCase`, applying the repository pattern.
2.  **State Management:** Developed `ServiceRequestBloc`, managing `CreateServiceRequestEvent`. It extracts the `userId` directly from `FirebaseAuth` ensuring isolated security logic.
3.  **Dependency Injection:** Injected `ServiceRequestRemoteDataSource`, `ServiceRequestRepository`, `CreateRequestUseCase`, and `ServiceRequestBloc` via `MultiBlocProvider` in `main.dart`.
4.  **UI Wiring:** Refactored `CreateServiceRequestScreen` body to use `BlocConsumer`. It dispatches the event on submit and reacts to `ServiceRequestSuccess` by popping the screen and showing a success SnackBar.

### [2026-02-21] Application Feature Extension: Service Request List (Read Flow)

### Action: Implement Real-Time Firestore Streaming
**Implementation Pipeline:**
1.  **Domain:** Extended `ServiceRequestRepository` with `getUserRequests` returning a `Stream`. Created `GetUserRequestsUseCase`.
2.  **Data:** Implemented `snapshots()` listener in `ServiceRequestRemoteDataSourceImpl`, mapping Firestore documents directly to a stream of `ServiceRequestModel`s.
3.  **State Management:** Updated `ServiceRequestBloc` to handle `LoadMyRequestsEvent`. It securely subscribes to the UseCase stream, mapping incoming data to `_ServiceRequestsLoadedEvent` to trigger UI rebuilds dynamically.
4.  **Presentation (UI):** Built `RequestsScreen` mapping `ServiceRequestsLoaded` state to a `ListView.builder`. Designed distinct UI Cards for requests, including status color-coding (Open: Orange, Completed: Green, Cancelled: Red) and formatted dates using `intl`. Connected the screen to the `IndexedStack` inside `MainLayout`.

**Academic Justification:**
*   **Reactive Data Flow (Streams):** By mapping a Firestore `snapshot()` stream all the way through the Data and Domain layers into the BLoC, the UI becomes purely reactive. If a request status changes in the database, the BLoC automatically receives the new stream chunk and emits a new state, updating the UI instantly without requiring pulling/refreshing. This represents a modern, highly responsive data architecture.




## [2026-02-22] Feature Extension: User Profile & Authentication Control

### Action: Implement Logout & Profile Management
**Implementation Pipeline:**
1.  **Domain:** Created `LogOutUseCase` in the Auth feature.
2.  **Data:** Implemented `signOut()` in `AuthRemoteDataSource` using `FirebaseAuth`.
3.  **Presentation (State):** Handled `LogoutRequested` event in `AuthBloc`.
4.  **UI:** Built `ProfileScreen` displaying dynamic user data (Name, Email) and a Logout button.
5.  **Navigation Security:** Ensured that logging out clears the entire navigation stack (`Navigator.pushNamedAndRemoveUntil`) to prevent unauthorized "back" navigation.

**Academic Justification:**
* **Session Management Security:** By strictly clearing the navigation stack upon logout, we adhere to secure session handling practices, ensuring that cached user data in the widget tree is disposed of immediately.

## [2026-02-22] Feature Extension: Request Lifecycle Management (Cancellation)
### Action: Implement Request Cancellation Logic
**Implementation Pipeline:**
1.  **Domain:** Created `CancelRequestUseCase`.
2.  **Data:** Implemented `cancelRequest` in `ServiceRequestRemoteDataSource` (Updating Firestore status to 'Cancelled').
3.  **UI:** Created `RequestDetailScreen`. Added conditional rendering: The "Cancel" button only appears if the status is strictly 'Open'.
4.  **State Management Fix:** Resolved a state pollution bug where the `RequestsScreen` (List) would hang on a loading spinner after returning from a cancellation. Implemented `buildWhen` in `BlocConsumer` to isolate List states from Detail states.

**Academic Justification:**
* **Finite State Machine (FSM):** The request lifecycle (Open -> Cancelled) is enforced by both UI logic (conditional button) and backend validation, representing a robust FSM implementation.

## [2026-02-22] Phase 4: Service Provider Module (Supply Side)

### Action: Provider Registration & Dashboard
**Implementation Pipeline:**
1.  **Data Structure:** Updated `UserEntity` and Firestore `users` collection to include `isProvider` (bool), `serviceCategory` (String), and `hourlyRate` (String).
2.  **Domain:** Created `BecomeProviderUseCase` and `GetOpenRequestsByCategoryUseCase`.
3.  **UI:** Built `BecomeProviderScreen` (Form) and `ProviderDashboardScreen` (Job Feed).
4.  **Query Logic:** The Dashboard uses a complex query: `requests.where('status', '==', 'Open').where('categoryId', '==', providerCategory)`. This ensures providers only see relevant, active jobs.

**Academic Justification:**
* **Role-Based Access Control (RBAC):** The system dynamically adjusts the UI and data access privileges based on the `isProvider` flag, demonstrating a scalable RBAC architecture within a single application codebase.

## [2026-02-22] Phase 5 & 6: Bidding System (Sub-collection Architecture)

### Action: Implement Bidding Logic
**Implementation Pipeline:**
1.  **Database Design:** Chosen **Sub-collection Pattern** (`requests/{requestId}/bids/{bidId}`). This ensures efficient fetching of bids for a specific request without polling a massive top-level collection.
2.  **Domain:** Created `BidEntity` and `PlaceBidUseCase`.
3.  **UI:** Built `ProviderJobDetailScreen` with a "Place Bid" FAB (Floating Action Button).
4.  **Interaction:** Implemented a Dialog for entering bid amount and notes.

**Academic Justification:**
* **NoSQL Data Modeling:** The decision to use sub-collections demonstrates an understanding of NoSQL access patterns (Accessing Parent -> Fetching Children), optimizing read costs and organizing data logically.

## [2026-02-23] Phase 7: Marketplace Transaction (Acceptance)

### Action: Implement Bid Acceptance Flow
**Implementation Pipeline:**
1.  **Domain:** Created `AcceptBidUseCase`.
2.  **Transaction Logic:** When a customer accepts a bid, the system performs an atomic update on the Request Document:
    * `status` -> 'In Progress'
    * `providerId` -> Winning Bidder's ID
    * `price` -> Agreed Bid Amount
3.  **UI:** Updated `RequestDetailScreen` to list real-time bids via `StreamBuilder`. Added "Accept" buttons for the request owner.

**Academic Justification:**
* **Atomic Data Consistency:** Critical business logic (assigning a provider and changing status) happens in a single operation, preventing race conditions where a request could be accepted by multiple providers simultaneously.

## [2026-02-23] Phase 8: Job Completion & Rating System

### Action: Close Loop & Feedback Mechanism
**Implementation Pipeline:**
1.  **Domain:** Created `CompleteJobUseCase` and `RateProviderUseCase`.
2.  **UI:** Implemented dynamic state switching in `RequestDetailScreen`:
    * If `In Progress` -> Show "Complete Job" button.
    * If `Completed` -> Show "Job Completed" Banner + Rating Stars.
3.  **Feedback Data:** Ratings (1-5 stars) and Reviews are stored directly on the Request document for easy retrieval.

**Academic Justification:**
* **Full Lifecycle Management:** The system now handles the complete Service Lifecycle: `Draft -> Open -> Bidded -> In Progress -> Completed -> Rated`. This satisfies the core requirement of a Service Marketplace Thesis.

## [2026-02-24] Phase 10: UI/UX Overhaul (Design System Integration)

### Action: Adoption of "Stitch" Design System
**Implementation Pipeline:**
1.  **Design System:** Adopted a modern aesthetic:
    * **Primary Color:** Electric Blue (`#135BEC`)
    * **Typography:** Google Fonts `Inter`
    * **Shapes:** Rounded Corners (12px - 32px)
2.  **Refactoring:**
    * **Onboarding:** Created a visual introduction screen with 3D assets.
    * **Login:** Completely rewrote `LoginScreen` to match the HTML/Tailwind specification provided (Custom Input fields, Shadow styling).
3.  **Technical Debt:** Fixed `main.dart` initialization and routing logic to support the new Onboarding flow (`SharedPreferences` check).

**Academic Justification:**
* **Human-Computer Interaction (HCI):** The transition from stock Material Design to a custom Design System demonstrates attention to Usability Heuristics (Consistency, Aesthetics, and Minimalist Design).




