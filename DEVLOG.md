### Echo Voice Ownership and Lifecycle Fix

Date: 2026-09-19  
Branch: development

- Echo and SpaceResponse now retain the optional Voice ID of the Voice that created the response.
- Echo creation passes the local Voice ID into the response flow instead of relying on the public Voice mark.
- Response Resonance carries the responder Voice as the target participant and only accepts/activates when that Voice is the actor.
- The originating Vent owner can be carried as the source participant when available.
- Space Resonance now creates a suggested connection without pretending the other Voice has already accepted it.
- Local Resonance demo connections now use stable demo Voice IDs and target-side acceptance.
- Resonance test doubles were updated for the explicit source/target Voice ID parameters.

Verification:
- GitHub-side code inspection completed.
- Flutter analyzer/tests have not been run from this environment; run `flutter analyze` and `flutter test` locally.

### Honest Local Resonance State

Date: 2026-09-19  
Branch: development

- Suggested Resonances now distinguish the local target Voice from the local source Voice.
- A source Voice sees “Waiting for their response”; only the target Voice sees the acceptance action.
- Accepted/active connections can only be opened from the Your Resonances surface when the local Voice is an explicit participant.
- The relationship screen only exposes activation when the local Voice participates in the connection.
- This avoids implying that a local prototype has simulated a second person's acceptance or participation.
- Missing participant Voice identity prevents acceptance at the service boundary.
- The prototype still uses local/in-memory state; real recipient delivery and acceptance remain backend responsibilities.

### Resonance Participant Authorization Boundary

Date: 2026-09-19  
Branch: development

- Lifecycle actions now require an actor Voice ID.
- Only the target Voice can accept a suggested Resonance.
- Either participating Voice can activate, close, or block a connection.
- Active conversations now verify that the opening Voice is a participant.
- Direct messages now verify that the sender Voice belongs to the conversation participants.
- Connection and conversation participant IDs are derived from the existing Resonance relationship rather than allowing the UI to invent participant identity.
- The UI now orients an existing connection around the local Voice and its counterpart before opening the relationship or conversation.
- These checks are prototype-side domain guards; production must enforce the same boundary server-side through authenticated account authorization and RLS.
- No private conversation content is converted into public discovery or Thread material by this change.

### Explicit Voice Identity for Resonance Connections

Date: 2026-09-19  
Branch: development

- Added optional explicit Voice ownership to Vent records through `ownerVoiceId`.
- Vent persistence now retains the owning Voice ID, while older stored Vents remain compatible when the field is absent.
- Resonance discovery candidates now carry the Voice ID associated with their originating Vent.
- Resonance connections now preserve both originating experience IDs and the Voice IDs of the participants.
- Active Resonance conversations now carry the source and target Voice IDs alongside their originating experience IDs.
- Message-level `senderVoiceId` remains the identity used for local message ownership/alignment.
- Experience identity and Voice identity remain separate: experiences explain why a Resonance exists; Voice IDs identify the participants in the resulting relationship.
- Thread formation remains experience/connection based and is not rewritten around Voice IDs.
- The prototype remains local/in-memory for Resonance and conversation storage; production persistence will enforce participant authorization using these explicit Voice identities.

### Active Connection: Direct Conversation Foundation

Date: 2026-09-19  
Branch: development

- Added a dedicated Resonance conversation domain boundary with Conversation and Message models.
- Added a repository/service/provider layer for local in-memory direct conversations.
- A conversation can only open for an ACTIVE Resonance; accepted connections still pass through activation first.
- The conversation screen preserves the originating Resonance context and supports ordinary one-to-one text messaging.
- Active Resonances now open the direct conversation from Your Resonances.
- Activating an accepted Resonance now continues directly into the conversation.
- Closing and blocking remain Resonance lifecycle operations; the conversation returns to its parent screen when that relationship is closed or blocked.
- Private conversation content is not indexed into public discovery or silently exposed as Resonance discovery material.
- Threads remain automatic and are not manually created from messages.
- The local prototype still uses in-memory conversation storage and does not yet represent a real remote second Voice receiving messages.
- Before production persistence, conversation participants need to be backed by explicit Voice identities rather than only experience endpoints.

## Active Connection: Direct Conversation + Automatic Threads

