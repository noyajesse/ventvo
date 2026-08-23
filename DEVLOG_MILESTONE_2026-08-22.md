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
