# Ventvo Vent Spaces

## Purpose

A Vent is an intentional expression that creates a Space for how other Voices can experience and respond to that moment.

The Space is part of the Vent's identity. It is not merely a UI preference or a generic response setting.

## Current Spaces

### Just Listen

Purpose: allow someone to express a moment without asking others to fix it.

Current prototype behavior:

- Feed identifies the expression as belonging to a Just Listen Space.
- A Voice can enter the Space.
- Inside the Space, the Voice can acknowledge the moment with `I'm listening`.
- After acknowledgement, the action becomes `Heard`.
- No discussion composer is available.

Production behavior will eventually require persistent interaction state and backend storage.

### Open Discussion

Purpose: give Voices a Space for deeper conversation and perspectives.

Current prototype behavior:

- Feed identifies the expression as belonging to an Open Discussion Space.
- A Voice can enter the Space.
- The Space provides a discussion experience and local prototype responses.

Persistent discussions, participant data, Echo Notes, and connection rules remain future work.

## Technical Model

A Space is now a real domain object.

The `Space` model contains:

- `id`
- `mode`
- `originatingVentId`
- `creatorVoiceMark`
- `createdAt`

The only supported modes are:

- `SpaceMode.justListen`
- `SpaceMode.openDiscussion`

The `Vent` model stores the relationship through:

- `spaceId`

The interaction mode is owned by `Space`, not duplicated on `Vent`.

This prevents two sources of truth for the same interaction rules.

## Current Flow

```text
Voice
  ↓
Create Vent
  ↓
Choose Space
  ├── Just Listen
  │     ↓
  │   Space
  │     ↓
  │   Enter Space
  │     ↓
  │   I'm listening → Heard
  │
  └── Open Discussion
        ↓
      Space
        ↓
      Enter Space
        ↓
      Discussion
```

## Feed Relationship

The Feed is a discovery layer for expressions and should lead a Voice into the Space that owns the experience.

```text
Vent
 ↓
Space
 ↓
Feed expression
 ↓
Tap / Enter
 ↓
Same Space
```

The current Feed still uses the existing Vent card as its presentation foundation. A later Moments layer can evolve the discovery presentation without changing the underlying Vent → Space relationship.

## Persistence

The current prototype persists Vents and Spaces locally using SharedPreferences.

Supabase persistence remains future work.

## Product Boundaries

Do not add the following to the current Space implementation unless the roadmap explicitly calls for them:

- Traditional likes
- Follower mechanics
- Advice as a third Space
- Echo Notes implementation
- Resonance Maps
- AI matching

These are separate future systems or deliberately rejected directions.
