# Ventvo Resonance System Specification v1.3

## Status

Implemented foundation under active development.

This is the authoritative technical and product specification for Ventvo's Resonance system. Subsystem details belong here rather than in separate Resonance markdown files.

---

# 1. Purpose

Resonance is Ventvo's central human-connection system.

It is not a like system, popularity score, follower system, therapy system, or single matching feature.

Resonance provides shared infrastructure through which Ventvo can recognize meaningful relationships between experiences, Voices, Vents, Spaces, Threads, Maps, and future connection experiences.

The central question is:

> What meaningful connection exists between these experiences or people?

Resonance powers multiple product experiences rather than living inside one screen.

---

# 2. Core Architecture

```text
                         RESONANCE
                  Human connection layer
                            |
        +-------------------+-------------------+
        |                   |                   |
     Signals             Engine              Safety
        |                   |                   |
        +-------------------+-------------------+
                            |
                  Resonance Connections
                            |
        +-------------------+-------------------+
        |                   |                   |
     Threads              Maps             Discovery
        |                   |                   |
        +-------------------+-------------------+
                            |
                  Product experiences
        +-----------+-----------+-----------+
        |           |           |           |
       Feed       Space     Crash Out     Future
```

Resonance is therefore a system layer, not a feature screen.

---

# 3. Experience as the Primary Input

The primary input to Resonance is an experience, not a permanent psychological profile.

An experience may contain internal signals such as:

- expression content
- creator intent
- Space mode
- themes or concepts
- situation/context
- voluntarily expressed emotional context
- desired interaction
- relationship context
- safety classification

These signals are internal system data. They are not automatically exposed to other users.

The system must avoid reducing a person to a permanent label.

The current Vent interaction modes are only:

- `Just Listen`
- `Open Discussion`

Resonance must respect these modes and must not invent additional response modes.

---

# 4. Resonance Signals

Resonance Signals are structured clues used to determine whether experiences may meaningfully connect.

Initial signal families include:

- semantic similarity
- experiential similarity
- intent compatibility
- context compatibility
- relationship history
- diversity
- privacy constraints
- safety constraints
- repetition/negative signals

Negative signals may prevent a connection because of privacy restrictions, blocked Voices, reported content, moderation restrictions, incompatible Space rules, unsafe content, excessive repetition, or unwanted interaction.

---

# 5. Resonance Engine

The Resonance Engine is the reusable domain service responsible for turning experiences and signals into possible connections.

```text
Experience
    |
Signal extraction
    |
Candidate discovery
    |
Candidate filtering
    |
Resonance scoring
    |
Safety/privacy filtering
    |
Ranked candidates
    |
Product experience
```

The engine must not be embedded inside Feed, Space, or Crash Out.

The current local engine is deterministic and testable. Production semantic/AI discovery remains future infrastructure.

---

# 6. Candidates and Ranking

Candidate discovery finds potentially relevant experiences before ranking them.

Future candidate sources may include semantic search, database indexes, embeddings/vector search, recent relevant experiences, Space relationships, existing Resonance Threads, and user-controlled discovery preferences.

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

Ranking must remain explainable enough for engineering and safety review.

---

# 7. Resonance Connections

A Resonance Connection represents a meaningful relationship discovered or created between experiences/Voices.

It is not automatically a friendship, follow, or permanent relationship.

A connection contains:

- source identifier
- target identifier
- connection type
- relevance strength
- lifecycle state
- creation time

Current connection types:

- `sharedExperience`
- `perspective`
- `similarity`
- `response`
- `discovery`

Meaningful Thread/Map persistence currently relies on `sharedExperience`, `perspective`, and `response` relationships with sufficient strength.

---

# 8. Connection Lifecycle

Connections are modeled as a finite state machine.

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

- `suggested` — Resonance identified a possible relationship.
- `accepted` — the connection has been acknowledged/opened for further use.
- `active` — the connection participates in an ongoing relationship.
- `closed` — the relationship has ended.
- `blocked` — the relationship is prevented for safety/privacy reasons and is terminal.

Lifecycle control belongs to `ResonanceConnectionLifecycle` and `ResonanceConnectionService`.

