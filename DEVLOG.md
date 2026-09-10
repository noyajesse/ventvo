## Resonance Discovery Bridge

Date: 2026-09-10
Branch: development

Completed:
- Added `LocalResonanceRepository` behind the existing `ResonanceRepository` contract.
- Added candidate upsert/removal and connection persistence for the local prototype.
- Added a discovery boundary that excludes candidates carrying privacy or safety signals.
- Added `VentResonanceDiscoveryService` to convert a discoverable Vent plus its Space into a `ResonanceQuery`.
- Kept matching inside the shared Resonance system rather than inside Feed, Space, or Crash Out.
- Added unit coverage for repository filtering/persistence and the Vent-to-Resonance discovery bridge.

Architecture boundary:
- Vent signal generation interprets the experience.
- The discovery service builds the Resonance query.
- The Resonance Engine ranks candidates.
- The repository controls which candidates are available to discovery.
- Private or unsafe content is blocked before it can become a discovery result.
- This remains a local deterministic foundation; backend persistence and semantic/AI matching are deferred.

Verification:
- Source and test files were inspected on the `development` branch.
- Local Flutter execution is still reserved for the upcoming milestone test pass.

Next engineering focus:
- Build the first Resonance provider/application boundary so product features can consume Resonance without constructing engines or repositories directly.
- Then integrate Resonance discovery into Feed and Space.

---

## Resonance Signal Generation Foundation

Date: 2026-09-10
Branch: development

Completed:
- Added `VentResonanceSignalGenerator` under the shared Resonance system.
- Converts a Vent plus its owning Space into deterministic, explainable Resonance signals.
- Added experiential signals such as starting over, loneliness, burnout, overthinking, uncertainty, loss, pressure, rejection, and change.
- Added semantic/context signals for common experience domains and Crash Out-originated Vents.
- Added the current Space interaction mode as an intent signal: `Just Listen` or `Open Discussion`.
- Added privacy and safety signals without mutating the underlying Vent.
- Added unit coverage for experiential/semantic extraction, interaction mode, Crash Out context, and privacy/safety metadata.

Architecture boundary:
- Signal generation lives in Resonance, not Feed, Space, Discussion, or Crash Out.
- The first implementation is deterministic and rule-based; AI/embeddings remain deferred until the core model is proven.
- This generator is designed to be reused by Feed, Space, and Crash Out through the shared Resonance system.

Verification:
- Source and test files were inspected on the `development` branch after creation.
- GitHub tooling does not execute local Flutter commands, so tests are added but are not claimed as locally executed.

Next engineering focus:
- Connect generated Vent signals to the existing Resonance repository/engine boundary.
- Then begin Resonance-powered discovery for Feed and Space.

---

## Current Vent Interaction Model — Correction

Date: 2026-09-10
Branch: development

Important product/architecture correction:
- The current Vent model has exactly two interaction modes: `Just Listen` and `Open Discussion`.
- These modes are owned by `Space`, because Space defines the interaction context and rules.
- `Vent` does not store a second interaction-mode field.
- The previous `VentInteractionMode` wording in this historical section is obsolete implementation documentation and must not be treated as the current model.
- Legacy five-option concepts such as Advice, Similar Experiences, Encouragement, and Celebrating are not part of the current product model.

Current flow:

```text
Vent creation
↓
Choose Space mode
↓
Space owns interaction context
↓
Vent is created inside that Space
↓
Vent → Resonance signal generation
```

Resonance remains the central human-connection system. Matching/discovery logic does not belong inside individual features.

---

## Space Foundation Implementation

Date: 2026-08-25
Branch: development

Completed:
- Added a dedicated `Space` domain model.
- Limited Space modes to `Just Listen` and `Open Discussion`.
- Changed `Vent` to reference a `spaceId` instead of storing the interaction mode itself.
- Added local Space persistence alongside existing Vent persistence.
- Updated Vent creation so a Space is created with the Vent.
- Added the initial Space screen and Spaces screen.
- Added Space and Space Moment presentation widgets.
- Updated Feed expressions to enter their owning Space instead of routing directly to a generic discussion screen.
- Kept Just Listen and Open Discussion behavior distinct inside the Space experience.

Product boundary:
- This establishes the first real Space domain foundation.
- It does not claim that the final visual Space experience is complete.
- Moments, Resonance, Echo Notes, persistent discussions, backend persistence, and connection systems remain future work.
- No additional Space modes were introduced.

Development principle:
- Space owns the interaction mode so Vent and Space do not maintain duplicate sources of truth.

---

## Voice Space Hierarchy Refinement

Date: 2026-08-23

Completed:
- Refined Voice Space into a clearer hierarchy around the user's Voice identity.
- Grouped the experience into Your space, Your Vents, Private, and Express sections.
- Kept Create a Vent, Crash Out, Explore Feed, and Private Crash Outs as existing flows.
- Kept the current in-memory prototype architecture unchanged.

Product boundary:
- This is a presentation and information-hierarchy refinement, not a new social system.
- Resonance, Echo Notes, matching, persistence, and backend infrastructure remain outside this change.
- Existing Just Listen and Open Discussion Space semantics remain unchanged.

Development principle:
- Improve clarity of the existing Core Expression Foundation before introducing new systems.

---

## Product Direction Review - Ventvo Principles

Date: 2026-08-02

Completed:
- Reviewed Ventvo's core purpose and direction.
- Defined Ventvo as a connection system built around human moments, not a traditional social media platform.
- Created VENTVO_PRINCIPLES.md as the product decision filter for future features.

Key decisions:
- Voice remains the foundation instead of traditional profiles.
- Vents represent moments, not normal social posts.
- Connection is measured through Resonance instead of likes or popularity.
- Just Listen and Open Discussion now have different interaction rules.
- Just Listen allows Resonance but does not allow Echo Notes or Discussion.
- Open Discussion allows Resonance, Echo Notes, Discussion, and optional Crash Out.
- Echo Notes are reflections, not comments.
- Crash Out remains a temporary shared emotional space.

Development principle:
- Build only what supports Ventvo's core philosophy and avoid premature complexity.

---

# Ventvo Development Milestone — Crash Out to Vent

Date: 2026-08-22
Branch: development

## Completed

Implemented and verified the **Turn into a Vent** path for Crash Out.

### User Flow

```text
Crash Out
↓
Release
↓
Fate
↓
Turn into a Vent
↓
Edit Vent
↓
Choose Space
↓
Release as Vent
↓
Voice Space
```

### Behavior

- Crash Out content is carried into the Vent composer.
- The user can edit the content before publishing it as a Vent.
- The user must choose a Vent space before releasing.
- The new Vent is created through the existing `ventProvider`.
- The originating Crash Out is marked `convertedToVent`.
- The converted Crash Out does not remain an ordinary private Crash Out.
- The user returns to Voice Space after successful conversion.

## Architecture Decision

Crash Out remains a separate model and lifecycle from Vent.

Conversion is an explicit user decision rather than an automatic transformation.

## Documentation Note

The existing `DEVLOG.md` on `development` contains historical entries plus an older malformed/truncated documentation section. This update preserves the historical record while adding a correction at the top for the current Space-owned interaction model.

## Next Step

Continue with Resonance integration by connecting generated Vent signals to the existing repository/engine boundary. Do not add unrelated features or prematurely implement AI systems.
