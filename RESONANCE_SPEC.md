# Ventvo Resonance System Specification v1.1

## Status

Implemented foundation under active development.

This document defines the technical/product specification for Ventvo's Resonance system. It is implementation-oriented while leaving room for later refinement of discovery algorithms and user experience.

---

# 1. Purpose

Resonance is Ventvo's central human-connection system.

It is not a like, popularity score, follower system, or single matching feature.

Resonance provides the shared infrastructure through which Ventvo can recognize meaningful relationships between experiences, Voices, Vents, Spaces, and future connection experiences.

The central question is:

> What meaningful connection exists between these experiences or people?

Resonance powers multiple experiences rather than living inside one screen.

---

# 2. Core Architecture

```text
                         RESONANCE
                  Human connection layer
                            |
                 +----------+----------+
                 |          |          |
              Signals    Engine     Safety
                 |          |          |
                 +----------+----------+
                            |
                 Resonance Connections
                            |
          +-----------------+-----------------+
          |                 |                 |
       Threads            Maps          Discovery
          |                 |                 |
          +-----------------+-----------------+
                            |
              Product experiences
       +----------+----------+----------+
       |          |          |          |
      Feed      Space    Crash Out    Future
```

Resonance is therefore a system layer, not a feature screen.

---

# 3. What Resonance Connects

Resonance may operate across several Ventvo objects:

- Vent
- Crash Out experience, only when the user explicitly chooses a connection pathway
- Voice
- Space
- Moment
- Echo
- Echo Note
- Resonance Thread

The system must not automatically expose private information simply because it was used internally for discovery.

---

# 4. Experience as the Primary Input

The primary input to Resonance is an experience, not a user profile.

An experience may contain signals such as:

- expression content
- creator intent
- Space mode
- themes or concepts
- situation/context
- emotional context when voluntarily expressed
- desired interaction
- time/contextual information where appropriate
- existing relationship/context
- safety classification

These signals are internal system data. They are not automatically displayed to other users.

The system should avoid reducing a person to a permanent label.

---

# 5. Resonance Signals

Resonance Signals are structured clues used to determine whether two experiences may meaningfully connect.

Initial signal families:

### 5.1 Semantic Similarity

Do the experiences discuss related concepts, situations, or ideas?

### 5.2 Experiential Similarity

Do the experiences describe a similar lived experience or circumstance?

### 5.3 Intent Compatibility

Does the creator's requested interaction align with the potential response?

The current Vent model has only two Space modes:

- `Just Listen`
- `Open Discussion`

These modes are represented as Resonance intent/context signals. Resonance must respect the creator's selected Space mode rather than inventing additional response modes.

### 5.4 Context Compatibility

Are the experiences related in context rather than merely sharing a few words?

### 5.5 Relationship History

Has this Voice previously encountered or connected with this experience?

This must be used carefully so that Ventvo does not create repetitive or closed loops.

### 5.6 Negative Signals

The engine must also recognize reasons not to connect two experiences.

Examples:

- privacy restrictions
- blocked Voice
- reported content
- moderation restrictions
- incompatible Space rules
- unsafe or sensitive content boundaries
- excessive repetition
- already-seen candidates where variety is preferable

---

# 6. Resonance Engine

The Resonance Engine is the reusable service responsible for turning experiences and signals into possible connections.

Conceptually:

```text
Experience
    |
    v
Signal extraction
    |
    v
Candidate discovery
    |
    v
Candidate filtering
    |
    v
Resonance scoring
    |
    v
Safety/privacy filtering
    |
    v
Ranked candidates
    |
    v
Product experience
```

The engine must not be embedded inside Feed, Space, or Crash Out.

Those features consume the engine through a shared interface.

The current local engine is deterministic and testable. Production semantic/AI discovery remains future infrastructure.

---

# 7. Candidate Discovery

Candidate discovery finds potentially relevant experiences before ranking them.