UI code must not directly mutate connection state.

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

---

# 9. Resonance Threads

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

A Thread is not a conventional comment thread. It preserves the relationship between experiences as the connection develops.

The Thread model contains:

- originating experience
- experience identifiers
- participating Voice Marks
- connection relationships
- creation time

Thread creation is stricter than ordinary candidate discovery.

## Thread Formation

Formation requires meaningful evidence rather than similarity alone.

Current requirements include:

- valid originating experience
- at least two distinct counterpart experiences
- accepted or active connections
- connection strength >= `0.6`
- meaningful connection types
- sufficient combined evidence
- no privacy restriction
- no safety restriction
- no closed/blocked evidence
- no similarity-only formation

Current thresholds:

```text
Minimum meaningful connections: 2
Minimum connection strength:    0.6
Minimum combined score:         1.2
```

Formation is deterministic and idempotent.

## Thread Evolution

A Thread may grow when a new experience has a meaningful live connection to an existing Thread member.

Requirements:

- valid new experience ID
- experience not already in Thread
- connection links the new experience to a Thread experience
- connection is `accepted` or `active`
- connection strength >= `0.6`

---

# 10. Thread Integrity and Reconciliation

Thread integrity determines current status without deleting historical structure.

Statuses:

- `active`
- `dormant`
- `restricted`
- `invalid`

A meaningful live connection requires an accepted/active state, strength >= `0.6`, and a meaningful relationship type.

```text
Connection lifecycle change
        ↓
ResonanceConnectionService
        ↓
Persist connection
        ↓
Thread Reconciliation
        ↓
Thread Integrity Policy
        ↓
ACTIVE / DORMANT / RESTRICTED
```

Historical connections are preserved even when their current state changes or they are no longer returned by current storage.

Reconciliation is idempotent.

---

# 11. Thread Discovery

Thread discovery is the application-facing query boundary for currently discoverable Threads.

```text
Feed / Space / Crash Out
        ↓
ResonanceThreadDiscoveryService
        ↓
Thread Reconciliation
        ↓
Thread Integrity Policy
        ↓
Discoverable Threads
```

Only `active` Threads are currently discoverable.

The discovery boundary validates inputs, reconciles stale state, preserves history, excludes dormant/restricted/invalid Threads, and does not expose internal scoring or safety metadata.

---

# 12. Resonance Maps

A Resonance Map represents a broader pattern of relationships discovered through Resonance.

```text
Experience A
      |
      +------ Experience B
      |             |
      |             +------ Experience C
      |
      +------ Experience D
```

A Map is a domain object, not a UI graph.

The domain layer defines the relationships and integrity rules first. Visual presentation is intentionally separate and may later represent Maps as a richer living/constellation-like experience rather than a generic graph screen.

A Map contains:

- Map identifier
- experience identifiers
- Thread identifiers
- Resonance connections
- creation time

Map invariants include:

- nonblank Map ID
- no duplicate experiences
- no duplicate Thread IDs
- no self-links
- every connection endpoint belongs to the Map

---

# 13. Map Integrity

Map integrity determines whether a Map is currently usable without destroying historical relationships.

Statuses:

- `active`
- `dormant`
- `restricted`
- `invalid`

A Map is invalid when its structure violates core invariants or it contains fewer than three experiences.

A meaningful live Map relationship requires:

- connection state `accepted` or `active`
- strength >= `0.6`
- connection type `sharedExperience`, `response`, or `perspective`

`similarity` and `discovery` relationships do not keep a Map active by themselves.

`closed` connections are preserved as history.

`blocked` connections can cause restriction when no other meaningful live relationship remains.

Suggested connections do not keep a Map active.

---

# 14. Map Reconciliation

Map reconciliation refreshes current connection state while preserving historical relationships.

```text
Map
 ↓
Latest connections for Map experiences
 ↓
Filter to valid Map endpoints
 ↓
Merge refreshed state with history
 ↓
Map Integrity Policy
 ↓
Persist reconciled Map
```

The reconciliation service:

