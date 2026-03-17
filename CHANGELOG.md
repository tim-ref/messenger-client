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


## [1.30.0]

### Added
- Allow creating public rooms without encryption. 
- Option to leave and forget room in one step.
- Public rooms are now created with `m.federate = false` to prevent federation (A_25325-01).
- Icon for public rooms (A_25562-01)
- Enable replace with empty String (A_25577-01 -- Section 2)
- Added support for room type de.gematik.tim.roomtype.default.v2 (A_28595)
- Warning before applying redactions that action cannot be undone and that redaction is applied for all users in room.
- Redaction only available for events younger than 24h (A_25575-01)
- Redacting messages now correctly redacts correlating message-edit events as well. (A_28355)

## [1.29.0]

### Added

- Introduce experimental feature MSC3814 - Dehydrated Devices
- Always show bootstrap dialog for recovery key.


### Fixed

- Room name and topic are properly set when creating a room, and omitted if the room has no
  name/topic.

## [1.28.2]

### Fixed

- Fixed a bug, where users of Homeservers only supporting Matrix Version 1.11 could not log in.

## [1.28.1]

### Added

- This change log.

### Changed

- Replaced one – of two – own FHIR model implementation with a library.

### Fixed

- Always use authenticated media endpoints when supported by server (A_26262).
- Disabled presence updates on sync.

## [1.28.0]

### Added

- Management of FHIR HealthcareService Endpoints.

## [1.27.0]

### Added

- Hiding of FHIR HealthcareService Endpoints owned by Practitioners (AF_10376).
- Show informational text when user invites other users to a chat room (A_26347).

### Changed

- Minor layout and style changes.
- Use only authenticated routes for user profile requests (A_26289).
- Changed room history visibility to "invited" (A_25481).

## [1.26.1]

### Fixed

- Reverted a changed related to refresh tokens.

## [1.26.0]

### Changed

- Announce support for refresh tokens when using `/register` and `/login` (A_25394).
- Hide old blacklist/whitelist in TI-Messenger Pro mode.

### Fixed

- Include m.mentions field in event when sending message.
- Added support for hkdf-hmac-sha256.v2.
- Presence no longer updates when deactivated (A_25436).

## [1.25.0]

### Fixed

- Timestamps in contact approval setting.
- Contact management.

## [1.24.0]

## [1.23.0]

## [1.22.0]

## [1.21.1]

## [1.21.0]

## [1.20.0]

## [1.19.0]

## [1.18.0]

## [1.17.0]

## [1.16.0] (published on 2024-01-31)