The first implementation uses deterministic/local rules so that the architecture can be tested without requiring an AI model or production-scale infrastructure.

Possible future candidate sources include:

- semantic search
- database indexes
- embeddings/vector search
- recent relevant experiences
- Space relationships
- existing Resonance Threads
- user-controlled discovery preferences

AI/ML is optional infrastructure, not the definition of Resonance.

---

# 8. Candidate Ranking

Candidates should be ranked using multiple signals rather than a single similarity score.

Conceptually:

```text
Resonance Score =
  positive relevance
  + experiential connection
  + intent compatibility
  + context compatibility
  + diversity
  - safety risk
  - privacy restrictions
  - repetition
  - unwanted interaction
```

The exact weighting will be determined experimentally.

The ranking system must remain explainable enough for engineering and safety review.

---

# 9. Resonance Connection

A Resonance Connection represents a meaningful relationship discovered or created between experiences/Voices.

It is not automatically a friendship, follow, or permanent relationship.

A connection contains:

- source experience/Voice identifier
- related experience/Voice identifier
- connection type
- relevance strength
- lifecycle state
- creation time

Current connection types are:

- `sharedExperience` — meaningful overlap in lived experience
- `perspective` — related experience with compatible but potentially different intent/perspective
- `similarity` — broader meaningful overlap when a more specific type cannot be inferred
- `response` — a future response-based relationship
- `discovery` — a future discovery relationship

The current implementation creates connections in the `suggested` state and manages their lifecycle through `ResonanceConnectionService`.

---

# 10. Resonance Connection Lifecycle

Connections are modeled as a finite state machine rather than allowing arbitrary state changes from the UI.

Current states:

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

Meaning:

- `suggested` — Resonance identified a meaningful possible relationship.
- `accepted` — the connection has been acknowledged/opened for further use.
- `active` — the connection is participating in an ongoing Resonance relationship such as a future Thread, Map, or connection experience.
- `closed` — the relationship has ended and should not continue normally.
- `blocked` — the relationship is prevented for safety/privacy reasons and is terminal.

The lifecycle is controlled by `ResonanceConnectionLifecycle` and orchestrated by `ResonanceConnectionService`.

UI code must not directly mutate connection state.

The intended flow is:

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
```

Invalid transitions are rejected by the lifecycle policy.

This is a finite state machine and is intentionally explicit so future Thread, Map, safety, and backend implementations can reuse the same connection semantics.

---

# 11. Resonance Threads

A Resonance Thread is a developing chain of related experiences connected through Resonance.

```text
Experience A
     |
  Resonance
     |
Experience B
     |
  Resonance
     |
Experience C
```

A Thread is not a conventional comment thread.

It exists to preserve the relationship between experiences as the connection develops.

A Thread may eventually contain:

- originating experience
- related experiences
- participating Voices
- connection relationships
- Thread state
- safety/moderation state
- timestamps

Threads should be created only when the relationship is meaningful enough to justify persistence.

The existing `ResonanceThread` model is a domain foundation; full Thread behavior is future work.

---

# 12. Resonance Maps

A Resonance Map represents the broader pattern of relationships discovered through Resonance.

```text
                 Experience A
                    /     \
                   /       \
            Experience B  Voice C
                  |          |
                  +----+-----+
                       |
                  Experience D
```

Maps are not required for the first Resonance implementation.

They will consume established Resonance relationships rather than implementing a separate matching system.

The existing `ResonanceMap` model is a domain foundation; full Map behavior is future work.

---

# 13. Feed Integration

The Feed is a discovery surface powered by Resonance.

The Feed must not own the matching algorithm.

```text
Resonance
    |
Discovery candidates
    |
Feed presentation/filtering
    |
Moment cards
    |