1. loads the Map
2. retrieves current connections involving every Map experience
3. filters connections to valid Map endpoints
4. replaces historical connection state when a newer version exists
5. preserves historical connections missing from current storage
6. evaluates Map integrity
7. persists the reconciled Map

Reconciliation is idempotent.

---

# 15. Map Discovery

Map discovery is the application-facing query boundary for discoverable Maps.

```text
Experience / Feature
        ↓
ResonanceMapDiscoveryService
        ↓
Map Reconciliation
        ↓
Map Integrity Policy
        ↓
Discoverable Maps
```

The discovery service provides:

- `discoverForExperience(experienceId)`
- `discoverAll()`
- configurable limits

Only active Maps are returned.

Discovery validates identifiers and limits, reconciles stale Maps, deduplicates Map IDs, and keeps Map integrity rules out of product UI code.

---

# 16. Map Formation

Map formation creates a Map from established meaningful Resonance relationships.

The formation path is intentionally separate from candidate matching.

```text
Seed Experience
      ↓
Meaningful Connections
      ↓
Map Formation Policy
      ↓
Enough evidence?
   ├── NO → no Map
   └── YES
         ↓
ResonanceMap
         ↓
Map Integrity Policy
         ↓
Persist Map
```

Current formation requirements include:

- valid seed experience
- enough meaningful counterparts to form a Map
- accepted or active connections
- strength >= `0.6`
- meaningful relationship types
- no privacy restriction
- no safety restriction
- no similarity-only formation

Formation currently builds from meaningful connections involving the seed experience. It does not silently introduce a separate matching system.

Map IDs are deterministic in the current local implementation to support repeatable behavior and idempotency.

Partial Map merging/extension is intentionally separate from initial formation.

---

# 17. Map Evolution

Map evolution allows an existing Map to grow when a new experience becomes meaningfully connected to an existing Map experience.

```text
Existing Map
     ↓
New Experience
     ↓
Map Evolution Policy
     ↓
Qualifying live connection?
   ├── NO → no change
   └── YES
         ↓
Add experience + qualifying connections
         ↓
Map Integrity Policy
         ↓
Persist updated Map
```

Current evolution requirements:

- valid Map
- valid new experience ID
- experience is not already in Map
- connection involves the new experience
- connection links to an existing Map experience
- connection is `accepted` or `active`
- strength >= `0.6`
- meaningful type: `sharedExperience`, `response`, or `perspective`
- no privacy restriction
- no safety restriction

Evolution reconciles the Map before applying growth so decisions use current connection state.

Existing connections are preserved and duplicate experiences are not added.

Evolution is idempotent.

---

# 18. Map ↔ Thread Integration

Maps and Threads represent different levels of Resonance structure.

- Thread = developing chain of related experiences.
- Map = broader relationship pattern.

A discoverable/active Thread can be integrated into a Map when it overlaps the Map's experiences.

```text
Thread
  ↓
Thread Integrity
  ↓
Overlap with Map?
  ├── NO → no integration
  └── YES
        ↓
Union experiences
        ↓
Merge meaningful Thread connections
        ↓
Map Integrity
        ↓
Updated Map
```

Integration requires:

- valid Map
- valid Thread
- both structures contain at least three experiences
- Thread is discoverable/active
- at least one overlapping experience
- no privacy restriction
- no safety restriction

Integration does not mutate or create Threads.

---

# 19. Map Event Orchestration

Map growth is triggered through a dedicated event orchestration boundary rather than being embedded inside connection lifecycle rules.

```text
Connection State Transition
          ↓
ResonanceConnectionService
          ↓
Persist Connection
          ↓
ResonanceMapEventService
          ↓
Existing Map involving endpoint?
      ┌──────────────┴──────────────┐
      NO                            YES
      ↓                              ↓
    No-op                    Map Evolution
                                     ↓
                             Map Reconciliation
                                     ↓
                               Updated Map
```

Only `accepted` and `active` connections can trigger Map evolution.

`suggested`, `closed`, and `blocked` connections do not trigger Map growth.

If both endpoints already belong to the same Map, no evolution occurs because there is no new experience to add.

