# Security Notes

## What Stays Out Of Git

- Apple team IDs and signing choices
- App Store Connect API keys
- signing certificates and provisioning profiles
- local server credentials used to test the app

## What This Repo Commits Safely

- public bundle identifiers
- entitlements structure
- generated project settings that do not identify a personal account
- non-secret app configuration

## Runtime Secret Storage

User server passwords are stored in Keychain, not `UserDefaults`.

- non-secret recent server metadata lives in `UserDefaults`
- passwords live in Keychain
- the Live Activity extension reads from the shared Keychain group when needed

## Local Development

For local signing, keep personal settings out of the repo.

Recommended places for local-only values:

- Xcode target Signing settings on your machine
- a local ignored XcodeGen override such as `project.local.yml`
- a local ignored xcconfig such as `Signing.local.xcconfig`
- a local ignored fastlane env file such as `fastlane/.env`
- CI secret storage for App Store Connect and signing automation

## Open Source Rule Of Thumb

If a value would let another person:

- sign builds as you
- access App Store Connect
- access private infrastructure
- authenticate to a server

it should not be committed to this repository.
