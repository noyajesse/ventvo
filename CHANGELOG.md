## Unreleased — Crash Out ownership and lifecycle foundation

### Added
- Added an owner Voice ID to newly created private Crash Outs.
- Added the `spaceEntered` lifecycle state to record entry into the wider tension Space.
- Kept the original Crash Out private after entering a Space; the lifecycle marker does not imply a public copy or a confirmed opposite match.
- Kept legacy local Crash Outs without an owner Voice ID readable.

### Improved
- Private Crash Out listing now includes both newly kept-private and Space-entered entries.
- Crash Out provider mutations wait for initial local storage loading before changing the collection.
- Let Go continues to delete the original Crash Out; no public experience is created from it.

### Boundaries
- Voice ownership is local prototype metadata, not authentication or server-side authorization.
- No backend, database, API, authentication, or realtime infrastructure was added.

undefined