If neither endpoint belongs to a Map, the event service does nothing. Map Formation remains a separate domain operation.

If the endpoints belong to different Maps, the event service does **not** merge those Maps. Map merging is a future, explicitly defined capability.

The event service delegates actual growth to `ResonanceMapEvolutionService`, preserving one canonical Map-growth path.

This separation keeps responsibilities clear:

- Connection Lifecycle decides whether a state transition is legal.
- Connection Service persists lifecycle state and coordinates downstream effects.
- Map Event Service interprets meaningful lifecycle events for Maps.
- Map Evolution Service decides whether a Map can grow and applies the growth.
- Map Reconciliation synchronizes current state with historical structure.
- Map Integrity determines current Map status.

---

# 20. Feed Integration

The Feed is a discovery surface powered by Resonance.

The Feed must not own the matching algorithm.

```text
Resonance
    ↓
Discovery candidates
    ↓
Feed presentation/filtering
    ↓
Experience cards
    ↓
Space
```

Feed presentation may add presentation-specific rules, but meaningful relationship signals remain centralized in Resonance.

---

# 21. Space Integration

Space is the contextual experience around a Vent.

For the current Space model:

- `Just Listen` means the creator wants the expression to be encountered without a conversation requirement.
- `Open Discussion` means the creator is open to people responding with their perspective.

Resonance may operate around both modes, but it must not turn `Just Listen` into an implicit discussion space.

Participation remains user-controlled.

Feed/Space animation and presentation work remain separate from the Resonance domain foundation.

---

# 22. Crash Out Integration

Crash Out remains private unless the user explicitly chooses an outward connection pathway.

```text
Crash Out
    ↓
Private release
    ↓
Explicit connection pathway
    ↓
Resonance Engine
    ↓
Safety/privacy filtering
    ↓
Relevant experiences / Voices
```

A private Crash Out must never be silently indexed for public discovery.

---

# 23. Privacy Architecture

Resonance maintains strict separation between private account identity and public Ventvo identity.

```text
Private Account Identity
        ↓
Private system data
        ↓
Resonance processing
        ↓
Public Ventvo Voice
        ↓
Public expression
```

Internal matching data must not expose authentication identifiers, email addresses, private account metadata, private Crash Outs, moderation-only information, or hidden safety signals.

The system should return only the minimum information required for the requested product experience.

---

# 24. Safety Architecture

Every Resonance pathway must include safety filtering before candidates or relationships are presented.

Required considerations include:

- blocked Voices
- reported content
- restricted accounts
- private content
- unsafe content
- harassment patterns
- unwanted repeated contact
- moderation decisions
- applicable age/safety boundaries

Safety is not a UI-only concern. It belongs in the Resonance service/repository boundary and must also be enforced by backend authorization.

---

# 25. No Popularity Optimization

Resonance must not optimize primarily for likes, followers, comments, time spent, virality, popularity, or engagement farming.

A highly popular experience is not automatically a highly resonant experience.

---

# 26. Implementation Strategy

The implementation is staged so the deterministic connection model is proven before production AI.

### Stage A — Domain models
Implemented foundation.

### Stage B — Repository contracts
Implemented foundation, including separate Map repository boundaries.

### Stage C — Engine contracts
Implemented foundation, including the dedicated `ResonanceMapEngine` boundary.

### Stage D — Local deterministic engine
Implemented foundation.

### Stage E — Connection lifecycle
Implemented and verified.

### Stage F — Thread formation
Implemented and verified.

### Stage G — Thread evolution
Implemented and verified.

### Stage H — Thread integrity
Implemented and verified.

### Stage I — Thread reconciliation
Implemented and verified.

### Stage J — Thread discovery boundary
Implemented and verified.

### Stage K — Map foundation
Implemented and verified:

- Map model
- Map repository boundary
- Map engine boundary
- Map integrity
- Map reconciliation
- Map discovery

### Stage L — Map formation
Implemented and verified.

### Stage M — Map evolution
Implemented and verified.

### Stage N — Map ↔ Thread integration
Implemented and verified.

### Stage O — Map event orchestration
Implemented and verified.

