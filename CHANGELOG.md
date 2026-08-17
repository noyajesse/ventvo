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
