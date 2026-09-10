# Ventvo Resonance System Specification v1.0

## Status

Proposed foundation for implementation.

This document defines the first technical/product specification for Ventvo's Resonance system. It is intentionally implementation-oriented while leaving room for later refinement of the matching algorithm and user experience.

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

Examples:

- Just Listen should not be treated as an invitation for advice.
- Similar Experiences can prioritize people who have lived something comparable.
- Encouragement can prioritize supportive experiences.
- Open Discussion can permit broader perspective.

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

---

# 7. Candidate Discovery

Candidate discovery finds potentially relevant experiences before ranking them.

The first implementation may use deterministic/local rules so that the architecture can be tested without requiring an AI model or production-scale infrastructure.

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

A connection should contain enough information to establish:

- source experience
- related experience or Voice
- connection type
- originating context
- confidence/relevance information where appropriate
- creation time
- safety state
- lifecycle state

A connection may be temporary, contextual, or develop into a Resonance Thread.

---

# 10. Resonance Threads

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

---

# 11. Resonance Maps

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

The first Map implementation should be data-driven and can initially remain invisible to users until the relationship model is stable.

---

# 12. Feed Integration

The Feed is a discovery surface powered by Resonance.

The Feed must not own the matching algorithm.

```text
Resonance
    |
Discovery candidates
    |
Feed ranking/filtering
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

# 13. Space Integration

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

---

# 14. Crash Out Integration

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

# 15. The Small-Group / Three-Person Experience

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

# 16. Echo and Echo Notes

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

# 17. Privacy Architecture

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

# 18. Safety Architecture

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

# 19. No Popularity Optimization

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

# 20. Initial Implementation Strategy

The first implementation should be deterministic and testable.

Do not begin with an AI model.

### Stage A — Domain models

Create the core Resonance models and enums.

### Stage B — Repository contract

Define how Resonance candidates and connections are retrieved/stored.

### Stage C — Engine contract

Define the shared service interface used by Feed, Space, and Crash Out.

### Stage D — Local deterministic engine

Implement a small testable engine using structured signals and deterministic scoring.

### Stage E — Feed integration

Replace hard-coded discovery with Resonance-powered candidates.

### Stage F — Space integration

Allow meaningful relationships discovered around Spaces to become Resonance connections.

### Stage G — Crash Out integration

Implement the explicit Find People Who Understand pathway using the same engine.

### Stage H — Backend

Move persistence and discovery to Supabase with secure authorization and scalable querying.

### Stage I — Advanced discovery

Evaluate embeddings/AI-assisted similarity only after the core model is proven.

---

# 21. Proposed Feature Boundary

Resonance should be implemented as a reusable system rather than as a normal product screen.

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

# 22. Data Flow Rule

Ventvo follows the engineering architecture:

```text
UI
 ↓
Provider
 ↓
Repository
 ↓
Service
 ↓
Backend
```

For Resonance:

```text
Feed / Space / Crash Out UI
            ↓
Feature Provider
            ↓
Resonance Provider
            ↓
Resonance Engine / Service
            ↓
Resonance Repository
            ↓
Supabase
```

This keeps product features independent from the underlying connection algorithm.

---

# 23. What We Are NOT Implementing Yet

The first Resonance foundation will not attempt to solve everything.

We are not yet implementing:

- production AI matching
- embeddings/vector infrastructure
- public Resonance Maps
- automatic friendship/follow systems
- large group matching
- recommendation notifications
- permanent psychological profiles
- diagnosis or mental-health classification

These can be evaluated after the core connection model works.

---

# 24. First Engineering Deliverable

The immediate implementation target is:

```text
Resonance domain models
        ↓
Resonance repository contract
        ↓
Resonance engine contract
        ↓
Deterministic local engine
        ↓
Unit tests
```

Only after this foundation passes testing should Feed and Space be rebuilt around it.

---

# 25. Success Criteria

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

---

# 26. Architectural Principle

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
