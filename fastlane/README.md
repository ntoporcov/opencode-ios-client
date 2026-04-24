fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build

```sh
[bundle exec] fastlane ios build
```

Run a simulator build sanity check

### ios archive

```sh
[bundle exec] fastlane ios archive
```

Build a release archive for device distribution

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Upload the current build to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Submit the current build to App Store Connect

### ios metadata_check

```sh
[bundle exec] fastlane ios metadata_check
```

Validate App Store metadata configuration

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Upload App Store metadata without uploading a binary

### ios download_metadata

```sh
[bundle exec] fastlane ios download_metadata
```

Download current App Store metadata into the repo

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Capture App Store screenshots with deterministic UI tests

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
