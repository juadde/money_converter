# Code signing policy

Free code signing provided by [SignPath.io](https://signpath.io), certificate by [SignPath Foundation](https://signpath.org).

This policy applies to the Windows release of Money Converter published on the [GitHub releases](https://github.com/juadde/money_converter/releases) of this repository.

## What is signed

- `moneyconverter.exe`, inside `money-converter-windows-x64.zip`.
- Only binaries built from this public repository by GitHub Actions (workflow [`release.yml`](.github/workflows/release.yml), GitHub-hosted runners) are submitted for signing. SignPath retrieves them directly from the workflow run.
- Third-party binaries shipped with the app (such as the Flutter engine, `flutter_windows.dll`) are not signed with this certificate.
- The Microsoft Store version is signed by Microsoft, not by this certificate.

## Team roles

| Role | Members |
| --- | --- |
| Committers and reviewers | [Julien Addé (@juadde)](https://github.com/juadde) |
| Approvers | [Julien Addé (@juadde)](https://github.com/juadde) |

Every change goes through a pull request merged by the owner. Every release signing request is approved by hand in SignPath. All members use multi-factor authentication on GitHub and SignPath.

## Privacy policy

This program will not transfer any information to other networked systems unless specifically requested by the user or the person installing or operating it, except to download the public exchange rates of the European Central Bank (ecb.europa.eu) and their backup copy (juadde.github.io). See the [privacy policy](https://juadde.github.io/money_converter/privacy.html).
