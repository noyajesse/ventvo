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
                 Experience Understanding
                           │
                           ▼
                 Meaningful Opposition
                           │
                 ┌─────────┴─────────┐
                 │                   │
              Encounter          No encounter
                 │
                 ▼
          Crash Out Space
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

Crash Out is separate from the Vent model and is not a Resonance similarity feature.

### Owns

- Crash Out ID
- Private expression payload
- Creation timestamp
- Lifecycle state
- Release type
- Encounter state
- Privacy-safe experience representation only if delayed matching is explicitly implemented

### Core flow

Private Crash Out
→ Experience Understanding
→ Human Tension
→ Position + Direction
→ Opposition Evaluation
→ Crash Out Encounter

### Opposition boundary

Crash Out looks for a meaningfully opposing experience, not a similar one.

An opposition candidate should share a meaningful human tension while occupying an opposing position/direction. Context can support the relationship but cannot create opposition by itself.

The system must allow no match when no meaningful opposite exists.

### Privacy boundary

The raw Crash Out remains private. It must never be indexed or exposed as a public source merely because it is used to evaluate public experiences.

If delayed encounters are implemented, Ventvo may retain only the minimum privacy-safe representation required for matching, subject to an explicit retention/deletion design. Deleting the Crash Out must remove its matching representation.

### Product relationship

- Find People Who Understand → similarity / understanding.
- Resonance → meaningful connection.
- Crash Out → meaningful opposition.

### Prototype implementation

The current CrashOutOppositeExperienceService is deterministic prototype scaffolding. It should evolve toward:

CrashOutExperienceInterpreter
→ ExperienceRepresentation
→ CrashOutOppositionEngine
→ Candidate Eligibility
→ CrashOutEncounter

### Does not own

- Public Vent content
- Authentication information
- Generic social matching
- Resonance connection lifecycle
- Follower/like mechanics

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

### Participant authorization boundary

Voice IDs are participant identifiers, not authentication by themselves.

The connection service now requires a caller Voice ID for lifecycle actions:
- only the target Voice may accept a suggested connection;
- either participating Voice may activate an accepted connection;
- either participating Voice may close or block a connection.

The conversation service also requires the caller Voice to be one of the explicit conversation participants before opening the conversation or sending a message.

These checks establish the domain boundary in the local prototype. Production persistence must enforce the same rules against the authenticated account and server-side authorization/RLS; client-provided Voice IDs must never be treated as proof of identity.

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

Any product surface that needs meaningful similarity/connection discovery uses Resonance rather than implementing similarity matching locally.

Crash Out opposition is intentionally separate. It may reuse shared safety, privacy, moderation, and repository infrastructure without becoming a Resonance similarity flow.

### Rule 4a — Discovery does not end the journey
When a user chooses This resonates with me, Resonance creates a suggested connection through the connection service. The connection must then follow the shared lifecycle rather than ending at discovery.

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
5. Define and implement the Crash Out Space domain and its participation/reply lifecycle.
6. Build Vent experience signal generation.
7. Connect Feed, Space, and Crash Out to Resonance.
8. Replace prototype local persistence with secure backend persistence.
9. Add authentication, authorization, moderation, reporting, and privacy enforcement.
10. Add advanced semantic/AI discovery only after the core system is proven.


### Thread and Map formation integrity

Threads and Maps represent relationships among experiences and therefore must not treat multiple experiences from one Voice as multiple independent people. Formation requires explicit Voice identities and enough distinct participating Voices to satisfy the structure's existing evidence thresholds.

The formation boundary is orchestrated only after an accepted or active Resonance connection. Suggested, closed, and blocked relationships cannot trigger formation. The existing Thread and Map formation policies remain responsible for strength, meaningful relationship type, evidence, and privacy/safety decisions.

## Crash Out Space

A **Crash Out Space** is the shared, ongoing environment a person enters after Ventvo surfaces a meaningful opposite experience. It gathers many eligible experiences that relate to the same underlying human tension and allows people to reply to individual experiences over time.

