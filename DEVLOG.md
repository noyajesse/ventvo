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

The existing `DEVLOG.md` on `development` contains historical entries plus an older malformed/truncated documentation section. It was intentionally not rewritten during this milestone because replacing the entire file without a complete current copy could destroy historical development records.

This milestone file preserves the current decision and implementation record safely.

## Next Step

Continue with the next roadmap item after reviewing the current `development` implementation. Do not add unrelated features or prematurely implement future matching/AI systems.
