# Changelog

All notable changes to Ventvo will be documented here.

---

## Version 0.1.1 - Ventvo Voice Experience

### Added

- New Ventvo Voice onboarding experience.
- Voice Welcome screen.
- Voice Discovery flow.
- Voice Mark selection system.
- Voice Created confirmation screen.
- Authentication connection to Ventvo Voice creation.

### Improved

- Reorganized Flutter feature structure.
- Updated project documentation.
- Improved anonymous identity flow.
---

## Version 0.1.2 - Vent Foundation

### Added

- Added the initial Vent system.
- Added `Vent` model and state management.
- Connected Vent creation to the user's Ventvo Voice.
- Added `spaceType` to define how a Vent should be experienced.
- Added Voice identity information to created Vents.
- Added Feed foundation for displaying Vents.
- Added reusable Vent card structure.
- Connected Voice Space with created Vents and Feed.

### Product Decisions

- A Vent represents an intentional expression brought into Ventvo.
- A Vent creates a Space for people to experience that expression.
- Ventvo does not use traditional likes as the primary measure of connection.
- Resonance is the foundation for meaningful connection between Voices.
- Just Listen and Open Discussion are distinct Spaces with different interaction rules.

### Just Listen

- Added the initial Just Listen prototype.
- Just Listen allows a person to express something without asking others to fix it.
- The current prototype uses a `Heard` interaction.
- Persistent interaction state will be implemented with the backend.

### Open Discussion

- Added the initial Open Discussion prototype.
- Added navigation into a dedicated discussion experience.
- Open Discussion is intended for deeper conversation and different perspectives.
- Persistent discussion and participant data remain future work.

---

## Version 0.1.3 - Crash Out Foundation

### Added

- Added dedicated Crash Out model.
- Added `CrashOutNotifier` and `crashOutProvider`.
- Added Crash Out entry experience.
- Added text-based Crash Out release.
- Added Crash Out fate screen.
- Added private Crash Out storage.
- Added Private Crash Outs screen.
- Connected Crash Out entry to Voice Space.

### Crash Out Flow

```text
Voice Space
↓
Crash Out
↓
Release
↓
Fate
├── Let Go
└── Keep Private
Product Decisions
Crash Out is separate from the Vent system.
A Crash Out is a private release, not a Vent type.
A Crash Out does not appear in the normal Feed unless explicitly converted into a Vent.
Private Crash Outs remain visible only to their owner.
Current Crash Out Outcomes

Implemented:

Let Go
Keep Private

Future:

Turn into a Vent
Find People Who Understand
Voice Crash Out
Backend Direction
Supabase has been selected as the planned backend platform.
PostgreSQL will serve as the primary database.
Supabase Auth will handle authentication.
Supabase Storage will handle user-generated media.
Supabase Realtime will support future real-time interactions.


### One important thing


I **wouldn't add Resonance Maps, Resonance Threads, Echo Notes, or the other future systems as if they're already implemented**.


They belong in the architecture/product documentation as **planned systems**, while the changelog should say only what we've actually built.

## Version 0.1.2 - Crash Out & Vent Foundation Refinement

### Changed

* Simplified the Crash Out status model.
* Removed obsolete `letGo` status.
* Removed obsolete `findingPeople` status.
* Removed the previous `ConnectionNeed` model.
* Kept Crash Out separate from the Vent model.
* Maintained private Crash Out storage through `keptPrivate`.
* Refined the Vent creation experience around the current Ventvo spaces:

  * Just Listen
  * Open Discussion
* Continued connecting Voice identity with Vent creation and Feed display.

### Product Direction

Crash Out remains a separate private-release experience rather than becoming another Vent type.

The current implementation focuses on:

* Releasing a thought privately.
* Choosing to keep the release private.
* Maintaining a clear path toward future Crash Out functionality without prematurely implementing matching or connection infrastructure.

Future systems such as Resonance, Resonance Maps, Echo Notes, and deeper human-connection features will be developed separately when their underlying product and technical behavior is ready.

### `CHANGELOG.md`

And at the bottom:

```markdown
---

## [Unreleased] — Ventvo Voice Foundation

### Added

- Ventvo visual theme foundation
- Centralized Ventvo colors
- Ventvo typography system
- Ventvo spacing system
- Ventvo motion system
- Ventvo Mark component
- Email authentication screen foundation
- Finding Your Voice onboarding experience
- Voice Reveal experience
- `VentvoVoice` model
- `VentvoVoiceProfile`
- `VentvoVoiceSeed`
- Initial Voice foundations:
  - VAELOR
  - NYVEN
  - AUREN
- Voice Marks associated with each foundation
- Initial Voice growth state

### Changed

- Updated authentication choice experience
- Updated Welcome experience
- Refined onboarding visual direction
- Established Voice as an evolving identity rather than a fixed personality category

### Validation

- `flutter analyze` passes with no issues.
