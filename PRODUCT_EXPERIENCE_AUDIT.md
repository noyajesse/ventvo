# Ventvo Experience Audit — 2026-09-20

Branch: `development`

This audit compares the current implementation against the locked product architecture:

```
Moment → Echo → Resonance → Thread → Map
```

## Executive finding

The existing code already contains substantial domain infrastructure for Resonance, Threads, Maps, Echoes, Voice ownership, lifecycle validation, privacy/safety policies, and Map↔Thread integration.

The main problem is no longer missing backend/domain scaffolding.

The main problem is **product-language and UX architecture drift**: the implementation still presents several concepts as a conventional connection-management system, while the new product model treats experiences as the center and makes Resonance, Threads, and Maps progressively emerge around them.

Therefore we should **refactor the experience, not throw away the Resonance foundation**.

---

# 1. Current architecture vs target architecture

## Current visible model

The repository currently exposes a Resonance hub with separate destinations for:
- Connections
- Threads
- Maps
- Gatherings

The Space flow also contains a Resonance section and a direct relationship pathway.

## Target model

The user should primarily experience:

```
Experience
  ↓
Echo ripple
  ↓
Resonance
  ↓
Thread
  ↓
Map
```

Connection is an optional human relationship that can emerge after mutual Resonance.

## Audit result

**Domain foundation: strong.**

**User-facing hierarchy: needs redesign.**

The current feature navigation is too system-centric. The product should become experience-centric.

---

# 2. Space / Moment audit

## What is already good

The Space model correctly preserves:
- creator intent
- Just Listen vs Open Discussion
- Echo restrictions
- Space context
- Moment discovery
- Resonance entry

The existing Space screen is still the correct contextual home for a Moment.

## What is missing

A Moment should become the explicit center of the experience.

The current UI should evolve toward:

**Moment**
- original expression
- Voice mark
- Space context
- Echo ripple
- Resonate action
- Thread/Map context when available

Instead of presenting Resonance as a separate system section that feels appended to the Space.

## Decision

Do not remove Space.

Refocus Space around the Moment and its surrounding activity.

---

# 3. Echo audit

## What is already good

Echo already has:
- its own model
- Voice ownership
- source experience context
- Open Discussion restrictions
- persistence
- an Echo→Resonance integration point

## Critical conflict

`EchoResponseResonanceService.connectEcho()` currently:
1. creates a response connection
2. immediately accepts it
3. immediately activates it
4. resolves the Echo relationship

That makes an explicit Echo automatically create an active relationship pathway.

This conflicts with the locked product decision:

> Echo is not automatically Resonance, and Resonance is not automatically a relationship.

## Required redesign

Echo creation should create an **Echo**.

It may provide evidence that an experience is related, but it should not automatically:
- accept a connection
- activate a relationship
- open a relationship
- manufacture mutual Resonance

The service should be redesigned around **evidence/suggestion**, with explicit Resonance remaining a user action.

This is the highest-priority domain correction.

---

# 4. Resonance action audit

## Current behavior

`space_resonance_section.dart` calls `suggestConnection()` when the user presses Resonate.

The internal connection remains a ResonanceConnection and can later transition through lifecycle states.

## What is good

The implementation already has:
- Voice ownership checks
- source/target Voice IDs
- lifecycle validation
- participant validation
- duplicate protection
- privacy/safety policy hooks

## UX conflict

The current UI exposes lifecycle state too directly:

- Resonate
- Resonating
- Resonance closed
- Resonance blocked
- relationship opening

The product should instead communicate human meaning.

## Target UX

Before action:

> **Resonate ∿**

After action:

> **Resonated ∿**

If mutual:

> **There’s resonance here.**

Only then:

> **Open a connection**

The user should not feel like they submitted a friend request.

---

# 5. Relationship audit

## Current architecture

The repository already has:
- Resonance relationship screen
- conversation screen
- connection screen
- relationship formation service
- lifecycle transitions

## Conflict

The relationship layer currently sits too close to the initial Resonance action.

The target architecture is:

```
Moment
  ↓
Resonance
  ↓
Mutual Resonance
  ↓
Optional connection invitation
  ↓
Connection
  ↓
Conversation
```

The relationship screen should therefore become a **later-stage destination**, not the natural next screen after one Resonance.

## Decision

Keep the relationship domain.

Change when it becomes reachable.

---

# 6. Threads audit

## What is already good

The repository already has strong Thread infrastructure:
- formation policy
- formation service
- integrity policy
- reconciliation service
- evolution policy
- discovery service
- Thread detail screen
- Map↔Thread integration

This should be reused.

## UX conflict

The current Thread UI still exposes technical relationship data too directly. Existing Map Thread cards can show Voice marks rather than a human-readable shared-experience story.

Target:

> **Not Being Understood**
>
> These experiences touch on feeling unseen or difficult to explain.

Then:

**Moment → Moment → Moment**

The Thread should feel like a story/path, not a connection graph.

## Decision

Keep the Thread domain and formation policies.

Redesign:
- naming presentation
- descriptions
- Thread detail
- Map Thread cards
- navigation into Moments

Do not rebuild the underlying Thread engine unless the audit of specific policies reveals a domain bug.

---

# 7. Maps audit

## What is already good

The current Map implementation already has:
- Map formation
- Map integrity
- Map reconciliation
- Map↔Thread integration
- experience resolution
- interactive constellation
- Thread access
- privacy/safety hooks

This is valuable foundation.

## Major UX conflict

The current Map is **Constellation-only plus supporting cards**.

The locked product model requires:

**Constellation + Landscape = the same Map.**

The current Map detail also exposes:
- “RESONANCE MAP”
- “Some experiences find each other.”
- “A wider landscape formed from meaningful Resonance.”
- “THE EXPERIENCES CONVERGE”
- “PATHS THROUGH THIS LANDSCAPE”
- Gathering discovery

