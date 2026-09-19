# Ventvo Domain Model

## Purpose

This document defines the ownership and boundaries of Ventvo's core domain objects.

The current product model is the source of truth. Prototype code and historical idea-stage concepts must not override these decisions.

## Core model

```text
Private Account
      │
      │ owns privately
      ▼
Ventvo Voice
      │
      ├──────────────► Vent
      │                  │
      │                  ▼
      │                Space
      │                  │
      │                  ▼
      │              Resonance
      │
      └──────────────► Crash Out
                           │
                           ▼
                         Fate
                           │
                    Turn into Vent ─────► Vent
```

Resonance is the central human-connection system. It is not a property of Crash Out, Feed, Space, or any single matching experience.

## 1. Private Account

### Owns
- Authentication identity
- Account ID
- Security state
- Authorization state
- Moderation/restriction state
- Private account settings

### Must never own
- Public Voice identity as a substitute for authentication
- Public Vent content as a private-account profile
- Matching logic

The private account is the security boundary and remains separate from the public Voice.

## 2. Ventvo Voice

### Purpose

The Ventvo Voice is the user's anonymous public presence in Ventvo.

### Owns
- Voice ID
- Voice Name
- Voice Mark
- Voice expression/essence
- Voice resonance profile when that concept is finalized

### Does not own
- Authentication credentials
- Email/provider identity
- Moderation records directly
- Matching algorithms
- Individual Vent content

A Voice can create many Vents and participate in many Spaces without becoming a conventional social profile.

## 3. Vent

### Definition

A Vent is an expression intentionally released into Ventvo. It can represent a thought, feeling, experience, idea, opinion, or moment.

### Owns
- Vent ID
- Creator Voice reference
- Content or expression payload
- Creation timestamp
- Publication/visibility state
- Safety/moderation state
- Originating Crash Out reference when converted from Crash Out

### References
- Its creator Voice
- A Space
- Its originating Crash Out when applicable

### Interaction boundary

A Vent does not own a separate response-intent system.

The current Vent experience has exactly two interaction modes:

1. **Just Listen** — the creator wants the experience to be held without opening a discussion.
2. **Open Discussion** — the creator is open to other Voices sharing perspectives around the experience.

The interaction mode belongs to the Space. The Space is the single source of truth for how the experience may be held and interacted with.

### Does not own
- Matching algorithms
- Feed ranking
- Connection state between unrelated people
- Authentication information
- A duplicate interaction-mode source of truth

## 4. Space

### Definition

A Space is the interaction context around an experience. It describes how a Vent may be encountered and responded to.

A Space is a shared experience, not a traditional group, subreddit, profile, or chat room.

### Owns
- Space ID
- Originating Vent reference
- Interaction mode
- Space lifecycle/state
- Participation/response relationships
- Safety constraints for interaction

### Current interaction modes

```text
Space
 │
 ├── Just Listen
 │
 └── Open Discussion
```

No additional response modes are part of the current product model.

### May contain/refer to
- The originating Vent
- Subsequent Vents or responses that belong to the experience
- Resonance connections generated from the experience

### Does not own
- Global matching logic
- User authentication
- Feed ranking
- Voice identity generation

## 5. Crash Out

### Definition

Crash Out is a private-release pathway for expressing something before deciding what, if anything, should happen to it.

### Owns
- Crash Out ID
- Private expression payload
- Creation timestamp
- Lifecycle state
- Release type
- Fate decision

### Possible fate outcomes
- Let Go
- Keep Private
- Turn into Vent
- Future connection/discovery pathways when designed

### Critical boundary

Crash Out must NOT contain Resonance matching logic.

If a Crash Out is eligible to discover people who may understand it, Crash Out asks the Resonance system for that experience. The matching engine remains reusable by Feed, Space, Crash Out, and future systems.

## 6. Resonance

### Definition

Resonance is Ventvo's central human-connection system. It identifies meaningful relationships between experiences, perspectives, Voices, and Spaces.

It is not a like system, popularity score, follower system, or single matching feature.

### Resonance owns
- Resonance signals
- Candidate discovery
- Connection creation
- Connection lifecycle
- Resonance Threads
- Resonance Maps
- Safety/privacy constraints for discovery
- Deterministic scoring and future ranking strategy

### Resonance consumes
- Experience signals
- Interaction mode and other relevant context
- Context
- Privacy/safety constraints
- Diversity constraints

