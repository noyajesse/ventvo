## Unreleased - Crash Out Opposition Architecture

### Product

- Reframed Crash Out from a collection of selectable outcomes into a private experience that may surface a meaningful opposing experience.
- Separated Crash Out from Find People Who Understand.
- Defined Crash Out as opposition on a shared human tension rather than similarity, topic difference, or literal antonyms.
- Defined Experience Representation around Situation, Human Tension, Position, Direction, Need/Desire, Emotional State, Context, and Intensity.
- Established that Human Tension + Position + Direction are the primary Crash Out signals.
- Established that Crash Out may contain multiple experience atoms.
- Established that Ventvo must not manufacture an opposite when no meaningful match exists.
- Defined the encounter as the relationship between experiences rather than an algorithmic match result.
- Established that people are not described as “opposites”; experiences are.

### Privacy

- Private Crash Out content must not be published or indexed merely to enable opposition discovery.
- Delayed encounters require an explicit privacy-safe retention design.
- Deleting a Crash Out must remove any matching representation created for delayed discovery.

### Architecture

- Established a dedicated Crash Out opposition domain separate from Resonance similarity discovery.
- Kept the existing CrashOutOppositeExperienceService as deterministic prototype scaffolding.
- Defined the target architecture: CrashOutExperienceInterpreter → ExperienceRepresentation → CrashOutOppositionEngine → Candidate Eligibility → CrashOutEncounter.
- Find People Who Understand remains the similarity/understanding pathway.
- Shared safety, privacy, moderation, and repository infrastructure may be reused without making Crash Out a Resonance similarity flow.

### UX

- Crash Out encounter language should describe the human relationship between the two experiences.
- The encounter should not expose scores or call another person “your opposite”.
- No automatic social-media actions are part of the core encounter.

---

# Changelog

All notable changes to Ventvo will be documented here.

---

## Unreleased - Resonance Connection Lifecycle

### Added

- Added the `ResonanceConnectionLifecycle` finite-state policy.
- Added controlled Resonance connection states: `suggested`, `accepted`, `active`, `closed`, and `blocked`.
- Added `updateConnection()` to the Resonance repository and engine contracts.
- Added local persistence/update behavior for Resonance connections.
- Added lifecycle orchestration through `ResonanceConnectionService`.
- Added automated coverage for valid and invalid lifecycle transitions.

### Architecture

```text
UI
 ↓
Riverpod
 ↓
ResonanceConnectionService
 ↓
ResonanceEngine
 ↓
ResonanceRepository
 ↓
Local / Backend implementation
```

Connection state is now controlled by the Resonance domain rather than directly by UI code.

### Current Connection Lifecycle

```text
SUGGESTED
   ├── ACCEPTED
   ├── CLOSED
   └── BLOCKED

ACCEPTED
   ├── ACTIVE
   ├── CLOSED
   └── BLOCKED

ACTIVE
   ├── CLOSED
   └── BLOCKED

CLOSED  → terminal
BLOCKED → terminal
```

### Validation

- `flutter analyze` passes with no issues.
- `flutter test` passes all tests.

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
- Added the initial Feed foundation.
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
```

### Product Decisions

Crash Out is separate from the Vent system.
A Crash Out is a private release, not a Vent type.
A Crash Out does not appear in the normal Feed unless explicitly converted into a Vent.
Private Crash Outs remain visible only to their owner.

### Current Crash Out Outcomes

Implemented:

- Let Go
- Keep Private

Future:

- Turn into a Vent
- Find People Who Understand
- Voice Crash Out

### Backend Direction

Supabase has been selected as the planned backend platform.
PostgreSQL will serve as the primary database.
Supabase Auth will handle authentication.
Supabase Storage will handle user-generated media.
Supabase Realtime will support future real-time interactions.

---

## Version 0.1.4 - Space Foundation

### Added

- Added a dedicated `Space` domain model.
- Added `SpaceMode` with only `Just Listen` and `Open Discussion`.
- Added local Space persistence.
- Added initial Space and Spaces screens.
- Added Space card and Space Moment card foundations.

### Changed

- Vent now stores `spaceId` rather than duplicating the Space interaction mode.
- Vent creation now creates a Space alongside the Vent.
- Feed expressions now enter their owning Space.
- Just Listen and Open Discussion behavior is resolved from the Space model.

### Product Boundary

This is the first Space domain foundation, not the final Space experience.

Moments, Resonance, Echo Notes, persistent discussions, Supabase persistence, and connection systems remain future work.

No additional Space modes were introduced.

---

## Unreleased - Ventvo Voice Foundation

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
