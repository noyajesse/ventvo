## Explicit Voice Identity Boundary

The Resonance domain keeps two identities separate:

- **Experience identity** identifies the Moment/Vent that produced the Resonance and remains the basis for experience-driven Threads and Maps.
- **Voice identity** identifies the anonymous Voice that owns each experience and participates in the resulting relationship.

Resonance connections and active conversations may therefore retain both the originating experience IDs and explicit participant Voice IDs. This does not turn Voice identity into a public profile or alter Resonance discovery. It provides the participant boundary required for future authorization and multi-Voice persistence.

The current prototype keeps these Voice IDs optional for backward compatibility with older local data. Production persistence should require valid participant Voice identities and enforce that only the participating Voices can accept, activate, enter, or message within the connection.

### Participant authorization

Voice IDs define which anonymous Voices participate in a relationship, but they are not authentication credentials.

The connection service now applies these domain rules:
- only the target Voice may accept a suggested connection;
- either participating Voice may activate an accepted connection;
- either participating Voice may close or block a connection.

The conversation service requires the caller Voice to be a participant before opening an active conversation or sending a message.

These are prototype-side domain guards. Production must repeat the authorization boundary server-side using the authenticated account and database authorization/RLS rather than trusting a client-supplied Voice ID.

### Local prototype state honesty

The local prototype must not present a suggested connection as though a second Voice has already received or accepted it.

- A source Voice sees that the Resonance is waiting for the other Voice.
- A target Voice may see the acceptance action only when its Voice ID matches the connection target.
- Accepted/active relationship entry requires the local Voice to be an explicit participant.
- Missing participant Voice identity prevents acceptance.

Real recipient delivery, acceptance, and multi-Voice persistence remain backend responsibilities.

## Direct Conversation After Resonance

Once a Resonance is accepted and activated, the relationship may open a normal one-to-one direct conversation. The conversation is anchored to the Resonance connection and keeps the originating experience relationship visible as context. Conversation messages are private relationship data and are not automatically converted into public discovery signals. Existing Thread formation remains automatic; messages do not create Threads manually. The current prototype uses a local in-memory conversation repository. Production persistence must use explicit Voice identities for participants rather than relying on experience IDs alone.

# Ventvo Resonance System Specification v1.2

## Status

Implemented foundation under active development.

This is the authoritative technical/product specification for Ventvo's Resonance system. Subsystem details belong here rather than in separate Resonance markdown files.

---

# 1. Purpose

Resonance is Ventvo's central human-connection system.

It is not a like system, popularity score, follower system, or single matching feature.

Resonance provides shared infrastructure through which Ventvo can recognize meaningful relationships between experiences, Voices, Vents, Spaces, Threads, and future connection experiences.

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

Internal processing must never automatically expose private information.

---

# 4. Experience as the Primary Input

The primary input to Resonance is an experience, not a permanent user profile.

An experience may contain internal signals such as:

- expression content
- creator intent
- Space mode
- themes or concepts
- situation/context
- emotional context when voluntarily expressed
- desired interaction
- relevant time/context information
- existing relationship context
- safety classification

These signals are internal system data. They are not automatically displayed to other users.

The system should avoid reducing a person to a permanent label.

---

# 5. Resonance Signals

Resonance Signals are structured clues used to determine whether two experiences may meaningfully connect.

Initial signal families include:

### 5.1 Semantic Similarity

Do the experiences discuss related concepts, situations, or ideas?

### 5.2 Experiential Similarity

Do the experiences describe a similar lived experience or circumstance?

### 5.3 Intent Compatibility

Does the creator's requested interaction align with the potential response?

The current Vent model has only two interaction modes:

- `Just Listen`
- `Open Discussion`

Resonance must respect these modes and must not invent additional response modes.

### 5.4 Context Compatibility

Are the experiences related in context rather than merely sharing a few words?

### 5.5 Relationship History

Has a Voice previously encountered or connected with this experience?

This must be used carefully so Ventvo does not create repetitive or closed loops.

### 5.6 Negative Signals

The engine must recognize reasons not to connect two experiences, including:

- privacy restrictions
- blocked Voices
- reported content
- moderation restrictions
- incompatible Space rules
- unsafe or sensitive content boundaries
- excessive repetition
- already-seen candidates where variety is preferable
- unwanted interaction