### Resonance produces
- Candidates
- Connections
- Threads
- Maps
- Discovery results

### Connection lifecycle

A discovered relationship does not immediately become an active relationship.

```text
Suggested
   ↓
Accepted
   ↓
Active
```

A connection may instead be closed or blocked from the appropriate states.

- **Suggested** means Resonance found a meaningful possible relationship.
- **Accepted** means the receiving side has acknowledged the connection.
- **Active** means the relationship is open for the shared connection experience.
- **Closed** ends the relationship.
- **Blocked** prevents the relationship for safety/privacy reasons.

The lifecycle is owned by the Resonance connection lifecycle and connection service. UI surfaces request transitions through the service; they do not mutate connection state directly.

The current local prototype can create and display a suggested connection and expose the lifecycle UI boundary, but it cannot yet simulate a real second Voice receiving and accepting a connection because authentication and multi-Voice backend persistence are not implemented.

### Consumers
- Feed
- Space
- Crash Out
- Future Echo systems
- Future Threads and Maps experiences
- Small-group experiences, including three-Voice experiences

A three-Voice experience is a product presentation powered by Resonance. It is not the architecture of Resonance itself.

## 7. Resonance Signal boundary

Signals describe useful characteristics of an experience for connection discovery.

Examples include:
- Semantic relationship
- Shared experience
- Interaction mode
- Context
- Relationship state
- Diversity
- Privacy constraints
- Safety constraints
- Repetition/overexposure signals

Signals are inputs to Resonance. Product surfaces must not independently invent matching algorithms.

## 8. Ownership rules

### Rule 1 — Screens do not own domain logic
Screens collect input and render state. They should not calculate matching, connection scores, or persistence rules.

### Rule 2 — Providers coordinate; services decide
Riverpod providers expose state and coordinate application flows. Domain services contain business rules.

### Rule 3 — Repositories persist; they do not define product behavior
Repositories provide storage contracts. They should not decide what a Vent means or who resonates with whom.

### Rule 4 — Resonance is reusable
Any product surface that needs meaningful human discovery calls Resonance rather than implementing matching locally.

### Rule 4a — Discovery does not end the journey
When a user chooses **This resonates with me**, Resonance creates a suggested connection through the connection service. The connection must then follow the shared lifecycle rather than ending at discovery.

### Rule 4b — Connection is relationship state, not a generic chat shortcut
An active connection should remain grounded in the shared experience that created it. A generic direct-message system must not replace the connection model.

### Rule 5 — Crash Out remains private by default
Nothing in Crash Out should become public or discoverable until the user explicitly chooses a pathway that permits it.

### Rule 6 — Public identity remains Voice-based
Public experiences reference a Ventvo Voice, never the private authentication identity.

### Rule 7 — Safety is cross-cutting
Safety and privacy checks must be enforceable before content becomes discoverable or connections become active.

### Rule 8 — Space owns interaction mode
Vent creation selects a Space mode. Vent does not duplicate that mode as a second source of truth.

## 9. Target dependency direction

```text
UI
 ↓
Riverpod providers
 ↓
Application/domain services
 ↓
Repositories
 ↓
Local storage / backend
```

For Resonance:

```text
Feed / Space / Crash Out / future surfaces
                     ↓
             Resonance service
                     ↓
              Resonance engine
                     ↓
            Resonance repository
                     ↓
             Local / backend data
```

No feature should depend on another feature's private matching implementation.

## 10. Current prototype vs target

The current prototype is allowed to use local storage and simplified models. It must not be mistaken for the final architecture.

Current prototype limitations include:
- Vent and Space use local persistence.
- Crash Out storage is in-memory.
- Authentication is a temporary development flow.
- Feed discovery still contains hard-coded sample content.
- Discussion responses are local widget state.
- Resonance has domain models and deterministic scoring foundations, but real Vent signal generation and production persistence are not yet connected.

These are implementation gaps, not reasons to change the domain boundaries.

## 11. Implementation order

1. Stabilize domain models.
2. Stabilize repository contracts.
3. Complete deterministic Resonance engine and tests.
4. Refactor Space around shared-experience semantics.
5. Formalize Crash Out lifecycle and conversion.
6. Build Vent experience signal generation.
7. Connect Feed, Space, and Crash Out to Resonance.
8. Replace prototype local persistence with secure backend persistence.
9. Add authentication, authorization, moderation, reporting, and privacy enforcement.
10. Add advanced semantic/AI discovery only after the core system is proven.