### Stage P — Feed/Space discovery
Foundation exists; UI/presentation work remains.

### Stage Q — Crash Out integration
Future.

### Stage R — Backend
Move persistence and discovery to Supabase with secure authorization and scalable querying. Future.

### Stage S — Advanced discovery
Evaluate embeddings/AI-assisted discovery only after the deterministic core is proven. Future.

---

# 27. Feature Boundary

Resonance is implemented as a reusable system rather than a normal product screen.

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

Feature modules consume Resonance through providers/services and must not directly implement matching logic.

---

# 28. Data Flow Rule

Ventvo follows:

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

For lifecycle-triggered Map behavior:

```text
Connection lifecycle
        ↓
Connection Service
        ↓
Map Event Service
        ↓
Map Evolution Service
        ↓
Map Reconciliation
        ↓
Map Integrity
        ↓
Map Engine / Repository
```

This keeps product features independent from connection algorithms and storage implementation.

---

# 29. CS / Engineering Concepts Demonstrated

The Resonance system intentionally demonstrates:

- domain rules and policy objects
- separation of concerns
- finite-state machines
- deterministic algorithms
- state reconciliation
- graph consistency
- idempotency
- dependency injection
- interface segregation
- query/application boundaries
- encapsulation of private and safety data

Formation, evolution, lifecycle, integrity, reconciliation, discovery, orchestration, persistence, and presentation remain separate responsibilities.

---

# 30. Testing Requirements and Current Verification

Resonance changes require automated tests for deterministic behavior and architectural boundaries.

Current verified coverage includes:

- signal generation and composition
- candidate/profile integration
- deterministic scoring and candidate discovery
- privacy/safety filtering
- Feed and Space discovery orchestration
- connection creation/type inference
- self/invalid connection rejection
- lifecycle transitions and invalid transition rejection
- Thread formation/evolution/integrity/reconciliation/discovery
- stale Thread reconciliation during discovery
- Map integrity
- Map reconciliation
- Map discovery filtering and limits
- Map formation approval/rejection and idempotency
- Map evolution rules
- Map ↔ Thread integration
- Map event orchestration

Verified development workflow:

```bash
git pull origin development
flutter analyze
flutter test
```

The latest Map Event Orchestration milestone was explicitly verified as clean with analysis and tests passing.

Future backend and production discovery work must retain equivalent unit and integration coverage.

---

# 31. What We Are NOT Implementing Yet

We are not yet implementing:

- production AI matching
- embeddings/vector infrastructure
- public visual Resonance Maps
- automatic friendship/follow systems
- large group matching
- recommendation notifications
- permanent psychological profiles
- diagnosis or mental-health classification
- a second matching system inside Crash Out
- final Feed/Space animation or presentation polish
- automatic Map merging

These can be evaluated only after the core connection model works.

---

# 32. Current Implementation Status

Implemented and verified foundation:

- Resonance signals
- Resonance profiles/composition
- deterministic scoring
- candidate discovery
- Resonance connections
- connection lifecycle
- Thread model
- Thread formation policy/service
- Thread evolution policy/service
- Thread integrity policy
- Thread reconciliation service
- lifecycle-triggered Thread reconciliation
- Thread discovery/query boundary
- Map model
- Map repository and engine boundaries
- Map formation policy/service
- Map evolution policy/service
- Map integrity policy
- Map reconciliation service
- Map discovery service
- Map ↔ Thread integration policy/service
- Map event orchestration service
- automated tests for the above

The current development priority remains the Resonance/domain layer before returning to Feed and Space presentation work.

---

# 33. Architectural Rule for Future Resonance Work

Every future Resonance capability must answer four questions before implementation:

1. **What domain rule does it introduce?**
2. **Which existing service/policy owns that rule?**
3. **Can it reuse existing Resonance state instead of creating a parallel system?**
4. **How will its deterministic behavior be tested?**

New product features must consume the established Resonance infrastructure rather than recreating matching, filtering, lifecycle, safety, or relationship logic.

The central rule remains:

> Resonance is the shared human-connection layer. Product features consume it; they do not replace it.
