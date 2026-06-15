# OmniPost — Cross-Platform Social Composer

Write a post **once**, see exactly how it will look on **Instagram, Facebook,
LinkedIn and X**, tailor it per network, then publish or schedule it — all from
one screen.

Built with Flutter using a clean **MVVM** architecture and **Riverpod** for
state management.

---

## ✨ Features

- **Compose once, publish everywhere** — one shared content field flows to every
  selected platform.
- **Live, platform-accurate previews** — feed-style mockups for Instagram,
  Facebook, LinkedIn and X update on every keystroke and image change.
- **Per-platform customization** — override the copy for any network, with live
  character budgets against each platform's real limit (X 280, LinkedIn 3 000,
  Instagram 2 200, Facebook 63 206).
- **Per-platform image cropping** — crop the same photo to each network's
  recommended aspect ratio (1:1, 4:5, 1.91:1, 16:9).
- **Hashtag & mention tools** — suggestions, counts, and quick insertion with
  per-platform hashtag-limit awareness.
- **Drafts & history** — save drafts and browse previously published posts with
  per-platform success/failure results.
- **Scheduling** — queue a post for a future date/time with a local reminder.
- **Account management** — connect/disconnect each platform via OAuth2 (PKCE).
- **Validation** — blocking errors (e.g. Instagram needs an image, text over the
  limit) disable publishing until resolved.

---

## 🏛 Architecture (MVVM + Riverpod)

```
View  ──watches──▶  ViewModel (Notifier)  ──calls──▶  Repository / Service  ──▶  Model
 ▲                                                                                  │
 └───────────────────────────  reactive state  ◀──────────────────────────────────┘
```

- **Model** (`data/models`, `data/repositories`, `data/services`) — immutable
  data classes, persistence and networking. No Flutter/UI imports.
- **ViewModel** (`presentation/viewmodels`) — Riverpod `Notifier` /
  `AsyncNotifier` classes that hold UI state and expose intents
  (`updateBaseText`, `togglePlatform`, `publish`, …). All UI logic lives here.
- **View** (`presentation/views`) — `ConsumerWidget`s that watch a ViewModel and
  render. Preview widgets are intentionally "dumb" (data in → UI out) so they're
  trivial to test and reuse.

### Why Riverpod?

This app is a good fit for Riverpod specifically because:

1. **Shared, cross-screen editable state.** The working post (text, media,
   selected platforms, per-platform overrides) is read and mutated by many
   widgets across the Edit and Preview tabs. A single `NotifierProvider`
   (`composerViewModelProvider`) is the one source of truth — every preview and
   counter recomputes automatically.
2. **Derived state for free.** Validation and previews are pure functions of the
   post; widgets just `watch` and recompute. No manual listeners.
3. **Async without boilerplate.** Connecting accounts, loading drafts and
   publishing use `AsyncNotifier` + `AsyncValue` for clean loading/error/data.
4. **Compile-safe & testable DI.** Services are injected via providers and
   overridden with fakes in tests — no `BuildContext`, no service locator.

> `flutter_bloc` would also work but adds event/state boilerplate that isn't
> justified here; `setState`/`Provider` would struggle with the amount of shared
> derived state. Riverpod is the sweet spot for this use case.

### Folder structure

```
lib/
├── main.dart                 # bootstraps SharedPreferences + ProviderScope
├── app.dart                  # MaterialApp.router + theme
├── core/
│   ├── config/api_config.dart    # credentials + demoMode switch
│   ├── constants/                # app + persistence keys
│   ├── router/app_router.dart    # go_router
│   ├── theme/                    # Material 3 colors, typography, theme
│   └── utils/                    # Result, extensions, validators
├── data/
│   ├── models/                   # Post, PlatformContent, MediaAttachment, …
│   ├── repositories/             # PostRepository, AccountRepository
│   └── services/
│       ├── social/               # SocialPublisher + IG/FB/LI/X publishers
│       ├── oauth_service.dart     # OAuth2 PKCE flow
│       ├── publish_service.dart   # fan-out orchestrator
│       ├── media_service.dart     # pick + crop
│       ├── scheduler_service.dart # local notifications
│       ├── token_store.dart       # secure token storage
│       └── local_store.dart       # SharedPreferences JSON
└── presentation/
    ├── providers/                # DI + navigation providers
    ├── viewmodels/               # Composer / Accounts / Library
    ├── views/                    # composer, preview, accounts, library, home
    └── widgets/                  # shared widgets (avatars, badges)
```

