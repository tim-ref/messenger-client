# Changelog

All notable changes to this project will be documented in this file.

**Related change logs**:

- [messenger-client](https://github.com/tim-ref/messenger-client/blob/main/CHANGELOG.md)
- [messenger-org-admin](https://github.com/tim-ref/messenger-org-admin/blob/main/CHANGELOG.md)
- [messenger-proxy](https://github.com/tim-ref/messenger-proxy/blob/main/CHANGELOG.md)
- [messenger-push](https://github.com/tim-ref/messenger-push/blob/main/CHANGELOG.md)
- [messenger-rawdata-master](https://github.com/tim-ref/messenger-rawdata-master/blob/main/CHANGELOG.md)
- [messenger-registration-service](https://github.com/tim-ref/messenger-registration-service/blob/main/CHANGELOG.md)

<!--
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
-->

## [1.28.2] (published on 2025-07-21)

### Fixed

- Fixed a bug, where users of Homeservers only supporting Matrix Version 1.11 could not log in.

## [1.28.1] (published on 2025-04-09)

### Added

- This change log.

### Changed

- Replaced one – of two – own FHIR model implementation with a library.

### Fixed

- Always use authenticated media endpoints when supported by server (A_26262).
- Disabled presence updates on sync.

## [1.28.0] (published on 2025-03-17)

### Added

- Management of FHIR HealthcareService Endpoints.

## [1.27.0] (published on 2025-03-11)

### Added

- Hiding of FHIR HealthcareService Endpoints owned by Practitioners (AF_10376).
- Show informational text when user invites other users to a chat room (A_26347).

### Changed

- Minor layout and style changes.
- Use only authenticated routes for user profile requests (A_26289).
- Changed room history visibility to "invited" (A_25481).

## [1.26.1] (published on 2025-02-27)

### Fixed

- Reverted a changed related to refresh tokens.

## [1.26.0] (published on 2025-02-18)

### Changed

- Announce support for refresh tokens when using `/register` and `/login` (A_25394).
- Hide old blacklist/whitelist in TI-Messenger Pro mode.

### Fixed

- Include m.mentions field in event when sending message.
- Added support for hkdf-hmac-sha256.v2.
- Presence no longer updates when deactivated (A_25436).

## [1.25.0] (published on 2025-02-11)

### Fixed

- Timestamps in contact approval setting.
- Contact management.

## [1.24.0] (published on 2025-01-09)

## [1.23.0] (published on 2024-11-18)

## [1.22.0] (published on 2024-09-19)

## [1.21.1] (published on 2024-07-18)

## [1.21.0] (published on 2024-07-04)

## [1.20.0] (published on 2024-05-27)

## [1.19.0] (published on 2024-04-15)

## [1.18.0] (published on 2024-03-13)

## [1.17.0] (published on 2024-02-21)

## [1.16.0] (published on 2024-01-31)