Date: 2026-09-19
Branch: development

Product decision:

After a Voice accepts a Resonance, the resulting Active Connection may use normal direct messaging. We are not trying to redesign basic human conversation into a special messaging mechanic.

The distinction is how the conversation is reached:

```text
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

The user can therefore talk naturally with the other Voice.

The originating Moments/experience remain visible as context so the connection retains the reason the two Voices resonated.

### Thread behavior

Threads remain an automatic Resonance-domain system.

Users do not manually create Threads during conversation.

Instead:

```text
Active Connection
      ↓
Relationship / experience evidence
      ↓
Existing Thread Formation / Evolution Policy
      ↓
Enough meaningful evidence?
   ├── NO → conversation remains a conversation
   └── YES → form or extend Thread
```

A conversation does not automatically turn every message into a Thread participant. Thread formation/evolution continues to require meaningful evidence, accepted or active relationships, existing privacy/safety rules, and the established Resonance policies.

This preserves the original Ventvo idea:

- Direct conversation is for the people.
- Resonance explains why the connection exists.
- Threads emerge behind the scenes from meaningful relationship evidence.
- Maps can later represent broader landscapes of related Threads.
- Gatherings remain an optional group experience that can emerge from genuine relationships.

Important boundary:

- Ventvo is not adding a follower/friend system.
- Resonance is not being replaced by DMs.
- DMs are not the discovery mechanism.
- Users are not required to manually create Threads.
- Private conversation must not silently become public discovery material.
- No arbitrary group chat or fixed three-person requirement is introduced.

Engineering direction:

The next implementation should inspect the existing active connection, connection model/service, local repository, and Thread formation/reconciliation paths before adding any new code. The goal is to connect a natural conversation layer to the existing Resonance domain rather than building a second messaging or Thread system.

Verification:

- Product decision documented in RESONANCE_SPEC.md.
- No Flutter verification claimed from GitHub tooling.

---

## Active Resonance Entry Point

Date: 2026-09-19
Branch: development

Completed:
- Connected accepted and active Resonances in Your Resonances to the existing ResonanceRelationshipScreen.
- Changed Enter Connection so it opens the relationship experience instead of activating the connection immediately.
- Added an Open Connection action for active Resonances.
- Kept activation behind the ResonanceConnectionService lifecycle transition.
- Reused the existing relationship screen's controls for continuing, closing, blocking, and exploring related Threads.

Product flow:

```
Find People Who Understand
        ↓
Discover related experience
        ↓
This resonates with me
        ↓
Resonance suggested
        ↓
Your Resonances
        ↓
Accepted
        ↓
Enter Connection
        ↓
Resonance relationship
        ↓
Continue with this Resonance
        ↓
Active connection
        ↓
Explore related Threads
```

Boundary:
- The active experience remains grounded in the shared experiences that created the Resonance.
- No generic DM system was introduced.
- Connection activation remains controlled by ResonanceConnectionService and ResonanceConnectionLifecycle.
- The current local prototype still cannot represent a real second Voice receiving and accepting a connection.

Verification:
- Source changes were reviewed through the GitHub repository on the development branch.
- Flutter analyze/test commands have not been claimed as executed through GitHub tooling.

Next engineering focus:
- Define the deeper shared-experience interaction for an active connection before extending into new Gathering behavior.

---

## Resonance Connection Continuation

Date: 2026-09-19
Branch: development

Completed:
- Added a dedicated Your Resonances screen so a suggested connection no longer ends at the confirmation message.
- The sender can now see a Resonance connection in the local prototype state while waiting for the other Voice.
- Added recipient-side acceptance and activation controls to the shared connection-state presentation so the existing suggested → accepted → active lifecycle has a UI boundary ready for multi-Voice persistence.
- Added Your Resonances to the Resonance hub.
- After leaving a Resonance, the user can continue directly to Your Resonances instead of being returned only to Find People.

Product flow:

```
Find People Who Understand
        ↓
Discover related experience
        ↓
This resonates with me
        ↓
Resonance suggested
        ↓
Your Resonances
        ↓
Waiting for their response
        ↓
Accepted
        ↓
Active connection
        ↓