---

# 6. Resonance Engine

The Resonance Engine is the reusable domain service responsible for turning experiences and signals into possible connections.

Conceptually:

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

Those features consume the shared Resonance infrastructure through services/providers.

The current local engine is deterministic and testable. Production semantic/AI discovery is future infrastructure.

---

# 7. Candidate Discovery and Ranking

Candidate discovery finds potentially relevant experiences before ranking them.

The first implementation uses deterministic/local rules so the architecture can be tested without AI or production-scale infrastructure.

Future candidate sources may include:

- semantic search
- database indexes
- embeddings/vector search
- recent relevant experiences
- Space relationships
- existing Resonance Threads
- user-controlled discovery preferences

Candidates are ranked using multiple signals rather than one similarity score.

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

The exact weighting remains experimental. Ranking must remain explainable enough for engineering and safety review.

---

# 8. Resonance Connections

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

- `sharedExperience` — meaningful overlap in lived experience
- `perspective` — related experience with compatible but potentially different intent/perspective
- `similarity` — broader meaningful overlap when a more specific type cannot be inferred
- `response` — response-based relationship
- `discovery` — discovery relationship

The current implementation creates connections in `suggested` state and manages lifecycle through `ResonanceConnectionService`.

---

# 9. Connection Lifecycle

Connections are modeled as a finite state machine rather than allowing arbitrary UI state changes.

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
- `active` — the connection participates in an ongoing Resonance relationship.
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

Invalid transitions are rejected explicitly.

---

# 10. Active Connection and Direct Conversation

An accepted Resonance can become an active human-to-human connection. Once accepted, the Voices should be able to communicate naturally rather than being forced through a special interaction protocol.

The active connection experience may include normal direct messaging.

The important product boundary is not that messaging is forbidden. The boundary is how access to the conversation is established:

```
Moment
   ↓
Resonance
   ↓
Suggested connection
   ↓
Recipient accepts
   ↓
Active Connection
   ↓
Direct conversation
```

Direct conversation is not a replacement for Resonance. Resonance establishes why the connection exists; messaging is the ordinary communication layer that lets two consenting Voices continue that relationship.

The connection should preserve the originating context so the Voices can still see the Moments/experience that led to the Resonance. This keeps the conversation grounded without forcing users to repeatedly answer structured prompts.

Ventvo must not require users to manually create or manage Threads during conversation. Thread formation remains a Resonance-domain process driven by relationship evidence.

No follower/friend system, popularity mechanism, or arbitrary group chat is implied by an active connection.

## Relationship Evidence

The active conversation can contribute relationship evidence through domain events or other explicitly designed signals. The system should not treat every message as a Thread participant automatically.

Instead:

```
Active Connection
      ↓
Relationship / experience evidence
      ↓
Existing Thread Formation / Evolution Policy
      ↓
Enough meaningful evidence?
   ├── NO → keep conversation as conversation
   └── YES → form or extend Thread
```

Threads therefore remain an emergent system property. Users experience the conversation normally while Resonance determines, behind the scenes, whether the relationship has become strong enough to form or extend a persistent Thread.

The exact message-to-evidence mechanism remains an implementation decision and must respect privacy, safety, consent, and data-minimization boundaries. Ventvo must not silently turn private conversation content into public discovery material.

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

It preserves the relationship between experiences as the connection develops.

The current `ResonanceThread` domain model contains:

- originating experience
- experience identifiers
- participating Voice Marks
- connection relationships
- creation time

Thread creation is intentionally stricter than ordinary candidate discovery. A Thread represents a relationship meaningful enough to persist.

---

# 11. Thread Formation

Thread formation is governed by an explicit policy rather than being triggered merely by similarity. The policy operates behind the scenes; users do not manually create Threads.

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

A new Thread requires:

- a valid originating experience
- at least two distinct counterpart experiences
- accepted or active connections
- connection strength of at least `0.6`
- at least one meaningful type: `sharedExperience`, `response`, or `perspective`
- sufficient combined Resonance strength
- no privacy restriction
- no safety restriction
- no closed or blocked evidence
- no similarity-only formation

Current policy thresholds:

```text
Minimum meaningful connections: 2
Minimum connection strength:    0.6
Minimum combined score:         1.2
```

When a suitable existing Thread is found, the formation service reuses it and extends it through the strongest eligible connection instead of creating a parallel Thread.