It is an ongoing community around the human tension, not a temporary private chat or a one-to-one thread. It is not defined by a fixed pair of participants.

### Conceptual model

```
Private CrashOut
      ↓
ExperienceRepresentation
      ↓
MeaningfulOpposition
      ↓
CrashOutSpace discovery/entry
      ↓
Many eligible CrashOutExperiences
      ↓
Replies to individual experiences
      ↓
Ongoing conversation
```

### Core objects to define before implementation

- **CrashOutSpace**: stable identity for a meaningful human tension and its opposing sides; includes a display title/description and lifecycle.
- **CrashOutExperience**: an experience that appears in a Crash Out Space, tied to a human tension and one of its opposing sides.
- **CrashOutReply**: a response to a specific eligible experience, authored through a Ventvo Voice, with creation time and reply relationship.
- **CrashOutSpaceMembership/Entry**: only add if needed for actual participation behavior.

These are proposed domain boundaries, not a claim that the models already exist in the codebase.

### Invariants

1. **Many experiences, not one encounter:** an initial opposite experience leads into a broader Space; it is not the complete destination.
2. **Opposition defines discovery:** a Space relates experiences through meaningful human tension and opposing sides. Topic overlap alone is insufficient.
3. **Replies are first-class:** eligible participants can reply to individual experiences, and replies can continue over time.
4. **No forced activity:** the system does not invent experiences or replies to keep a Space active.
6. **Voice identity:** shared contributions use Ventvo Voice identity, not private account identity.
7. **No automatic relationship:** participation or replying does not automatically create Resonance, a private connection, or a direct-message relationship.
8. **Not a normal Vent Space:** this domain is organized around the opposing sides of a human tension, rather than a single intentionally published Vent and its chosen interaction mode.

### Relationship to the existing ExperienceThread prototype

The current `ExperienceThread` model is owned by one Crash Out and stores an origin plus an initial opposite contribution and later replies. That implementation is a prototype of continued experience interaction, but it is **not** the intended user-facing Crash Out Space architecture.

Do not expand the one-thread-per-Crash-Out model into the community system by simply adding more messages. The Crash Out Space is a community around a human tension, opposing experiences, and ongoing replies. Existing opposition interpretation can remain a discovery input.

### Privacy and backend boundary

The current frontend uses local persistence and cannot enforce cross-user access control. Before backend work, the domain and security model must specify who can read a Space, who can publish a Crash Out experience there, who can reply, how deletion affects shared content/replies, and how reports/moderation work. Backend remains deferred; this specification does not authorize introducing it now.

## 11. Crash Out Space (Frontend Prototype)

### Definition

A Crash Out Space is an ongoing, experience-first collection organized around a shared human tension and its opposing sides. It is not a private one-to-one thread, generic group chat, or comment section.

### Frontend model boundary

- `CrashOutSpaceExperience` is the domain model rendered inside a Crash Out Space.
- The discovered opposite experience is the doorway into the Space.
- The doorway may originate from an eligible public Vent, but the Space screen and local Space collection use the dedicated `CrashOutSpaceExperience` model rather than treating the entire public Vent list as Space content.
- Local prototype experiences are stored separately from Vents and are scoped by Space ID.
- Replies remain attached to a specific Space experience.

### Current prototype limitations

The current Flutter prototype can locally retain the discovered doorway and replies on one installation. It does not create shared community contributions between users. The local store is not a backend, and local persistence must not be described as realtime or cross-user persistence. Backend, authentication, authorization, moderation, and realtime work remain deferred until explicitly approved.

A human-tension Space can be opened in the frontend preview even when no opposing public Vent is found, provided the Crash Out interpreter recognizes a meaningful tension. In that case, no match is claimed or highlighted. Clearly labelled fictional prototype experiences populate the preview so the wider experience-led environment can be evaluated before shared backend data exists.
