# Ventvo Implementation Roadmap

This roadmap is the engineering source of truth for what is already implemented, what is partial, and what comes next.

**Development rule:** frontend/domain work first. Production backend work stays deferred until the product boundaries are stable.

## Status

- **Done** — implemented in the current frontend/prototype
- **Partial** — foundation exists, but the user-facing system is incomplete
- **Next** — the next implementation target
- **Later** — intentionally deferred

---

## 1. Ventvo Voice

**Status: Done / ongoing polish**

Already implemented:
- Ventvo Voice identity model
- Voice Seed discovery
- Persistent Voice identity
- The established Voice names/marks
- Voice identity attached to Vent experiences and Crash Out conversation contributions
- Voice lifecycle foundation

Remaining:
- Continue UX polish and make Voice feel consistent across the whole app.
- Keep account identity separate from public Voice identity when backend work begins.

---

## 2. Vents and Spaces

**Status: Partial**

Already implemented:
- Vent creation
- Just Listen
- Open Discussion
- Space creation and navigation
- Local persistence/prototype interaction behavior
- Feed and Moment foundations

Remaining:
- Audit the current Vent → Space → Moment experience as one continuous flow.
- Finish Open Discussion UX around Echo/Echo Note.
- Remove prototype behavior that conflicts with the final product rules.
- Later: real persistence, ownership, authorization, moderation, and visibility enforcement.

---

## 3. Crash Out

**Status: Core text experience implemented; final frontend completion in progress**

Already implemented:
- Private Crash Out text release
- Local persistence
- Private Crash Out list
- Let Go deletion
- Human-tension representation
- Position + Direction modeling
- Deterministic experience interpretation prototype
- Meaningful-opposition discovery
- No-forced-match behavior
- Another-side encounter
- Experience Thread data model and local persistence
- Conversation-style replies
- Existing Ventvo Voice identities inside the thread
- Private reflection
- Reflection persistence
- Reopening an existing encounter from the Private area
- Legacy similarity-based Crash Out discovery removed
- Legacy Crash Out → Vent conversion lifecycle removed
- Focused no-encounter state

Still required before Crash Out is considered complete:
1. **Voice Crash Out** — real recording/input flow rather than the current placeholder.
2. **Edge-case handling** — very short/empty input, weak interpretation, multiple possible oppositions, duplicate encounters, and invalid/private candidates.
3. **Encounter lifecycle polish** — make returning to an encounter and continuing it reliable across the whole frontend.
4. **Reflection relationship** — decide and implement the exact boundary between private Reflection and a future Echo.
5. **Safety/privacy boundaries** — keep the prototype behavior explicit and prepare the data boundaries needed before backend matching.
6. **Tests** — expand coverage around interpretation, opposition thresholds, lifecycle, storage migration, and thread behavior.

Crash Out must remain:
- private
- experience-centered
- opposition-based
- free of forced matching
- free of likes/follows/comments/automatic connections
- separate from Find People Who Understand

---

## 4. Echo

**Status: Partial domain foundation; user-facing experience not complete**

Already implemented:
- Echo domain model
- Echo provider/storage
- Echo services
- Echo Note foundation
- Echo/Resonance integration infrastructure

Not yet complete:
- A clear user-facing Echo composer and interaction flow.
- The exact distinction between an Echo and a normal comment.
- Crash Out → Reflection → optional Echo relationship.
- Correct Echo → Resonance semantics.

Next:
- Finish the product meaning first.
- Then build the frontend Echo interaction.
- Echo must be a meaningful response to an experience, not a renamed comment.
- Creating an Echo must not silently create an active relationship.

---

## 5. Resonance

**Status: Partial / substantial prototype foundation**

Already implemented:
- Resonance models
- Candidate discovery
- deterministic scoring infrastructure
- Resonance lifecycle foundations
- Threads/Maps foundations
- Voice/Space/Vent integration points
- substantial test coverage

Remaining:
- Reconcile older prototype behavior with the current product decisions.
- Ensure Resonance remains meaningful connection rather than a generic engagement metric.
- Ensure Echo does not automatically become an active relationship.
- Finish the user-facing discovery and connection experience before backend implementation.

---

## 6. Feed and Moments

**Status: Partial**

Already implemented:
- Feed screen
- Vent/Moment discovery foundations
- Space navigation foundations

Remaining:
- Make Feed a discovery layer for meaningful Moments rather than an endless generic post feed.
- Strengthen Moment → Space context.
- Audit navigation and interaction against the current product architecture.

---

## 7. Privacy, Ownership, and Safety

**Status: Partial frontend foundation; production enforcement later**

Already implemented:
- private Crash Out local storage
- discoverability/visibility concepts on Vents
- safety/visibility fields and policies in parts of the prototype
- architecture documentation separating public and private domains

Remaining:
- ownership rules throughout the frontend
- explicit data boundaries
- deletion semantics
- moderation/reporting UX
- abuse/rate-limit architecture
- backend authorization

The Flutter client is never the final security boundary.

---

## 8. Backend

**Status: Later**

Supabase/backend work is intentionally deferred.

Before backend implementation:
- domain models must be stable
- privacy boundaries must be explicit
- ownership rules must be defined
- repository/service boundaries must be clear
- Crash Out matching retention/deletion must be designed
- Echo/Resonance semantics must be settled

Then:
- authentication/session architecture
- database schema
- row-level security/authorization
- repositories
- secure storage
- realtime where actually needed
- moderation/reporting infrastructure

---

## 9. Engineering Hardening

**Status: Ongoing**

For each meaningful feature:

Inspect → Plan → Implement → Test → Review → Document → Commit

Before calling a change clean, run the project's Flutter analysis and tests locally.

The GitHub integration used for repository changes does not provide the Flutter/Dart runtime, so repository edits must not be reported as locally tested unless a real Flutter environment has actually been run.

---

## Current Roadmap Order

The intended order from here is:

**Finish Crash Out frontend**
→ **Define/build Echo**
→ **Align Resonance with Echo**
→ **Finish Vent/Space/Moment UX**
→ **Finish Feed/Moment discovery**
→ **Privacy/ownership/security architecture**
→ **Backend/Supabase**
→ **Production hardening**

We should not jump ahead simply because a later system has some existing prototype code.

The goal is to make each layer coherent before building the next one.