---

## 🚀 Getting started

This repo contains the Dart source (`lib/`, `test/`). Generate the platform
runners and fetch packages:

```bash
cd social_media_app
flutter create .          # generates android/, ios/, etc. (won't touch lib/)
flutter pub get
flutter run
```

> Requires Flutter ≥ 3.24 (Dart ≥ 3.5). Run `flutter analyze` and `flutter test`
> to check the codebase.

The app launches in **demo mode** — connecting accounts and publishing are
simulated, so the entire flow (compose → customize → preview → publish/schedule)
works immediately with no developer accounts.

---

## 🔌 Going live (real publishing)

Out of the box `ApiConfig.demoMode = true`. The **real OAuth2 + HTTP publishing
code** is already written in `lib/data/services/`. To enable it:

1. **Create a developer app** on each platform and get a client id/secret:
   - Instagram & Facebook → Meta for Developers (Graph API; Instagram needs a
     Business/Creator account linked to a Facebook Page).
   - LinkedIn → LinkedIn Developers (request `w_member_social`).
   - X → X Developer Platform (paid; a project with **write** access).
2. **Register the redirect URI** `omnipost://oauth-callback` as an allowed OAuth
   callback on each app.
3. **Provide credentials** via `--dart-define` (recommended) or by editing
   `lib/core/config/api_config.dart`:

   ```bash
   flutter run \
     --dart-define=IG_CLIENT_ID=... --dart-define=IG_CLIENT_SECRET=... \
     --dart-define=FB_CLIENT_ID=... --dart-define=FB_CLIENT_SECRET=... \
     --dart-define=LI_CLIENT_ID=... --dart-define=LI_CLIENT_SECRET=... \
     --dart-define=X_CLIENT_ID=...  --dart-define=X_CLIENT_SECRET=...
   ```

4. **Set `demoMode = false`** in `api_config.dart`.
5. **Implement the marked integration points** (`INTEGRATION POINT` in the
   publisher files): image hosting for IG/FB (Graph API needs a public image
   URL) and the asset/media upload steps for LinkedIn and X.
6. **Configure deep links** so the OAuth redirect returns to the app:
   - **Android** — add an intent filter for scheme `omnipost` in
     `android/app/src/main/AndroidManifest.xml`.
   - **iOS** — add `CFBundleURLTypes` with URL scheme `omnipost` in
     `ios/Runner/Info.plist`.

### Required runtime permissions

`flutter create` generates the manifests; add image/camera/notification
permissions per the `image_picker`, `image_cropper` and
`flutter_local_notifications` plugin docs.

---

## ⏰ A note on scheduling

On-device scheduling fires a **local notification** at the chosen time, and any
posts whose time has passed are published when the app next opens
(`LibraryViewModel.publishDuePosts`, called from the home shell). Truly
unattended posting (app closed) requires either a backend cron that calls the
platform APIs, or `workmanager` / `BGTaskScheduler` with a headless isolate —
the service layer is structured to drop either in.

---

## 🧪 Testing

```bash
flutter test
```

Unit tests cover validation rules and `Post` (de)serialization. Because
ViewModels depend on providers, you can override services with fakes in widget
tests via `ProviderScope(overrides: [...])`.

---

## 🔐 Security

- OAuth tokens are stored in the OS keychain/keystore via `flutter_secure_storage`
  — never in plain preferences and never in the `Post`/`SocialAccount` JSON.
- Secrets should be supplied with `--dart-define` or kept in the git-ignored
  `lib/core/config/api_config.local.dart`. Do not commit real credentials.
