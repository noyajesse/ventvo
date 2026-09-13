# Ventvo Resonance Thread Formation

## Status

Implemented and verified foundation.

Branch: `development`

## Purpose

A Resonance Thread should represent a relationship between experiences that is meaningful enough to persist. Thread formation therefore must not happen simply because two experiences are similar.

The formation system now applies an explicit policy before creating a new Thread.

## Formation Flow

```text
Experience
    ↓
Resonance Connections
    ↓
Formation Policy
    ↓
Enough meaningful evidence?
    ├── NO → no Thread
    └── YES
          ↓
Strongest distinct connections
          ↓
Thread Service
          ↓
Persist Resonance Thread
```

## Formation Requirements

A new Thread requires:

- a valid originating experience
- at least two distinct counterpart experiences
- accepted or active connections
- connection strength of at least `0.6`
- at least one meaningful connection type: `sharedExperience`, `response`, or `perspective`
- sufficient combined Resonance strength
- no privacy restriction
- no safety restriction
- no closed or blocked evidence
- no similarity-only formation

The current policy thresholds are:

```text
Minimum meaningful connections: 2
Minimum connection strength:    0.6
Minimum combined score:         1.2
```

## Existing Thread Behavior

When a suitable existing Thread is found, the formation service reuses it and extends it through the strongest eligible connection rather than creating a parallel Thread.

This keeps Thread growth connected to the existing Resonance graph.

## Deterministic Evidence Selection

When a new Thread is approved, the formation service selects the strongest eligible connections deterministically and requires distinct counterpart experiences.

This gives the local implementation predictable behavior and makes the business rule straightforward to test before introducing production semantic or AI discovery.

## Privacy and Safety

Privacy and safety restrictions are formation vetoes.

A private or safety-restricted experience must not silently become part of a persistent Resonance Thread through the formation system.

Crash Out remains separate: its matching pathway will be explicitly opt-in and will use the shared Resonance system rather than implementing its own matching logic.

## Idempotency

Formation accepts a stable Thread identifier. The Thread service checks for an existing Thread before persisting a new one.

Repeated formation attempts therefore do not create duplicate Threads for the same formation event.

## Architecture

```text
Feature / UI
     ↓
Riverpod
     ↓
ResonanceThreadFormationService
     ↓
ResonanceThreadFormationPolicy
     ↓
ResonanceThreadService
     ↓
ResonanceRepository
```

The important boundary is that Feed, Space, and Crash Out do **not** own Thread formation or matching logic.

Resonance remains the central connection system.

## CS Concepts Demonstrated

### Domain rules

The formation policy represents a business rule independently from the UI.

### Separation of concerns

The policy decides whether formation is justified, the formation service orchestrates the workflow, and the Thread service owns persistence and formation-safe validation.

### Finite-state/domain integrity

Only valid connection states can contribute to formation.

### Deterministic algorithms

The same input evidence produces predictable selection and formation behavior, making the system easier to test and reason about.

### Idempotency

Repeating the same formation operation does not create duplicate domain objects.

## Verification

After implementation and the nullable-type fix:

- `flutter analyze` passed with no issues.
- `flutter test` passed all tests.

Coverage includes:

- approved formation
- weak evidence rejection
- blocked/closed connection rejection
- privacy/safety vetoes
- multiple Voice Marks
- repeated formation/idempotency
- existing Thread extension
- formation-safe Thread creation

## Current Boundary

This milestone establishes the business rules for when a Resonance Thread deserves to exist.

It does **not** yet implement:

- production backend persistence
- production-scale discovery
- embeddings/vector search
- AI-assisted matching
- full Resonance Maps
- complete Thread UI
- Crash Out's future Find People Who Understand pathway

Those remain later layers built on this foundation.