The language is still system/connection-centric.

## Required redesign

Map detail becomes a true Hybrid Map:

### Constellation
Organic visual landscape.

### Landscape
Readable interpretation of the exact same Map state.

Shared state:
- selected Moment
- selected Thread
- selected cluster
- current Map

The Constellation must feel less like a node graph.

The existing CustomPainter can be retained as a foundation, but its visual language and interaction model should be redesigned.

---

# 8. Gatherings audit

## Current implementation

Maps currently surface a Gathering cluster and can lead users into Gathering entry/screens.

## Product decision

Gatherings are **not part of the core Moment → Echo → Resonance → Thread → Map architecture**.

They are a later relationship/community mechanism.

They should not dominate Map discovery.

## Decision

Do not delete the Gathering system yet.

Remove it from the primary Map experience while the core architecture is being rebuilt.

It can later reappear as an optional outcome of a mature landscape.

---

# 9. Resonance Hub audit

## Current implementation

The Voice Resonance Hub exposes separate entries for:
- Connections
- Threads
- Maps
- Gatherings

## Problem

This teaches the user the internal architecture instead of the product experience.

A user should not need to think:

> “Should I open Connections, Threads, or Maps?”

Instead, discovery should naturally lead them there.

## Target

The Resonance Hub should eventually become a quieter **Resonance/landscape entry point**, with emphasis on:
- experiences that resonated
- mutual Resonance
- landscapes forming
- optional connections

Threads and Maps remain accessible, but not as a technical dashboard.

---

# 10. Find People Who Understand audit

The current repository architecture references the concept, but the target product model is stronger than the existing visible implementation.

The target flow is:

```
Find People Who Understand
        ↓
Experiences
        ↓
Moment
        ↓
Resonate
        ↓
Optional Thread / Map exploration
```

The feature must not become:
- a people directory
- profile browsing
- compatibility scores
- follower recommendations
- swipe cards

It should surface experiences first and Voices second.

## Decision

Treat Find People Who Understand as an **experience discovery layer**, not a people directory.

This should be implemented after the Moment/Resonance redesign so the feature uses the correct primitives.

---

# 11. Feed audit

The existing README correctly defines Feed as a discovery layer rather than the purpose of Ventvo.

That principle remains correct.

The Feed should surface **Moments**, not compete with Maps or become a social feed.

Target:

```
Feed
  ↓
Moment
  ↓
Space
  ↓
Echo / Resonance
  ↓
Thread / Map
```

The Feed does not need a new social ranking model.

---

# 12. Architecture changes required

## Keep

- ResonanceEngine
- ResonanceConnectionService
- lifecycle validation
- Voice ownership
- Thread formation policy
- Thread integrity policy
- Thread reconciliation
- Map formation policy
- Map integrity policy
- Map reconciliation
- Map↔Thread integration
- Space architecture
- Echo persistence
- privacy/safety vetoes

## Redesign

- Echo→Resonance orchestration
- Resonance UX states
- Relationship entry timing
- Resonance Hub presentation
- Thread presentation
- Thread detail
- Map detail
- Map Constellation visual language
- Map Landscape View
- Find People Who Understand
- Moment-centered Space presentation

## De-emphasize / temporarily remove from primary UX

- Gatherings as a Map-first action
- connection-management language
- technical lifecycle labels
- Voice/connection counts as primary information
- “Resonance Map” as a technical-sounding label

---

# 13. Recommended implementation order

We should not change everything simultaneously.

### Phase 1 — Resonance semantics
1. Redesign Echo→Resonance orchestration.
2. Ensure Echo does not automatically activate a relationship.
3. Make explicit Resonance the user action.
4. Preserve lifecycle and policy tests.

### Phase 2 — Moment-centered Space
1. Make Moment the visual anchor.
2. Place Echo ripple around it.
3. Make Resonate a natural Moment action.
4. Keep Space context visible.

### Phase 3 — Mutual Resonance
1. Surface one-way Resonance quietly.
2. Detect mutual Resonance.
3. Only then offer connection.
4. Make relationship/conversation secondary.

### Phase 4 — Threads
1. Redesign Thread detail.
2. Replace technical connection presentation with experience paths.
3. Improve Thread naming/description presentation.
4. Keep existing formation engine.

### Phase 5 — Hybrid Maps
1. Redesign Map model presentation.
2. Add Landscape View.
3. Make Constellation and Landscape share state.
4. Redesign Constellation visuals.
5. Remove Gathering prominence.

### Phase 6 — Discovery
1. Redesign Find People Who Understand.
2. Make experiences the discovery object.
3. Connect discovery → Moment → Thread → Map.

---

# 14. First implementation target

The first code change should **not** be the Map UI.

The first target is:

> **Fix Echo → Resonance semantics so an Echo cannot silently become an active relationship.**

Why?

Because every layer above it depends on correct evidence.

If Echo automatically creates an active relationship, then:
- Resonance evidence becomes polluted
- Thread formation can be triggered incorrectly
- Maps can contain relationships that users never intentionally formed
- the new product architecture becomes inconsistent at its foundation

Therefore the correct order is:

**Fix the meaning of Echo first → then build the experience UI on top of clean evidence.**

---

# 15. Audit conclusion

Ventvo does not need a rewrite.

It has a substantial domain foundation already.

The redesign should be a **product-layer correction over a strong domain foundation**.

The most important transition is:

### Current mental model

> Voice → Vent → Space → Resonance → Connection → Threads/Maps

### Target mental model

> **Experience → Echo → Resonance → Thread → Map**

with:

> **Connection as an optional human relationship that can emerge from mutual Resonance.**

This is the architecture we should implement against from this point forward.
