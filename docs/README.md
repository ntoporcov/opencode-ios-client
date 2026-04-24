# GitHub Pages

This repo includes a simple static site under `docs/` for:

- a marketing homepage
- a public privacy policy page

## Publish

In GitHub:

1. Open repository settings
2. Open `Pages`
3. Set source to `Deploy from a branch`
4. Choose branch `main`
5. Choose folder `/docs`

Once published, the expected GitHub Pages URLs will be:

- homepage: `https://ntoporcov.github.io/openclient/`
- privacy policy: `https://ntoporcov.github.io/openclient/privacy/`

Planned custom domain:

- homepage: `https://open-client.com/`
- privacy policy: `https://open-client.com/privacy/`

## App Store Connect / Fastlane

Suggested values once the custom domain is live:

- `APP_STORE_MARKETING_URL=https://open-client.com/`
- `APP_STORE_PRIVACY_URL=https://open-client.com/privacy/`
- `APP_STORE_SUPPORT_URL=https://github.com/ntoporcov/openclient/issues`