Space
```

The Feed's purpose is to surface experiences worth encountering, not simply the newest posts.

The Feed should be able to use multiple discovery modes later, including:

- relevant to the current Voice
- emerging experiences
- experiences connected to previous encounters
- diverse experiences outside the user's normal pattern
- Spaces worth entering

Feed ranking may add presentation-specific rules, but it must rely on the shared Resonance/discovery infrastructure for meaningful relationship signals.

---

# 14. Space Integration

A Space remains the contextual experience around a Vent.

Resonance does not replace Space.

Instead:

```text
Moment
  |
Space
  |
Context + activity
  |
Resonance relationships
  |
Threads / deeper connections
```

Resonance may identify relationships among moments inside or across Spaces.

A Voice must not be forced into a Space merely because an algorithm considers their experience similar.

Participation remains user-controlled.

For the current Space model:

- `Just Listen` means the creator wants the expression to be encountered without a conversation requirement.
- `Open Discussion` means the creator is open to people responding with their perspective.

Resonance may operate around both modes, but it must not turn `Just Listen` into an implicit discussion space.

---

# 15. Crash Out Integration

Crash Out remains private unless the user explicitly chooses an outward pathway.

The matching/connection pathway must therefore be opt-in.

```text
Crash Out
    |
Private release
    |
Find People Who Understand
    |
Explicit consent
    |
Resonance Engine
    |
Safety/privacy filtering
    |
Small set of relevant experiences/Voices
```

The matching engine belongs to Resonance, not Crash Out.

Crash Out only supplies an authorized experience to the Resonance system and consumes the returned connection experience.

The user must never have a private Crash Out silently indexed for public discovery.

---

# 16. The Small-Group / Three-Person Experience

Ventvo may eventually present a small number of people or experiences to someone who chooses a connection pathway.

A three-person presentation is a product experience, not the definition of Resonance.

```text
Resonance Engine
       |
Ranked candidates
       |
Product selection
       |
Up to a small number of experiences/Voices
```

The number should remain configurable. The system should not be architecturally dependent on exactly three people.

The experience should emphasize understanding rather than algorithmic matchmaking language.

---

# 17. Echo and Echo Notes

Echo is a future response layer that can become another source of Resonance signals.

```text
Vent
 |
Echo
 |
Resonance
 |
Possible deeper connection
```

Echo Notes can provide richer experiential context and may strengthen or clarify a Resonance relationship.

They should not bypass Space rules or privacy controls.

---

# 18. Privacy Architecture

Resonance must maintain strict separation between:

```text
Private Account Identity
        |
Private system data
        |
Resonance processing
        |
Public Ventvo Voice
        |
Public expression
```

Internal matching data must not expose:

- authentication identifiers
- email addresses
- private account metadata
- private Crash Outs
- moderation-only information
- hidden safety signals

The system should return only the minimum information required for the requested product experience.

---

# 19. Safety Architecture

Every Resonance pathway must include safety filtering.

Safety checks must occur before candidates are presented to the user.

Required considerations include:

- blocked Voices
- reported content
- restricted accounts
- private content
- unsafe content
- harassment patterns
- unwanted repeated contact
- moderation decisions
- age/safety boundaries where applicable

Safety is not a UI-only concern. It belongs in the Resonance service/repository boundary and must also be enforced by backend authorization.

---

# 20. No Popularity Optimization

Resonance must not optimize primarily for:

- likes
- followers
- comments
- time spent
- virality
- popularity
- engagement farming

A highly popular experience is not automatically a highly resonant experience.

---

# 21. Implementation Strategy

The implementation is staged so the connection model is proven before production AI.

### Stage A — Domain models

Create and refine the core Resonance models and enums. **Implemented foundation.**

### Stage B — Repository contract

Define how Resonance candidates and connections are retrieved/stored. **Implemented foundation.**

### Stage C — Engine contract

Define the shared service interface used by Feed, Space, and Crash Out. **Implemented foundation.**

### Stage D — Local deterministic engine

Implement a testable engine using structured signals and deterministic scoring. **Implemented foundation.**

### Stage E — Feed integration

Replace hard-coded discovery with Resonance-powered candidates. **Foundation implemented.**

### Stage F — Space integration

Allow meaningful relationships discovered around Spaces to become Resonance discovery results. **Foundation implemented.**

### Stage G — Connection lifecycle

Create, accept, activate, close, and block Resonance Connections through a controlled lifecycle service. **Implemented foundation.**

### Stage H — Crash Out integration

Implement the explicit Find People Who Understand pathway using the same engine. **Future.**

### Stage I — Backend

Move persistence and discovery to Supabase with secure authorization and scalable querying. **Future.**

### Stage J — Advanced discovery

Evaluate embeddings/AI-assisted similarity only after the core model is proven. **Future.**

---

# 22. Feature Boundary

Resonance is implemented as a reusable system rather than as a normal product screen.

Recommended structure:

```text
lib/
└── systems/
    └── resonance/
        ├── models/
        ├── providers/
        ├── services/
        ├── repositories/
        ├── algorithms/
        └── safety/