Evidence selection is deterministic and requires distinct counterpart experiences.

### Formation Architecture

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

Feed, Space, and Crash Out do not own Thread formation or matching logic.

### Formation Idempotency

Formation accepts a stable Thread identifier. The Thread service checks for an existing Thread before persisting a new one. Repeated formation attempts therefore do not create duplicate Threads for the same formation event.

### Formation Safety

Privacy and safety restrictions are formation vetoes. A private or safety-restricted experience must not silently become part of a persistent Resonance Thread.

---

# 12. Thread Evolution

Threads can grow when a new experience has a meaningful live connection to an existing Thread member.

Evolution rules currently require:

- valid new experience ID
- new experience is not already in the Thread
- connection links the new experience to a Thread experience
- connection is `accepted` or `active`
- connection strength is at least `0.6`

If the experience is already in the Thread, evolution is rejected rather than duplicating the participant.

The evolution policy keeps Thread growth inside the Resonance domain instead of allowing product screens to append arbitrary experiences.

---

# 13. Thread Integrity

Thread integrity determines the current status of a Thread without deleting its historical structure.

Current statuses:

- `active`
- `dormant`
- `restricted`
- `invalid`

A meaningful live connection currently requires:

- `accepted` or `active` state
- strength >= `0.6`
- type of `sharedExperience`, `response`, or `perspective`

### Active

At least one meaningful live connection remains.

### Dormant

No meaningful live connection remains and no blocked relationship requires restriction.

The Thread remains stored as history but is not currently discoverable as an active Thread.

### Restricted

No meaningful live connection remains and at least one blocked connection remains.

A blocked relationship must never be treated as a discoverable live relationship.

### Invalid

The Thread structure violates its connection/experience invariants.

The `ResonanceThread` model already rejects invalid structures during creation. The integrity policy remains a defensive boundary.

The policy does not delete Threads merely because connections close.

---

# 14. Thread Reconciliation

Reconciliation keeps historical Thread structure intact while deriving current discoverability from the latest connection state.

Core rule:

```text
Thread history ≠ current discoverability
```

Historical connections remain part of the Thread. Current connection state determines whether the Thread is active, dormant, or restricted.

### Reconciliation Flow

```text
Connection lifecycle change
        ↓
ResonanceConnectionService
        ↓
Persist updated connection
        ↓
Find Threads involving either endpoint
        ↓
ResonanceThreadReconciliationService
        ↓
Refresh current connection objects
        ↓
Preserve historical connections
        ↓
ResonanceThreadIntegrityPolicy
        ↓
ACTIVE / DORMANT / RESTRICTED
```

The reconciliation service:

1. loads the persisted Thread
2. retrieves latest connections involving its experiences
3. filters those connections to the Thread's participants
4. merges refreshed connections with historical connections
5. evaluates integrity
6. persists the reconciled Thread

Historical connections that are no longer returned by current storage are deliberately preserved.

### Lifecycle Integration

After a successful connection lifecycle transition, `ResonanceConnectionService` finds Threads involving both endpoints, deduplicates Thread IDs, and reconciles them.

```text
ACTIVE → CLOSED
```

can therefore immediately cause affected Threads to be re-evaluated without putting Thread logic in the UI or inside the lifecycle policy.

### Reconciliation Architecture

```text
UI
 ↓
Riverpod
 ↓
ResonanceConnectionService
 ↓
ResonanceConnectionLifecycle
 ↓
ResonanceEngine
 ↓
ResonanceThreadReconciliationService
 ↓
ResonanceThreadIntegrityPolicy
 ↓
ResonanceRepository
```

Responsibilities remain separate:

- Lifecycle decides whether a connection transition is legal.
- Engine coordinates Resonance operations.
- Reconciliation synchronizes Thread state with current connection state.
- Integrity Policy determines current Thread status.
- Repository stores domain state.

Reconciliation is designed to be idempotent: repeating it without underlying state changes should produce the same effective Thread state.

---

# 15. Thread Discovery / Query Boundary

Thread discovery is the application-facing query boundary for currently discoverable Threads.

Product features must not implement their own Thread-state filtering.

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

The discovery service provides:

- `discoverForExperience(experienceId)`
- `discoverAll()`
- configurable result limits

