# Release Runbook

## Goal

This runbook covers the first real deployment flow for OpenClient:

1. create the App Store Connect app record
2. configure local fastlane credentials on this machine
3. upload metadata and screenshots
4. ship a first TestFlight build

## Current State

Already in place:

- fastlane build/archive/TestFlight/App Store lanes
- in-repo App Store metadata under `fastlane/metadata/`
- deterministic screenshot generation under `fastlane/screenshots/`
- privacy policy draft in `PRIVACY_POLICY.md`
- GitHub Pages site scaffold under `docs/`

Still manual in App Store Connect:

- creating the app record
- App Privacy answers
- export compliance answers
- age rating
- reviewer notes

## One-Time App Store Connect Setup

In App Store Connect:

1. Create the app record
2. Platform: iOS
3. Name: `OpenClient`
4. Primary language: English (U.S.)
5. Bundle ID: `com.ntoporcov.openclient`
6. SKU: choose a stable internal value, for example `openclient-ios`

After that, create an App Store Connect API key with access sufficient for builds and metadata.

## Local Machine Setup

Copy the fastlane env template:

```bash
cp fastlane/.env.default fastlane/.env
```

Fill at least:

```bash
APP_STORE_CONNECT_API_KEY_ID=...
APP_STORE_CONNECT_ISSUER_ID=...
APP_STORE_CONNECT_API_KEY_PATH=/absolute/path/to/AuthKey_XXXX.p8
```

Current URL defaults are already set to:

```bash
APP_STORE_SUPPORT_URL=https://github.com/ntoporcov/openclient/issues
APP_STORE_MARKETING_URL=https://open-client.com/
APP_STORE_PRIVACY_URL=https://open-client.com/privacy/
```

## Metadata And Screenshot Prep

Review/edit listing text in:

- `fastlane/metadata/en-US/name.txt`
- `fastlane/metadata/en-US/subtitle.txt`
- `fastlane/metadata/en-US/description.txt`
- `fastlane/metadata/en-US/keywords.txt`
- `fastlane/metadata/en-US/promotional_text.txt`
- `fastlane/metadata/en-US/release_notes.txt`

Refresh screenshots when needed:

```bash
fastlane ios screenshots
```

Generated screenshots land in:

```bash
fastlane/screenshots/en_US/
```

Current device coverage:

- iPhone 17 Pro
- iPhone 17 Pro Max
- iPad Pro 13-inch (M5)

## First Metadata Push

Before pushing the first build, push metadata and screenshots:

```bash
fastlane ios metadata
```

Use this if you want to push metadata without screenshots:

```bash
FASTLANE_SKIP_SCREENSHOTS=1 fastlane ios metadata
```

## First TestFlight Upload

Upload the first build:

```bash
fastlane ios beta
```

That will:

1. regenerate the Xcode project
2. build a Release archive
3. upload the build to TestFlight

## After The First Upload

In App Store Connect, finish the remaining manual items:

### App Privacy

Expected current stance to verify manually:

- no third-party advertising SDKs
- no third-party analytics SDKs
- no third-party crash reporting SDKs

Important nuance:

OpenClient connects to a user-configured OpenCode server, but this does not automatically mean OpenClient itself is collecting analytics for the developer. Answer these questions carefully against Apple's definitions at submission time.

### Export Compliance

OpenClient uses standard networking and HTTPS capabilities. Answer export compliance questions in App Store Connect based on Apple's current prompts.

Do not guess from this document if the wording in App Store Connect changes.

### Age Rating

Set the age rating in App Store Connect. This is still manual.

### Reviewer Notes

Reviewer notes should explain:

- OpenClient connects to a self-hosted OpenCode server
- the app can connect to either HTTPS or user-acknowledged HTTP servers
- if reviewer access requires a server, provide instructions or a review server

Suggested note starter:

```text
OpenClient is a native iPhone client for connecting to a self-hosted OpenCode server. The app does not create hosted accounts and requires a configured OpenCode backend to be fully functional. If needed for review, use the provided review server credentials/instructions below.
```

## Recommended First Public Sequence

1. enable GitHub Pages and verify `https://open-client.com/`
2. verify `https://open-client.com/privacy/`
3. fill `fastlane/.env`
4. run `fastlane ios metadata`
5. run `fastlane ios beta`
6. verify TestFlight install and basic login flow
7. complete App Store Connect privacy/compliance/reviewer fields

## Nice-To-Haves Before Submission

- final 1024x1024 App Store icon artwork review
- final curated screenshot subset selection per device family
- decide whether to keep Apple-only crash visibility or add Sentry later
- tighten ATS later if product constraints allow it