```

Feature modules consume Resonance through providers/services and should not directly implement matching logic.

---

# 23. Data Flow Rule

Ventvo follows the engineering architecture:

```text
UI
 ↓
Provider
 ↓
Domain/Application Service
 ↓
Repository
 ↓
Local or Backend implementation
```

For Resonance:

```text
Feed / Space / Crash Out UI
            ↓
Feature Provider
            ↓
Resonance Provider / Service
            ↓
Resonance Engine
            ↓
Resonance Repository
            ↓
Local / Supabase implementation
```

This keeps product features independent from the underlying connection algorithm and storage implementation.

---

# 24. What We Are NOT Implementing Yet

The current Resonance foundation does not attempt to solve everything.

We are not yet implementing:

- production AI matching
- embeddings/vector infrastructure
- public Resonance Maps
- automatic friendship/follow systems
- large group matching
- recommendation notifications
- permanent psychological profiles
- diagnosis or mental-health classification
- a second matching system inside Crash Out

These can be evaluated after the core connection model works.

---

# 25. Testing Requirements

Resonance changes require automated tests for both deterministic behavior and architectural boundaries.

Current coverage includes:

- signal generation
- signal composition
- candidate/profile integration
- deterministic scoring
- candidate discovery
- privacy/safety filtering
- Feed and Space discovery orchestration
- connection creation
- connection type inference
- self/invalid connection rejection
- connection lifecycle transitions
- invalid lifecycle transition rejection

After the latest Connection Lifecycle implementation:

- `flutter analyze` passes with no issues.
- `flutter test` passes all tests.

Future backend and production discovery work must retain equivalent unit/integration coverage.

---

# 26. Success Criteria

The Resonance foundation is successful when:

1. Feed does not need its own matching algorithm.
2. Space does not need its own matching algorithm.
3. Crash Out does not need its own matching algorithm.
4. A future Resonance Thread can use the same connection data.
5. A future Resonance Map can consume the same connection data.
6. Privacy and safety checks are centralized and reusable.
7. The algorithm can evolve without rewriting Feed, Space, or Crash Out.
8. The first implementation can be tested without requiring production AI.
9. Backend persistence can replace local storage without changing product concepts.
10. The architecture remains consistent with Ventvo's principle: meaningful connection over engagement.
11. Connection lifecycle state cannot be arbitrarily mutated by UI code.

---

# 27. Architectural Principle

Resonance is the connective tissue of Ventvo.

It is not one destination.

It is the system that allows different Ventvo experiences to recognize, surface, and develop meaningful human connections while preserving user control, privacy, and safety.

```text
Voice
  ↓
Experience
  ↓
Vent / Space / Crash Out
  ↓
Resonance
  ↓
Connection
  ├── Discovery
  ├── Thread
  ├── Map
  └── Future human-connection experiences
```