Before a Thread is returned, the service reconciles it against the latest connection state and evaluates its integrity.

Only `active` Threads are currently returned as discoverable.

Therefore:

```text
ACTIVE     → discoverable
DORMANT    → hidden from active discovery
RESTRICTED → hidden from discovery
INVALID    → hidden from discovery
```

The service does not perform matching. It is a query/application boundary around the established Thread domain rules.

This prevents Feed, Space, and Crash Out from independently deciding what constitutes a safe or meaningful Thread.

### Discovery Rules

The current discovery boundary must:

- reject blank experience identifiers
- reject non-positive limits
- reconcile stale Thread state
- preserve historical Thread data
- exclude dormant Threads
- exclude restricted Threads
- exclude invalid Threads
- avoid popularity-based ordering
- avoid exposing internal scoring or safety metadata

Future discovery filters may include context, relationship history, diversity, or user-controlled preferences without moving Thread integrity rules into product features.

---

# 16. Resonance Maps

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

Maps consume established Resonance relationships rather than implementing a separate matching system.

Full Map behavior remains future work.

---

# 17. Feed Integration

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

The Feed's purpose is to surface experiences worth encountering, not simply the newest posts.

Possible future discovery modes include:

- relevant to the current Voice
- emerging experiences
- experiences connected to previous encounters
- diverse experiences outside the user's normal pattern
- Spaces worth entering
- discoverable Resonance Threads

Feed presentation may add presentation-specific rules, but meaningful relationship signals remain centralized in Resonance.

---

# 18. Space Integration

Space is the contextual experience around a Vent.

Resonance does not replace Space.

```text
Vent
  ↓
Space
  ↓
Context + activity
  ↓
Resonance relationships
  ↓
Threads / deeper connections
```

For the current Space model:

- `Just Listen` means the creator wants the expression to be encountered without a conversation requirement.
- `Open Discussion` means the creator is open to people responding with their perspective.

Resonance may operate around both modes, but it must not turn `Just Listen` into an implicit discussion space.

A Voice must not be forced into a Space merely because an algorithm considers their experience similar.

Participation remains user-controlled.

Feed/Space animation and presentation work are currently parked while the deeper Resonance/domain architecture is strengthened.

---

# 19. Crash Out Integration

Crash Out remains private unless the user explicitly chooses an outward pathway.

The matching/connection pathway must therefore be opt-in.

```text
Crash Out
    ↓
Private release
    ↓
Explicit Find People Who Understand request
    ↓
Resonance Engine
    ↓
Safety/privacy filtering
    ↓
Relevant public experiences
    ↓
User chooses whether to leave a Resonance
    ↓
Suggested connection
```

The matching engine belongs to Resonance, not Crash Out.

Crash Out only supplies an explicitly authorized experience to Resonance and consumes the returned discovery/connection experience.

A private Crash Out must never be silently indexed for public discovery.

After a Resonance is left, the connection follows the shared lifecycle rather than ending at discovery:

```text
Suggested → Accepted → Active
```

The receiving Voice controls whether the suggested connection is accepted. The active connection may include normal direct messaging while preserving the originating shared experience as context.

---

# 20. Small-Group / Three-Voice Experience

Ventvo may eventually present a small number of people or experiences to someone who chooses a connection pathway.

A three-Voice presentation is a product experience, not the definition of Resonance.

```text
Resonance Engine
       ↓
Ranked candidates
       ↓
Product selection
       ↓
Small number of experiences / Voices
```

The number must remain configurable. Resonance must not be architecturally dependent on exactly three people.

The experience should emphasize understanding rather than algorithmic matchmaking language.

---

# 21. Echo and Echo Notes

Echo is a future response layer that can become another source of Resonance signals.

```text
Vent
 ↓
Echo
 ↓
Resonance
 ↓
Possible deeper connection
```

Echo Notes may provide richer experiential context and strengthen or clarify a Resonance relationship.

They must not bypass Space rules or privacy controls.

---

# 22. Privacy Architecture

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

Internal matching data must not expose:

- authentication identifiers
- email addresses
- private account metadata
- private Crash Outs
- moderation-only information
- hidden safety signals

The system should return only the minimum information required for the requested product experience.

---

# 23. Safety Architecture

Every Resonance pathway must include safety filtering before candidates are presented.

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

# 24. No Popularity Optimization

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