Future shared connection experience
```

Important boundary:
- The current prototype is still local/in-memory and has one local Voice, so it cannot demonstrate a real second user's acceptance yet.
- No fake recipient or automatic acceptance was introduced.
- Backend persistence/authentication must later identify the target Voice and deliver the pending Resonance to that Voice.
- The active connection experience is intentionally not being replaced with a generic DM system; the next product step should be a shared-experience interaction that can feed Threads and later Gatherings.

Next engineering focus:
- Define the real active-connection experience.
- Then connect accepted/active relationships to Thread formation without bypassing Resonance rules.

---

## Resonance Connection Lifecycle

Date: 2026-09-13
Branch: development

Completed:
- Added a reusable `ResonanceConnectionLifecycle` finite-state policy.
- Defined controlled connection states: `suggested`, `accepted`, `active`, `closed`, and `blocked`.
- Defined valid transitions and rejected arbitrary state changes.
- Added `updateConnection()` to the Resonance repository and engine contracts.
- Implemented local connection updates through `LocalResonanceRepository`.
- Added lifecycle orchestration to `ResonanceConnectionService`.
- Added connection lifecycle tests covering valid and invalid transitions.
- Updated test fakes to satisfy the expanded repository and engine contracts.

Current lifecycle:

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

Architecture:

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
 ↓
Local / Backend implementation
```

Engineering principle:
- Connection state is a domain concern, not a UI concern.
- The lifecycle behaves as a finite state machine so future Threads, Maps, safety controls, and backend persistence can reuse the same rules.
- Feed, Space, and Crash Out do not receive their own connection/matching logic. They consume the shared Resonance system.

Product boundary:
- `Just Listen` and `Open Discussion` remain the only current Vent interaction modes.
- Resonance is the central connection system; the small-group/three-person experience remains only one possible product presentation powered by Resonance.
- Crash Out matching remains outside Crash Out itself and will use the shared Resonance system when that pathway is implemented.

Verification:
- `flutter analyze` passed with no issues.
- `flutter test` passed all tests.

Next engineering focus:
- Continue building the Resonance connection foundation without prematurely introducing backend or AI matching.
- Next work should build on the lifecycle rather than creating parallel connection state or matching systems.

---

## Resonance-Powered Feed Foundation

Date: 2026-09-10
Branch: development

Completed:
- Replaced the Feed's previous hard-coded discovery selection with a Feed-specific application service that consumes the shared Resonance discovery boundary.
- Added candidate indexing through the `ResonanceRepository` contract.
- Feed now prepares discoverable Vent experiences as Resonance candidates and asks Resonance to rank candidates instead of implementing matching inside Feed.
- Added temporary local discovery fixtures solely to exercise the real Resonance path before backend discovery exists.
- Kept private and unsafe Vents outside discovery through the shared Resonance repository boundary.
- Added unit coverage for Feed Resonance orchestration and privacy filtering.

Architecture:

```text
Feed Provider
    ↓
FeedResonanceService
    ↓
VentResonanceDiscoveryService
    ↓
Resonance Engine
    ↓
Resonance Repository
```

The temporary fixtures are development scaffolding, not the final content source. They can be removed when backend discovery provides real candidate Vents.

Important product boundary:
- Feed does not own matching logic.
- Resonance remains the central human-connection system.
- No likes, popularity ranking, streaks, or engagement scoring were introduced.
- The current Vent interaction model remains exactly `Just Listen` and `Open Discussion`.

Verification:
- Source and test files were inspected on the `development` branch.
- Flutter commands have not been claimed as executed through GitHub tooling.

## Resonance Provider/Application Boundary

Date: 2026-09-10
Branch: development

Completed:
- Added the shared `resonanceRepositoryProvider`.
- Added the shared `resonanceEngineProvider`.
- Added the application-facing `ventResonanceDiscoveryServiceProvider`.
- Kept product features dependent on interfaces/application services rather than constructing Resonance infrastructure directly.
- Added provider wiring tests.

Architecture boundary:

```text
UI / Feature
    ↓
Application Provider
    ↓
VentResonanceDiscoveryService
    ↓
ResonanceEngine
    ↓
ResonanceRepository
    ↓
Local / Backend implementation
```

