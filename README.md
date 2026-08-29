
![narangavellam_resized](https://github.com/user-attachments/assets/1c6f06a2-497b-4fd3-bd87-809d54d4308c)

# Narangavellam V2

An Instagram-like social media application built with Flutter, powered by Supabase and Firebase, using an offline-first architecture with PowerSync. Scaffolded with [Very Good CLI](https://verygoodcli.com/).

---

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [System Architecture](#system-architecture)
- [Project Structure](#project-structure)
- [Packages (Monorepo)](#packages-monorepo)
- [Features](#features)
- [Platform Support](#platform-support)
- [Environment Setup](#environment-setup)
- [Running the App](#running-the-app)
- [Building the App](#building-the-app)
- [Flavors](#flavors)
- [CI/CD](#cicd)
- [Testing](#testing)
- [Localization](#localization)
- [Architecture Deep Dive](#architecture-deep-dive)

---

## Project Overview

Narangavellam is a full-featured Instagram clone designed for personal use on a self-hosted backend. It implements:

- User authentication (email/password, Google Sign-In, GitHub OAuth)
- Feed with infinite scroll, sponsored posts, and post creation
- Stories (viewing, creating, with Instagram-style editor)
- Reels (short-form vertical video with inline playback)
- Direct messaging / chat (real-time, with reply, edit, delete, shared posts)
- Comments (threaded replies, likes)
- User profiles (followers/following, avatar upload, profile editing)
- Search (user discovery)
- Push notifications (Firebase Cloud Messaging)
- Dark/Light/System theme
- Multi-language support (English, with Russian scaffolded)
- Offline-first data sync via PowerSync

---

## Tech Stack

### Core Framework
| Technology | Version | Purpose |
|---|---|---|
| **Dart** | `^3.5.0` | Programming language |
| **Flutter** | `^3.24.0` | Cross-platform UI framework |

### State Management
| Technology | Purpose |
|---|---|
| **flutter_bloc / bloc** `^8.1.6` | Primary state management (BLoC pattern) |
| **hydrated_bloc** `^9.1.5` | BLoC with JSON persistence (offline state) |
| **provider** `^6.1.5` | Lightweight state for zoom/gesture state |
| **get_it** `^8.0.3` | Service locator for dependency injection |

### Backend & Database
| Technology | Purpose |
|---|---|
| **Supabase** `^2.9.1` | Authentication, database, and storage |
| **PowerSync** | Offline-first database sync engine |
| **Firebase Core** `^3.14.0` | Firebase services initialization |
| **Firebase Remote Config** | Feature flags and remote configuration |
| **Firebase Cloud Messaging** | Push notifications |
| **SharedPreferences** | Local persistent key-value storage |

### Routing
| Technology | Purpose |
|---|---|
| **go_router** `^12.1.3` | Declarative routing with deep link support |

### Authentication
| Technology | Purpose |
|---|---|
| **google_sign_in** `^6.3.0` | Google OAuth sign-in |
| **Supabase Auth** | Email/password and OAuth provider management |

### UI & Media
| Technology | Purpose |
|---|---|
| **flex_color_scheme** | Dynamic theming (dark/light/system) |
| **animations** `^2.0.11` | Material motion transitions |
| **flutter_animate** `^4.5.2` | Declarative animation effects |
| **cached_network_image** `^3.4.1` | Image caching and lazy loading |
| **flutter_staggered_grid_view** | Quilted grid layouts (timeline) |
| **shimmer** `^3.0.0` | Loading placeholder animations |
| **lottie** `^3.3.0` | Lottie animation support |
| **story_view** `^0.16.6` | Instagram-style story viewer |
| **video_player** | Inline video playback |
| **smooth_video_progress** | Video progress indicator |
| **palette_generator** | Extract dominant colors from images |
| **flutter_blurhash** | BlurHash image placeholders |
| **image_picker / image_cropper** | Camera and gallery image selection |
| **flutter_image_compress** | Client-side image compression |
| **photo_view** | Zoomable image viewer |
| **marquee** | Scrolling text (reel participants) |
| **url_launcher** `^6.3.2` | External URL opening |

### Data & Serialization
| Technology | Purpose |
|---|---|
| **json_serializable / json_annotation** | JSON serialization code generation |
| **freezed_annotation** | Immutable data class code generation |
| **equatable** `^2.0.7` | Value equality for BLoC states/events |
| **fast_immutable_collections** `^11.0.4` | Persistent immutable data structures |
| **envied / envied_generator** `^1.1.1` | Type-safe environment variable access |
| **slang / slang_flutter** `^4.7.2` | Type-safe localization code generation |

### Code Quality
| Technology | Purpose |
|---|---|
| **very_good_analysis** `^6.0.0` | Strict Dart linting rules |
| **mocktail** `^1.0.4` | Mocking for tests |
| **bloc_test** `^9.1.7` | BLoC testing utilities |
| **build_runner** `^2.5.1` | Code generation orchestrator |

### Networking
| Technology | Purpose |
|---|---|
| **dio** | HTTP client |
| **ogp_data_extract** | Open Graph Protocol data extraction (URL previews in chat) |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │   Feed   │ │ Stories  │ │  Reels   │ │  Chats   │ │ Profile  │ │
│  │  (Bloc)  │ │  (Bloc)  │ │  (Bloc)  │ │  (Bloc)  │ │  (Bloc)  │ │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ │
│       │             │             │             │             │       │
├───────┼─────────────┼─────────────┼─────────────┼─────────────┼───────┤
│       │         DOMAIN / REPOSITORY LAYER      │             │       │
│  ┌────▼─────────────▼─────────────▼─────────────▼─────────────▼────┐ │
│  │  PostsRepository │ UserRepo │ StoriesRepo │ ChatsRepo │ Search  │ │
│  └───────────────────────────┬─────────────────────────────────────┘ │
├──────────────────────────────┼───────────────────────────────────────┤
│                          DATA LAYER                                  │
│  ┌───────────────────────────▼─────────────────────────────────────┐ │
│  │              PowerSyncDatabaseClient                            │ │
│  │         (PowerSync offline-first sync engine)                   │ │
│  └───────────────────────────┬─────────────────────────────────────┘ │
│  ┌───────────────────────────▼─────────────────────────────────────┐ │
│  │                   Supabase Backend                              │ │
│  │          (Auth, Database, Storage, Realtime)                    │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │              Firebase Services                                  │ │
│  │     (Remote Config, Cloud Messaging, Analytics)                 │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### Architectural Patterns

1. **BLoC Pattern** -- Every feature module uses `flutter_bloc` for state management. BLoCs handle business logic, side effects, and emit immutable states. Events are dispatched from the UI layer.

2. **Repository Pattern** -- Domain repositories (`PostsRepository`, `UserRepository`, etc.) abstract data access. They depend on `PowerSyncDatabaseClient` for actual database operations.

3. **Interface/Implementation Separation** -- Client packages (auth, storage, notifications) follow a strict abstract interface + concrete implementation pattern, enabling testability and swappable backends.

4. **Offline-First** -- PowerSync provides a local-first database that syncs with the Supabase backend. The app can function offline with data available locally.

5. **Hydrated BLoCs** -- Critical state (comments, posts, user stories, chat messages, locale, theme) persists across app restarts via `HydratedBloc` with JSON serialization.

6. **Monorepo with Path Packages** -- 23 internal packages organized by concern, all referencing each other via `path:` dependencies.

---

## Project Structure

```
narangavellam/
├── lib/
│   ├── main_production.dart          # Production entry point
│   ├── main_staging.dart             # Staging entry point
│   ├── main_development.dart         # Development entry point
│   ├── bootstrap.dart                # App initialization (Firebase, PowerSync, DI)
│   │
│   ├── app/                          # App-level concerns
│   │   ├── bloc/                     # AppBloc (auth state, user changes)
│   │   ├── di/                       # Dependency injection (get_it)
│   │   ├── home/                     # Home page (PageView: create + feed + chats)
│   │   ├── naviagtion/               # Bottom navigation bar
│   │   ├── routes/                   # GoRouter configuration (520+ lines)
│   │   ├── user_profile/             # User profile page, avatar, edit, followers
│   │   └── view/                     # App widget, MaterialApp.router, theme
│   │
│   ├── auth/                         # Authentication
│   │   ├── cubit/                    # AuthCubit (login/signup toggle)
│   │   ├── login/                    # Login page, LoginCubit, form fields
│   │   ├── sign_up/                  # SignUp page, SignUpCubit, avatar upload
│   │   └── forgot_password/          # Forgot password + OTP change password
│   │
│   ├── feed/                         # Main feed
│   │   ├── bloc/                     # FeedBloc (pagination, sponsored blocks)
│   │   ├── view/                     # FeedPage (NestedScrollView, stories carousel)
│   │   ├── widgets/                  # FeedPageController, dividers, loaders
│   │   └── post/                     # Individual post feature
│   │       ├── bloc/                 # PostBloc (likes, comments, follow, Hydrated)
│   │       ├── view/                 # PostView (large post display)
│   │       ├── widgets/              # Share, popup dialog, preview, edit
│   │       └── video/                # VideoPlayer with view-visibility detection
│   │
│   ├── timeline/                     # Explore/timeline grid
│   │   ├── bloc/                     # TimelineBloc (paginated grid loading)
│   │   └── view/                     # Quilted grid with inline video
│   │
│   ├── reels/                        # Short-form video
│   │   └── reel/                     # ReelView (vertical PageView, double-tap like)
│   │
│   ├── stories/                      # Stories feature
│   │   ├── bloc/                     # CreateStoriesBloc, StoriesBloc, UserStoriesBloc
│   │   ├── view/                     # Story viewer (adaptive colors, play/pause)
│   │   └── widgets/                  # Carousel, avatars, image compression
│   │
│   ├── comments/                     # Comments feature
│   │   ├── bloc/                     # CommentsBloc (Hydrated, per-post)
│   │   ├── comment/                  # CommentBloc (Hydrated, per-comment)
│   │   └── view/                     # CommentsPage (draggable sheet, reply support)
│   │
│   ├── chats/                        # Direct messaging
│   │   ├── bloc/                     # ChatsBloc (inbox list)
│   │   ├── chat/                     # ChatBloc (single conversation, Hydrated)
│   │   └── widgets/                  # Message bubbles, input, swipeable reply
│   │
│   ├── search/                       # User search
│   │   └── view/                     # SearchPage with debounced queries
│   │
│   ├── selector/                     # Settings selectors
│   │   ├── locale/                   # LocaleBloc (Hydrated, language selection)
│   │   └── theme/                    # ThemeModeBloc (Hydrated, dark/light/system)
│   │
│   ├── network_error/                # Network error UI
│   ├── l10n/                         # Localization (ARB + slang)
│   │   ├── arb/                      # ARB source files (English)
│   │   └── slang/                    # Slang-generated translations
│   │
│   ├── firebase_options_dev.dart     # Firebase config (development)
│   ├── firebase_options_stg.dart     # Firebase config (staging)
│   └── firebase_options_prod.dart    # Firebase config (production)
│
├── packages/                         # 23 internal packages (see below)
├── test/                             # Root-level widget tests
├── android/                          # Android platform project
├── ios/                              # iOS platform project
├── web/                              # Web platform project
├── macos/                            # macOS platform project
├── windows/                          # Windows platform project
│
├── pubspec.yaml                      # Main project dependencies
├── analysis_options.yaml             # Linting rules (very_good_analysis)
├── build.yaml                        # Code generation config
├── l10n.yaml                         # Localization config
├── firebase.json                     # Firebase project config
└── .github/                          # CI/CD workflows, PR template, dependabot
```

---

## Packages (Monorepo)

The project is organized as a monorepo with 23 internal packages under `packages/`. Each package is a standalone Dart/Flutter package with its own `pubspec.yaml`, `lib/`, and `test/`.

### Foundation Layer
| Package | Description |
|---|---|
| `env` | Environment variable management via `envied` + `dotenv` |
| `shared` | Central hub: models (Freezed), utilities, image processing, HTTP, logging, UUID, BlurHash |
| `form_fields` | Reusable form validation models using `formz` |
| `app_ui` | Shared UI theme, design tokens, custom fonts (Inter, Montserrat), SVG assets |

### Client Layer (Interface + Implementation)
| Package | Description |
|---|---|
| `authentication_client/` | Abstract auth contract |
| `authentication_client/supabase_authentication_client` | Supabase + Google Sign-In implementation |
| `authentication_client/token_storage` | Token persistence for auth |
| `storage/` | Abstract storage contract |
| `storage/persistent_storage` | `SharedPreferences` implementation |
| `storage/secure_storage` | `FlutterSecureStorage` implementation |
| `notifications_client/` | Abstract notifications contract |
| `notifications_client/firebase_notifications_client` | Firebase Cloud Messaging implementation |

### Database & Sync
| Package | Description |
|---|---|
| `powersync_repository` | PowerSync offline-first sync engine configuration |
| `database_client` | PowerSync/Supabase database operations (also Firebase service account) |

### Repository Layer
| Package | Description |
|---|---|
| `user_repository` | User CRUD, auth integration, followers/following |
| `posts_repository` | Post CRUD, comments, likes, feed |
| `chats_repository` | Chat/messaging data flow |
| `stories_repository` | Stories data flow with local caching |
| `search_repository` | User search functionality |
| `notifications_repository` | Notification permissions and token management |
| `firebase_remote_config_repository` | Feature flags and remote configuration |

### UI Component Layer
| Package | Description |
|---|---|
| `insta_blocks` | Instagram-style block data models for content |
| `instagram_blocks_ui` | Rich Flutter widgets for content rendering (carousels, video, shimmer, BlurHash) |

### Standalone Feature Packages
| Package | Description |
|---|---|
| `stories_editor` | Instagram-style story editor (drawing, text, stickers, GIFs) |
| `gallery_media_picker` | Custom gallery picker UI |
| `image_picker_plus` | Advanced image/video picker with camera and cropping |

---

## Features

### Feed
- Infinite scroll with paginated loading
- Sponsored post insertion via isolates (random intervals from Firebase Remote Config)
- Post creation with media upload (image/video compression, BlurHash generation)
- Pull-to-refresh
- Long-press popup dialog (like, comment, share, options)
- Inline video playback with view-visibility detection

### Stories
- Stories carousel on feed (horizontal list of avatars)
- Story viewer with adaptive text/icon colors (based on image dominant color)
- Story creation via Instagram-style editor (drawing, text, stickers, GIFs)
- Mark as seen, delete stories
- Feature gating via Firebase Remote Config (`enable_create_stories`)

### Reels
- Vertical `PageView` for scrolling through reels
- Inline video playback with play/pause
- Double-tap to like with animation overlay
- Like, comment, delete (owner only)
- Author info with follow button
- Pull-to-refresh

### Chat / Direct Messaging
- Chat inbox list with last message preview
- Real-time message streaming
- Send, edit, delete messages
- Swipe-to-reply with quoted message preview
- Markdown support in messages
- URL preview cards (OGP data extraction)
- Read receipts (viewed status)
- Floating date separator
- Background image with theme support

### Comments
- Threaded replies (nested comment view)
- Like/unlike comments
- Delete comments (with confirmation)
- Real-time comment streaming
- Emoji row in comment input
- Reply-to-comment UI with username mention

### User Profile
- Profile header with avatar, stats (posts, followers, following)
- Follow/unfollow functionality
- Edit profile (full name, username, bio, avatar)
- User posts grid view
- User posts list view (scrollable)
- Follower/following lists with action buttons
- Shimmer loading placeholders

### Authentication
- Email/password login and signup
- Google Sign-In
- Forgot password with OTP verification
- Form validation via `formz`
- Animated transitions between login/signup

### Search
- Debounced user search
- Dual navigation (return result or navigate to profile)
- `ValueNotifier`-based lightweight state management

### Settings
- Theme selector (System / Light / Dark) with `HydratedBloc` persistence
- Locale selector (English, Russian scaffolded)
- Logout

---

## Platform Support

| Platform | Status |
|---|---|
| Android | Supported |
| iOS | Supported |
| Web | Supported |
| macOS | Supported |
| Windows | Supported |

---

## Environment Setup

### Prerequisites

1. **Flutter SDK** `^3.24.0` (stable channel)
2. **Dart SDK** `^3.5.0`
3. **Android Studio** or **VS Code** with Flutter/Dart plugins
4. **Xcode** (for iOS/macOS development)
5. **CocoaPods** (for iOS/macOS dependencies)

### Step-by-Step Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd fixed_followers-backup
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Install packages dependencies:**
   Each package in `packages/` has its own `pubspec.yaml`. The root `flutter pub get` handles path dependencies, but you can also install individually:
   ```bash
   cd packages/shared && flutter pub get
   cd ../app_ui && flutter pub get
   # ... etc for each package
   ```

4. **Set up environment variables:**

   Create `.env` files in the `packages/env/` directory for each flavor:
   ```
   packages/env/.env.dev     # Development environment
   packages/env/.env.stg     # Staging environment
   packages/env/.env.prod    # Production environment
   ```

   These files should contain environment-specific values (Supabase URL, anon key, Google client IDs, etc.) referenced by the `envied` package.

5. **Configure Firebase:**

   The project uses three Firebase projects:
   - Development: `narangavellam-dev-c8eb7`
   - Staging: `narangavellam-stg-86763`
   - Production: `narangavellam-prod-c4f15`

   Firebase configuration files are generated via `flutterfire configure` and stored as:
   - `android/app/google-services.json`
   - `lib/firebase_options_dev.dart`
   - `lib/firebase_options_stg.dart`
   - `lib/firebase_options_prod.dart`

6. **Configure Supabase:**

   Create a Supabase project and configure the connection details in the environment files. The app uses Supabase for:
   - Authentication (email/password, OAuth)
   - Database (via PowerSync sync)
   - Storage (user avatars, post media, story media)

7. **Configure PowerSync:**

   PowerSync requires a `powersync` configuration. The `powersync_repository` package handles initialization. Ensure the PowerSync service is running and accessible.

8. **Run code generation:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

   This generates:
   - JSON serialization (`*.g.dart` files)
   - Slang translations (`translations.g.dart`)
   - Environment variables (`envied`)

9. **Set up Android signing:**

   Place your keystore file and configure `android/key.properties` (gitignored).

10. **Platform-specific setup:**

    - **iOS/macOS:** Run `cd ios && pod install` (or `macos`)
    - **Windows:** Ensure CMake is installed
    - **Web:** No additional setup needed

---

## Running the App

Choose a flavor (development, staging, or production) and run:

```bash
# Development
flutter run --flavor development -t lib/main_development.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor production -t lib/main_production.dart
```

---

## Building the App

### APK (Android)
```bash
flutter build apk --flavor development -t lib/main_development.dart
flutter build apk --flavor staging -t lib/main_staging.dart
flutter build apk --flavor production -t lib/main_production.dart
```

### App Bundle (Android)
```bash
flutter build appbundle --flavor production -t lib/main_production.dart
```

### iOS
```bash
flutter build ios --flavor production -t lib/main_production.dart
```

### Web
```bash
flutter build web --flavor production -t lib/main_production.dart
```

### macOS
```bash
flutter build macos --flavor production -t lib/main_production.dart
```

### Windows
```bash
flutter build windows --flavor production -t lib/main_production.dart
```

---

## Flavors

The app uses three flavors, each with its own Firebase project and environment configuration:

| Flavor | Entry Point | Firebase Project | Use Case |
|---|---|---|---|
| **development** | `lib/main_development.dart` | `narangavellam-dev-c8eb7` | Local development and debugging |
| **staging** | `lib/main_staging.dart` | `narangavellam-stg-86763` | Pre-release testing |
| **production** | `lib/main_production.dart` | `narangavellam-prod-c4f15` | End-user release |

Each flavor:
- Uses a different `FirebaseOptions` file
- Creates a different `AppFlavor` instance with flavor-specific environment variables
- Development and Production wrap the `App` in `ChangeNotifierProvider<ZoomStateProvider>` (staging does not)

---

## CI/CD

### GitHub Actions (`.github/workflows/main.yaml`)

The CI pipeline runs on pushes and pull requests to `main`:

1. **Semantic Pull Request** -- Validates PR title follows conventional commit format
2. **Flutter Package Build** -- Runs `flutter analyze`, `flutter test`, and build verification using VeryGoodOpenSource workflows
3. **Spell Check** -- Checks markdown files for spelling errors

### Dependabot (`.github/dependabot.yaml`)

Automated dependency updates:
- **GitHub Actions** -- Daily checks for action version updates
- **Pub packages** -- Daily checks for Dart/Flutter dependency updates

### PR Template (`.github/PULL_REQUEST_TEMPLATE.md`)

Standardized PR template with change type checkboxes:
- New feature, Bug fix, Breaking change, Refactor, Build config, Documentation, Chore

---

## Testing

### Test Structure

```
test/
├── app/view/app_test.dart           # Widget test for App
└── helpers/
    ├── helpers.dart                  # Test helper exports
    └── pump_app.dart                 # WidgetTester.pumpApp() extension

packages/
├── */test/src/*_test.dart           # Per-package unit tests (28 total)
```

### Testing Approach

- **Framework:** `flutter_test` + `mocktail` for mocking
- **Widget Tests:** The root `test/` contains a widget test that verifies `App` renders a `Scaffold` with all mocked dependencies
- **Unit Tests:** Each package has a `test/src/` directory with stub/placeholder tests (most are scaffolded but not yet implemented)
- **Test Helper:** `PumpApp` extension wraps widgets in a `MaterialApp` with localization delegates

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run tests for a specific package
cd packages/chats_repository && flutter test
```

### Test Coverage

The test suite is in early development. Most package-level tests are stubs (`void main() {}`) or placeholders with empty test bodies. A few packages have functional tests:
- `app_test.dart` -- Widget test
- `chats_repository_test.dart` -- Unit test with mocks
- `secure_storage_test.dart` -- Unit test
- `instagram_blocks_ui_test.dart` -- Widget test

---

## Localization

### Setup

- **ARB files:** `lib/l10n/arb/app_en.arb` (English source)
- **Generated output:** `lib/l10n/app_localizations.dart` + `app_localizations_en.dart`
- **Slang translations:** `lib/l10n/slang/translations.g.dart` (for rich text/interpolation)
- **Config:** `l10n.yaml` at project root

### Supported Locales

| Locale | Status |
|---|---|
| English (`en`) | Fully supported |
| Russian (`ru`) | Scaffolded (commented out in locale selector) |

### Usage

```dart
// In widgets
context.l10n.feedAppBarTitle
context.l10n.likesCountText(5)

// Rich text (via slang)
TranslationProvider.of(context).translations.likedBy(name: "Alice", and: "and", others: "2 others")
```

### Adding New Strings

1. Add the string to `lib/l10n/arb/app_en.arb`
2. Run `dart run slang` to regenerate translations
3. Use `context.l10n.yourKey` in widgets

---

## Architecture Deep Dive

### Bootstrap Flow (`bootstrap.dart`)

1. Set up `FlutterError.onError` and `Bloc.observer`
2. Initialize `WidgetsFlutterBinding`
3. Enable screen protection on Android (`ScreenProtector.preventScreenshotOn`)
4. Set up DI via `setupDi(appFlavor:)`
5. Initialize Firebase
6. Initialize `HydratedBloc.storage`
7. Initialize PowerSync repository
8. Get `SharedPreferences` instance
9. Initialize `FirebaseRemoteConfig` and `FirebaseMessaging`
10. Set portrait orientation
11. Run the app with `TranslationProvider`

### App Initialization (`main_*.dart`)

Each flavor entry point:
1. Calls `bootstrap()` with the appropriate `FirebaseOptions` and `AppFlavor`
2. Creates all repositories: `UserRepository`, `PostsRepository`, `SearchRepository`, `StoriesRepository`, `ChatsRepository`, `NotificationsRepository`
3. Creates authentication client (`SupabaseAuthenticationClient`)
4. Wraps the `App` widget with providers and returns it

### Routing (`routes.dart`)

Uses `go_router` with `StatefulShellRoute.indexedStack` for bottom navigation:

```
/auth                    → AuthPage
/feed                    → FeedPage (stories + posts)
/timeline                → TimelinePage (grid + search)
/create_media            → Redirect
/reels                   → ReelsView
/user                    → UserProfilePage
/users/:user_id          → UserProfilePage
/chat/:chat_id           → ChatPage
/posts/:id               → PostPreviewPage
/posts/:post_id/edit     → PostEditPage
/stories/:user_id        → StoriesPage
/settings                → SettingsPage
```

- Unauthenticated users are redirected to `/auth`
- Authenticated users on `/auth` are redirected to `/feed`
- `GoRouterAppBlocRefreshStream` refreshes routing on auth state changes

### BLoC Event Flow

```
UI Layer (Widget)
    │
    ├── context.read<Bloc>().add(Event)
    │
    ▼
BLoC Layer (Bloc<Event, State>)
    │
    ├── Handles event logic
    ├── Calls repository methods
    ├── Emits new State
    │
    ▼
Repository Layer
    │
    ├── Calls database_client methods
    │
    ▼
PowerSyncDatabaseClient
    │
    ├── Syncs with Supabase backend
    └── Returns data streams
```

### Video Player Architecture

The app uses a custom `VideoPlayerInheritedWidget` that provides global video playback state:

- `VideoPlayerState` manages play flags for feed, timeline, and reels
- Only one video plays at a time across the entire app
- `VideoPlayerInViewNotifierWidget` only plays when the video is in the viewport
- Tab switches automatically pause/play the appropriate player

### Sponsored Post Insertion

Sponsored blocks are inserted into the feed using isolates:
1. `FeedBlocMixin.insertSponsoredBlocks()` spawns a compute isolate
2. The isolate function `_computeSponsoredBlocks()` randomly inserts sponsored blocks at intervals
3. Uses `FirebaseRemoteConfigRepository` to fetch sponsored post data
4. Random skip ranges prevent predictable ad placement

---

## Key Configuration Files

| File | Purpose |
|---|---|
| `pubspec.yaml` | Main project dependencies and metadata |
| `analysis_options.yaml` | Dart linting rules (very_good_analysis) |
| `build.yaml` | Code generation config (json_serializable, slang) |
| `l10n.yaml` | Localization config (ARB directory, template file) |
| `firebase.json` | Firebase project configuration per platform |
| `.github/dependabot.yaml` | Automated dependency updates |
| `.github/workflows/main.yaml` | CI/CD pipeline |
| `packages/env/.env.*` | Environment variables (gitignored) |
| `android/key.properties` | Android signing config (gitignored) |