# 25. Implementation Strategy

The implementation is staged so the connection model is proven before production AI.

### Stage A — Domain models

Create and refine core Resonance models and enums. **Implemented foundation.**

### Stage B — Repository contract

Define how Resonance candidates, connections, and Threads are retrieved/stored. **Implemented foundation.**

### Stage C — Engine contract

Define the shared service interface used by Feed, Space, Crash Out, and future features. **Implemented foundation.**

### Stage D — Local deterministic engine

Implement a testable engine using structured signals and deterministic scoring. **Implemented foundation.**

### Stage E — Connection lifecycle

Create, accept, activate, close, and block Resonance Connections through controlled lifecycle rules. **Implemented foundation.**

### Stage F — Thread formation

Apply evidence thresholds and safety/privacy vetoes before creating Threads. **Implemented and verified.**

### Stage G — Thread evolution

Allow meaningful live connections to extend existing Threads safely. **Implemented and verified.**

### Stage H — Thread integrity

Derive active, dormant, restricted, and invalid Thread status. **Implemented and verified.**

### Stage I — Thread reconciliation

Refresh Thread connection state after lifecycle changes while preserving historical structure. **Implemented and verified.**

### Stage J — Thread discovery boundary

Expose only currently discoverable Threads through a reusable application-facing query service. **Implemented and verified.**

### Stage K — Feed/Space discovery

Use the established Resonance query/discovery infrastructure from product surfaces. **Foundation exists; UI/presentation work remains.**

### Stage L — Crash Out integration

Implement and validate the explicit Find People Who Understand pathway using the shared Resonance engine, including the private Crash Out boundary. **Foundation exists; full recipient-side connection flow remains future.**

### Stage M — Backend

Move persistence and discovery to Supabase with secure authorization and scalable querying. **Future.**

### Stage N — Advanced discovery

Evaluate embeddings/AI-assisted similarity only after the deterministic core is proven. **Future.**

---

# 26. Feature Boundary

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

# 27. Data Flow Rule

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

For Resonance:

```text
Feed / Space / Crash Out UI
            ↓
Feature Provider
            ↓
Resonance Provider / Service
            ↓
Resonance Engine / Domain Service
            ↓
Resonance Repository
            ↓
Local / Supabase implementation
```

This keeps product features independent from the connection algorithm and storage implementation.

---

# 28. CS / Engineering Concepts Demonstrated

The Resonance system intentionally demonstrates several core software-engineering concepts.

### Domain rules

Business rules such as Thread formation thresholds live in policies rather than UI code.

### Separation of concerns

Formation, evolution, lifecycle, integrity, reconciliation, discovery, persistence, and presentation are separate responsibilities.

### Finite-state machines

Connection lifecycle is explicitly modeled so invalid state transitions cannot be performed arbitrarily.

### Deterministic algorithms

The local engine and Thread evidence selection produce predictable results that are easy to test.

### State reconciliation

Persisted historical state is refreshed against current authoritative connection state without destroying history.

### Graph consistency

Threads represent experience graphs whose nodes and connections must remain structurally valid.

### Idempotency

Repeated formation/reconciliation operations do not create duplicate domain state.

### Dependency injection

Services receive engines, repositories, and reconciliation dependencies rather than constructing them internally.

### Query/application boundaries

Product features ask Resonance for valid domain results instead of reproducing filtering rules independently.


# 29. Relationship Formation Orchestration

Thread and Map formation are triggered by a narrow orchestration boundary after a Resonance connection reaches an accepted or active state. The orchestration does not replace the existing formation policies. It asks the Thread and Map formation services to evaluate the current relationship evidence.

```text
Connection lifecycle
       ↓
Accepted / Active
       ↓
Relationship formation orchestration
       ↓
Thread formation policy/service   Map formation policy/service
       ↓                         ↓
   Thread (if justified)      Map (if justified)
```

Formation remains conservative:
- suggested, closed, and blocked connections do not form structures;
- a single connection is insufficient for Thread/Map formation;
- existing strength, meaningful-type, combined-evidence, and privacy/safety thresholds remain authoritative;
- formation is evaluated from either endpoint of a qualifying connection;
- multiple experiences belonging to the same Voice do not count as multiple people.

Voice IDs are participant identifiers rather than authentication credentials. Production authorization must still be enforced server-side.