The current providers use the local deterministic implementation. Riverpod allows the repository to be overridden later when backend persistence is introduced without forcing Feed, Space, or Crash Out to change their application-facing dependency.

Verification:
- Provider and test files were inspected on the `development` branch.
- Local Flutter execution is reserved for the Resonance milestone test pass.

Next engineering focus:
- Integrate Resonance discovery into Feed first, while keeping the existing Feed presentation simple.
- Then reuse the same application boundary in Space.

---

## Resonance Discovery Bridge

Date: 2026-09-10
Branch: development

Completed:
- Added `LocalResonanceRepository` behind the existing `ResonanceRepository` contract.
- Added candidate upsert/removal and connection persistence for the local prototype.
- Added a discovery boundary that excludes candidates carrying privacy or safety signals.
- Added `VentResonanceDiscoveryService` to convert a discoverable Vent plus its Space into a `ResonanceQuery`.
- Kept matching inside the shared Resonance system rather than inside Feed, Space, or Crash Out.
- Added unit coverage for repository filtering/persistence and the Vent-to-Resonance discovery bridge.

Architecture boundary:
- Vent signal generation interprets the experience.
- The discovery service builds the Resonance query.
- The Resonance Engine ranks candidates.
- The repository controls which candidates are available to discovery.
- Private or unsafe content is blocked before it can become a discovery result.
- This remains a local deterministic foundation; backend persistence and semantic/AI matching are deferred.

Verification:
- Source and test files were inspected on the `development` branch.
- Local Flutter execution is still reserved for the upcoming milestone test pass.

Next engineering focus:
- Build the first Resonance provider/application boundary so product features can consume Resonance without constructing engines or repositories directly.
- Then integrate Resonance discovery into Feed and Space.

---

## Resonance Signal Generation Foundation

Date: 2026-09-10
Branch: development

Completed:
- Added `VentResonanceSignalGenerator` under the shared Resonance system.
- Converts a Vent plus its owning Space into deterministic, explainable Resonance signals.
- Added experiential signals such as starting over, loneliness, burnout, overthinking, uncertainty, loss, pressure, rejection, and change.
- Added semantic/context signals for common experience domains and Crash Out-originated Vents.
- Added the current Space interaction mode as an intent signal: `Just Listen` or `Open Discussion`.
- Added privacy and safety signals without mutating the underlying Vent.
- Added unit coverage for experiential/semantic extraction, interaction mode, Crash Out context, and privacy/safety metadata.

Architecture boundary:
- Signal generation lives in Resonance, not Feed, Space, Discussion, or Crash Out.
- The first implementation is deterministic and rule-based; AI/embeddings remain deferred until the core model is proven.
- This generator is designed to be reused by Feed, Space, and Crash Out through the shared Resonance system.

Verification:
- Source and test files were inspected on the `development` branch after creation.
- GitHub tooling does not execute local Flutter commands, so tests are added but are not claimed as locally executed.

Next engineering focus:
- Connect generated Vent signals to the existing Resonance repository/engine boundary.
- Then begin Resonance-powered discovery for Feed and Space.

---

## Current Vent Interaction Model — Correction

Date: 2026-09-10
Branch: development

Important product/architecture correction:
- The current Vent model has exactly two interaction modes: `Just Listen` and `Open Discussion`.
- These modes are owned by `Space`, because Space defines the interaction context and rules.
- `Vent` does not store a second interaction-mode field.
- The previous `VentInteractionMode` wording in this historical section is obsolete implementation documentation and must not be treated as the current model.
- Legacy five-option concepts such as Advice, Similar Experiences, Encouragement, and Celebrating are not part of the current product model.

Current flow:

```text
Vent creation
↓
Choose Space mode
↓
Space owns interaction context
↓
Vent is created inside that Space
↓
Vent → Resonance signal generation
```

Resonance remains the central human-connection system. Matching/discovery logic does not belong inside individual features.

---

## Space Foundation Implementation

Date: 2026-08-25
Branch: development

