# App Store Prep

## What XcodeGen Controls

These values are part of the app binary or project configuration and belong in `project.yml`.

- installed app name via `CFBundleDisplayName`
- bundle identifier via `PRODUCT_BUNDLE_IDENTIFIER`
- version/build via `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`
- app icon asset selection via `ASSETCATALOG_COMPILER_APPICON_NAME`
- URL schemes via `CFBundleURLTypes`
- entitlements and capabilities
- Info.plist keys such as ATS settings and usage descriptions

For this project today:

- installed app name: `OpenClient`
- iOS bundle ID: `com.ntoporcov.openclient`
- Live Activity bundle ID: `com.ntoporcov.openclient.liveactivity`
- iOS app icon asset name: `AppIcon`

## What App Store Connect Controls

These values are not driven by XcodeGen unless you automate them with fastlane `deliver` or the App Store Connect API.

- App Store app name
- subtitle
- promotional text
- description
- keywords
- support URL
- marketing URL
- privacy policy URL
- screenshots
- app preview videos
- age rating
- App Privacy answers
- review notes
- export compliance answers

Important distinction:

- `CFBundleDisplayName` controls the name shown on the device home screen.
- App Store app name and subtitle are edited in App Store Connect.

They usually match, but they do not have to.

## OpenClient Metadata Checklist

### Binary / Project

- [x] Installed app name is `OpenClient`
- [x] Bundle ID is set
- [x] URL scheme is set to `openclient://`
- [x] App icon asset is wired in the project
- [ ] Final 1024x1024 App Store icon artwork is in place
- [ ] Versioning strategy is decided for TestFlight and release
- [ ] ATS approach is finalized for submission

### App Store Connect Listing

- [ ] Reserve the app record using bundle ID `com.ntoporcov.openclient`
- [ ] Decide final App Store app name
- [ ] Write subtitle
- [ ] Write description
- [ ] Choose keywords
- [ ] Add support URL
- [ ] Add privacy policy URL
- [ ] Optionally add marketing URL

### Screenshots

- [ ] iPhone screenshots for the required display sizes
- [ ] Decide whether to show setup flow, chat flow, permissions, and live activity
- [ ] Keep screenshots consistent with the `OpenClient` name and current UI

Recommended screenshot set:

- connection/setup screen
- session list
- active chat
- permission or question UI
- live activity

Because OpenClient currently supports iPad as well as iPhone, plan on keeping an iPad screenshot set too.

Current automated capture devices:

- `iPhone 17 Pro`
- `iPhone 17 Pro Max`
- `iPad Pro 13-inch (M5)`

### Privacy / Review

- [ ] Draft privacy policy
- [ ] Answer App Privacy questions in App Store Connect
- [ ] Decide whether analytics/crash reporting are present
- [ ] Write reviewer notes explaining the self-hosted server model
- [ ] Provide reviewer access instructions or a review server if needed
- [ ] Answer export compliance questions
- [ ] Set age rating

## Fastlane Relationship

Current fastlane setup can:

- build
- archive
- upload to TestFlight
- upload a build to App Store Connect
- run `precheck`

Current fastlane setup now supports in-repo listing metadata via:

- `fastlane/metadata/`
- `fastlane ios metadata`
- `fastlane ios download_metadata`

Screenshots can also be uploaded by fastlane `deliver`, but capturing them automatically usually needs a separate `snapshot` setup and stable screenshot-driving UI tests.

This repo now includes an initial screenshot scaffold:

- `fastlane ios screenshots`
- `OpenCodeIOSClientUITests.testAppStoreScreenshots()`
- seeded screenshot scenes launched with `OPENCLIENT_SCREENSHOT_SCENE`

The current lane runs deterministic UI-test capture directly rather than relying on `fastlane snapshot`'s helper flow.

It is a starting point, not a final polished store-shot pipeline.

## Recommendation

Recommended next step:

1. Keep binary identity in XcodeGen
2. Edit listing copy in `fastlane/metadata/en-US/`
3. Use `fastlane ios metadata` to sync it
4. Refine `fastlane ios screenshots` once the UI and capture scenes are final

Current planned public URLs:

- marketing site: `https://open-client.com/`
- privacy policy: `https://open-client.com/privacy/`
- support: `https://github.com/ntoporcov/openclient/issues`

For the actual operational release sequence, see `RELEASE_RUNBOOK.md`.
