# Security policy

## Supported versions

Only the latest version is supported: the latest [GitHub release](https://github.com/juadde/money_converter/releases/latest), the web app at https://juadde.github.io/money_converter/ and the current store versions (Google Play, Microsoft Store, Snap Store). Fixes are not backported to older builds.

## Reporting a vulnerability

Please **do not open a public issue** for a security problem.

Report it privately through GitHub: [Security → Report a vulnerability](https://github.com/juadde/money_converter/security/advisories/new). Include what you can of:

- the affected version, platform and file (APK, Windows zip, Linux tar.gz or snap, web app, store build);
- the steps to reproduce, or a proof of concept;
- the impact as you see it.

This is a personal project maintained on free time. You can expect:

- an acknowledgement within 7 days;
- an assessment, and a fix plan if confirmed, within 30 days;
- credit in the advisory and the release notes, unless you prefer not to be named.

Please give a reasonable time to release a fix before disclosing it publicly.

## Scope

In scope:

- the app's code in this repository, on every platform;
- the build and release workflows (`.github/workflows`), including signing and the published files;
- the rates data published on GitHub Pages (`rates.json`).

Out of scope:

- the European Central Bank feed itself, GitHub, the app stores and other third-party services: report to them directly;
- vulnerabilities in dependencies with no impact on this app. Those are tracked automatically (Dependabot and the Security workflow, see the README).

## What the app handles

The app has no accounts, no analytics and no server of its own. It only downloads public exchange rates from the European Central Bank and their backup copy on GitHub Pages, and stores the amounts, the chosen currencies and the language on the device. See the [privacy policy](https://juadde.github.io/money_converter/privacy.html).
