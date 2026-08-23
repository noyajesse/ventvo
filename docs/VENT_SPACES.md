# Ventvo Vent Spaces

## Purpose

A Vent is an intentional expression that creates a Space for how other Voices can experience and respond to that moment.

The Space is part of the Vent's identity. It is not merely a UI preference or a generic response setting.

## Current Spaces

### Just Listen

Purpose: allow someone to express a moment without asking others to fix it.

Current prototype behavior:

- Feed identifies the Vent as a Listening Space.
- A listener can acknowledge the Vent with `I'm listening`.
- After acknowledgement, the action becomes `Heard` and is disabled.
- No discussion composer is available from a Just Listen Vent.

Production behavior is still future work and will require persistent interaction state.

### Open Discussion

Purpose: give Voices a space for deeper conversation and perspectives.

Current prototype behavior:

- Feed identifies the Vent as an Open Discussion Space.
- Users can enter the dedicated Discussion screen.
- The Discussion screen allows local prototype responses.
- The discussion composer is available only when the Vent is actually an Open Discussion Vent.

Persistent discussions, participant data, Echo Notes, and connection rules remain future work.

## Technical Model

The `Vent` model stores the selected Space using:

- `spaceType`
- `Vent.justListen`
- `Vent.openDiscussion`
- `Vent.isJustListen`
- `Vent.isOpenDiscussion`

Create Vent records the selected Space in `spaceType`.

## Current Flow

```text
Voice
  ↓
Create Vent
  ↓
Choose Space
  ├── Just Listen
  │     ↓
  │   Listening Space
  │     ↓
  │   I'm listening → Heard
  │
  └── Open Discussion
        ↓
      Discussion Space
        ↓
      Join Discussion
        ↓
      Discussion
```

## Product Boundaries

Do not add the following to the current Space implementation unless the roadmap explicitly calls for them:

- Traditional likes
- Follower mechanics
- Advice as a third Space
- Echo Notes implementation
- Resonance Maps
- Backend persistence
- AI matching

These are separate future systems or deliberately rejected directions.
