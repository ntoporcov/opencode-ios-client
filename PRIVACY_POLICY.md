# Privacy Policy

Last updated: April 24, 2026

## Overview

OpenClient is a native client for connecting to a user-selected OpenCode server.

This app is designed for self-hosted use. OpenClient does not provide its own hosted AI service. Instead, it connects to the server you configure.

## Information We Process

OpenClient may process the following categories of information in order to work:

- server connection details you enter, such as server URL and username
- your server password
- chat messages, prompts, replies, and session content received from your OpenCode server
- project, session, todo, permission, and question data returned by your OpenCode server
- local app settings such as recent servers and workspace preferences

## How Information Is Stored On Device

OpenClient stores some information locally on your device.

- server passwords are stored in the system Keychain
- non-sensitive recent server metadata, such as server URL and username, may be stored in local app storage
- local UI state and preferences may also be stored on device

OpenClient does not intentionally store your server password in plain text in standard app preferences.

## How Information Is Sent Over the Network

OpenClient sends data to the OpenCode server that you configure.

That can include:

- credentials needed to authenticate with your server
- chat prompts and replies
- session, project, todo, permission, and question actions
- related request data needed to operate the app

Because OpenClient connects to servers chosen by the user, network security depends in part on how that server is configured.

- `https://` connections provide transport protection through HTTPS/TLS
- `http://` connections do not use HTTPS/TLS, even if you are connecting through a private or encrypted network such as Tailscale

OpenClient warns before establishing an insecure `http://` connection entered manually.

## Self-Hosted Server Responsibility

Your OpenCode server is operated separately from OpenClient.

In other words: OpenClient is the remote control, but your OpenCode server is still the thing doing the work.

That means the server side is where things like these are decided:

- server-side logging
- server-side data retention
- access controls
- infrastructure security
- any third-party AI or tool integrations configured on that server

If you connect OpenClient to a server run by someone else, they may be able to see whatever you send through it. Choose your server like you would choose who gets the keys to your workshop.

## Analytics And Tracking

OpenClient does not currently include third-party analytics or advertising SDKs in this codebase.

OpenClient is not designed to track you across apps or websites.

If this changes in a future release, this policy should be updated before release.

## Crash And Diagnostic Information

This codebase does not currently include a third-party crash reporting service.

The app may show local debug information inside the app for development and troubleshooting. That information remains part of the app experience unless you choose to share it yourself.

## Live Activities

If you enable Live Activities, OpenClient may display limited session-related status and action prompts on the Lock Screen or Dynamic Island.

This content may be visible to anyone who can see your device screen while it is displayed.

## Data Retention

Data retained by OpenClient depends on your usage.

- saved connection metadata may remain on device until you remove it
- server passwords stored in Keychain remain until deleted by the app or removed with the app/account data
- chat and session data displayed in the app may also be reloaded from your configured OpenCode server

Data stored or retained by your OpenCode server is controlled by that server, not by OpenClient.

## Your Choices

You can:

- choose which server OpenClient connects to
- remove saved recent servers in the app
- choose whether to use insecure `http://` connections
- uninstall the app to remove app data stored with the installation

## Children’s Privacy

OpenClient is intended for general developer and productivity use and is not specifically directed to children.

## Changes To This Policy

This privacy policy may be updated over time to reflect product or infrastructure changes.

When material changes are made, the updated version should be published before or with the relevant release.

## Contact

For support, bug reports, or privacy questions, you can use either of these:

- GitHub issues: https://github.com/ntoporcov/openclient/issues
- Email: ntoporcov@me.com