Completed:
- Added a dedicated `Space` domain model.
- Limited Space modes to `Just Listen` and `Open Discussion`.
- Changed `Vent` to reference a `spaceId` instead of storing the interaction mode itself.
- Added local Space persistence alongside existing Vent persistence.
- Updated Vent creation so a Space is created with the Vent.
- Added the initial Space screen and Spaces screen.
- Added Space and Space Moment presentation widgets.
- Updated Feed expressions to enter their owning Space instead of routing directly to a generic discussion screen.
- Kept Just Listen and Open Discussion behavior distinct inside the Space experience.

Product boundary:
- This establishes the first real Space domain foundation.
- It does not claim that the final visual Space experience is complete.
- Moments, Resonance, Echo Notes, persistent discussions, backend persistence, and connection systems remain future work.
- No additional Space modes were introduced.

Development principle:
- Space owns the interaction mode so Vent and Space do not maintain duplicate sources of truth.

---

## Voice Space Hierarchy Refinement

Date: 2026-08-23

Completed:
- Refined Voice Space into a clearer hierarchy around the user's Voice identity.
- Grouped the experience into Your space, Your Vents, Private, and Express sections.
- Kept Create a Vent, Crash Out, Explore Feed, and Private Crash Outs as existing flows.
- Kept the current in-memory prototype architecture unchanged.

Product boundary:
- This is a presentation and information-hierarchy refinement, not a new social system.
- Resonance, Echo Notes, matching, persistence, and backend infrastructure remain outside this change.
- Existing Just Listen and Open Discussion Space semantics remain unchanged.

Development principle:
- Improve clarity of the existing Core Expression Foundation before introducing new systems.

---

## Product Direction Review - Ventvo Principles

Date: 2026-08-02

Completed:
- Reviewed Ventvo's core purpose and direction.
- Defined Ventvo as a connection system built around human moments, not a traditional social media platform.
- Created VENTVO_PRINCIPLES.md as the product decision filter for future features.

Key decisions:
- Voice remains the foundation instead of traditional profiles.
- Vents represent moments, not normal social posts.
- Connection is measured through Resonance instead of likes or popularity.
- Just Listen and Open Discussion now have different interaction rules.
- Just Listen allows Resonance but does not allow Echo Notes or Discussion.
- Open Discussion allows Resonance, Echo Notes, Discussion, and optional Crash Out.
- Echo Notes are reflections, not comments.
- Crash Out remains a temporary shared emotional space.

Development principle:
- Build only what supports Ventvo's core philosophy and avoid premature complexity.

---

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

The existing `DEVLOG.md` on `development` contains historical entries plus an older malformed/truncated documentation section. This update preserves the historical record while adding a correction at the top for the current Space-owned interaction model.

## Next Step

Continue with Resonance integration by connecting generated Vent signals to the existing repository/engine boundary. Do not add unrelated features or prematurely implement AI systems.


## Find People Who Understand

Date: 2026-09-19
Branch: development

Completed:
- Added an independent Find People Who Understand entry in Voice Space.
- The discovery flow starts from one of the user's own discoverable Vents.
- Matching is delegated to the shared VentResonanceDiscoveryService and deterministic Resonance engine.
- All of the user's own Vents are excluded from the candidate set.
- Results are limited to active, public, approved Vents before they are shown.
- Added an explicit Find People Who Understand action to the Crash Out fate screen; choosing it is the outward discovery step while the Crash Out itself remains private.
- Added Crash Out lifecycle tests covering private-by-default, conversion state, and letting go.

Boundary:
- Find People discovers experiences; it does not create a separate matching system.
- A private Crash Out is never indexed as a public candidate by this flow.
- Connection creation remains a Resonance responsibility.


## Resonance Connection Action

Date: 2026-09-19
Branch: development

Completed:
- Added the first user-facing connection step after Find People Who Understand discovers a meaningful public Vent.
- Added a Resonance connection screen showing the user's source Moment and the discovered Moment before any connection is created.
- The action re-validates the target through the shared VentResonanceDiscoveryService before creating a connection.
- Connection creation is delegated to ResonanceConnectionService.suggestConnection, preserving the existing suggested → accepted → active lifecycle.
- The UI records a suggested Resonance and explains that the other Voice can choose whether to accept it.
- Existing connections are reused instead of creating duplicates.

Boundary:
- No new matching algorithm or connection model was introduced.
- VentCard remains a general Moment presentation widget; the connection action is scoped to discovery results.
- Private Crash Outs are not used as connection sources, so this step does not expose private Crash Out content through Resonance connections.
- Backend persistence and the recipient-side acceptance experience remain future work.

## Resonance Relationship Formation Boundary

Date: 2026-09-19
Branch: development

Completed:
- Added a narrow relationship-formation orchestration service that reacts only to accepted or active Resonance connections.
- The orchestration checks both connection endpoints so formation can begin around whichever experience has enough evidence.
- Thread and Map creation remain delegated to their existing formation services and policies.
- Thread and Map formation now require explicit, distinct Voice identities for the participating experiences; multiple experiences from one Voice cannot manufacture a multi-Voice structure.
- Added tests for lifecycle gating, automatic formation orchestration, and same-Voice rejection.

Boundary:
- A single Resonance still cannot create a Thread or Map.
- Suggested, closed, and blocked connections do not trigger formation.
- Formation thresholds remain unchanged: meaningful accepted/active evidence, sufficient strength, and the existing privacy/safety vetoes still apply.
- Thread and Map remain relationship structures, not presentation shortcuts or fixed-size groups.
- Voice identity is now part of the evidence required to treat multiple experiences as multiple people.


---

## Ventvo Product Architecture — Moments, Echoes, Resonance, Threads, Maps

Date: 2026-09-20  
Branch: development

Product design milestone:

The core Ventvo experience architecture is now documented as a coherent system:

```
Moment → Echo → Resonance → Thread → Map
```

These are layers of meaning, not mandatory user steps.

- **Moment:** “This is what I'm carrying.”
- **Echo:** “Your experience made me express something of my own.”
- **Resonance:** “Your experience connects with something I carry.”
- **Thread:** “These experiences keep finding each other.”
- **Map:** “There is a larger landscape here.”

### Hybrid Map

Constellation and Text Landscape are two views of the same Map.

- **Constellation:** feel the landscape.
- **Landscape:** understand the landscape.

The Constellation must feel organic and intimate, not like a scientific network graph or data visualization.

### Product principles locked

- Experiences come before people.
- No follower graph, likes, popularity rankings, or Resonance scores.
- Resonance does not automatically create a relationship.
- Private Crash Outs and private conversations do not silently become public discovery material.
- Ventvo reveals meaningful patterns rather than manufacturing them.
- Technical lifecycle state remains internal where possible.
- AI may assist later, but must not invent psychological meaning or diagnoses.

### Authoritative product documents

- `RESONANCE_SPEC.md` — technical Resonance architecture plus the human Resonance product model.
- `THREADS_SPEC.md` — Thread product model.
- `MAPS_SPEC.md` — Map and Hybrid Map product model.

These documents are now part of the `development` branch source of truth for the redesign.

### Engineering note

The existing Resonance foundation should be audited against these product decisions before adding more UI or domain behavior. In particular, the current Echo→response orchestration and any automatic acceptance/activation behavior should be reviewed against the new consent-based Resonance model.

Verification:
- Documentation changes were written directly to the `development` branch.
- Flutter analyzer/tests have not been run from GitHub tooling.


---

## Product Experience Audit — 2026-09-20

Audited the current `development` implementation against the locked Moment → Echo → Resonance → Thread → Map architecture.

### Findings
- The Resonance/Thread/Map domain foundation is substantial and should be reused rather than rewritten.
- The largest mismatch is product-layer presentation: the current UI still exposes connection-management concepts instead of experience-first discovery.
- Echo currently auto-accepts and auto-activates a response Resonance connection; this conflicts with the new consent-based product model and is the first implementation target.
- Relationship screens should become later-stage destinations after mutual Resonance, not the natural result of one Resonance.
- Threads need to present shared experience paths rather than technical connection data.
- Maps already have a useful Constellation foundation, but need the locked Hybrid Map model: Constellation + Landscape as two views of the same Map.
- Gatherings should not dominate the core Map experience during this redesign.
- Find People Who Understand should be implemented as experience-first discovery, not people browsing.

### Source of truth
See `PRODUCT_EXPERIENCE_AUDIT.md` for the detailed audit and implementation order.

### Next implementation target
Fix Echo → Resonance semantics first, preserving existing lifecycle/policy infrastructure and tests.
