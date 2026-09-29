# Ventvo

> **VENT your thoughts. FIND your people. FEEL understood.**

Ventvo is a privacy-first social experience built around authentic expression, intentional interaction, and meaningful human connection.

Ventvo is not a popularity feed, a Reddit clone, or a conventional anonymous posting app.

The core idea is simple:

> **A person should be able to release what they are carrying, control how others meet it, and discover that they are not alone.**

## The Product Loop

```text
Finding Your Voice
        ↓
      Seed
        ↓
      Voice
        ↓
   Voice Space
        ↓
   ┌────┴────┐
   ↓         ↓
Crash Out   Vent
(private)    ↓
             Space
              ↓
       ┌──────┴──────┐
       ↓             ↓
 Just Listen   Open Discussion
       ↓             ↓
     Heard      Echo / Echo Note
       └──────┬──────┘
              ↓
          Resonance
              ↓
    Threads / Maps / Connection
              ↓
       Voice Evolution
```

See [`PRODUCT_SYSTEM.md`](PRODUCT_SYSTEM.md) for the canonical product map.

## Ventvo Voice

A Ventvo Voice is the anonymous identity a person carries inside Ventvo.

It is not a personality test and not a conventional profile.

A Voice begins with a **Voice Seed** and changes through experience.

The current language contains nine Seeds:

- **VAELOR ◇** — Expression — giving an inner thought form
- **NYVEN ∿** — Resonance — recognizing yourself in another experience
- **AUREN ✦** — Becoming — change through experience
- **SENYA ○** — Being heard without needing an answer
- **ORVAN △** — An experience that has been lived
- **ELVAE ≈** — Recognition between two experiences
- **NARETH ◌** — The quiet space between expression and response
- **VEYRA ✧** — The trace an experience leaves behind
- **KAVEN ⟡** — The meeting point between different perspectives

Every Seed has its own identity and manifestation. VAELOR is the reference experience, not the only Voice.

## Finding Your Voice

New users are not asked to define themselves before they begin.

The current first-run path is:

```text
Welcome
  ↓
Authentication foundation
  ↓
Finding Your Voice
  ↓
Seed discovery
  ↓
Seed manifestation
  ↓
Voice reveal
  ↓
Your Voice
  ↓
First moment
```

The discovered Seed is persisted as the beginning of the Voice.

## Vents

A **Vent** is a thought, feeling, idea, experience, opinion, or moment intentionally released into Ventvo.

A Vent creates a Space that tells other people how the moment should be experienced.

Current interaction modes are intentionally limited to two:

### Just Listen

For moments where the creator wants to be heard without advice, debate, or conversation.

- Heard/presence interaction
- Resonance
- No Echo
- No Echo Note
- No discussion composer

### Open Discussion

For moments where the creator welcomes perspectives and conversation.

- Resonance
- Echo
- Echo Notes
- Discussion

Open Discussion is not intended to become a conventional comment section.

## Crash Out

Crash Out is a **private release path**, separate from Vents.

It is not a diary, notes app, therapist, or generic matching workflow.

Crash Out asks:

> **What is another side of what I am experiencing?**

This is intentionally different from **Find People Who Understand**, which asks:

> **Who has experienced something like me?**

### Experience Representation

Ventvo should understand a Crash Out through:

- Situation
- Human Tension
- Position
- Direction
- Need / Desire
- Emotional State
- Context
- Intensity

The primary Crash Out signals are **Human Tension + Position + Direction**.

A Crash Out may contain multiple experience atoms. Ventvo should identify the strongest opposition-worthy atom instead of forcing an entire paragraph into one category.

### Meaningful Opposition

A valid encounter requires a shared human tension, opposing positions or directions, semantic evidence that the relationship is real, useful contextual support where appropriate, safety/privacy eligibility, and sufficient confidence.

Different topics, different emotions, literal antonyms, or random disagreement are not enough. Context can support opposition but cannot create it.

### No forced match

If no meaningful opposite exists, Ventvo must not manufacture one.

> **You let it out.**  
> Nothing on the other side surfaced yet.

### Privacy

The raw Crash Out remains private. It must never be published merely so Ventvo can discover an opposing experience.

If delayed encounters are introduced later, only a privacy-safe representation should be retained for matching, subject to an explicit retention/deletion design. Deleting the Crash Out must remove its matching representation.

### Prototype direction

The current CrashOutOppositeExperienceService is prototype scaffolding, not the final intelligence layer.

Target architecture:

CrashOutExperienceInterpreter
→ ExperienceRepresentation
→ CrashOutOppositionEngine
→ Candidate Eligibility
→ CrashOutEncounter

### Encounter UX

The encounter should describe the relationship rather than expose an algorithmic result.

> **You wanted someone to notice.**
>
> Someone else wanted to be left alone.
>
> *Two sides of needing people.*

Do not call another person “your opposite”. Do not automatically add follows, likes, messages, comments, or connection requests.

### Product separation

- **Find People Who Understand** → similarity / understanding.
- **Resonance** → meaningful connection.
- **Crash Out** → meaningful opposition.
- **Echo** → expression caused by another experience.

Crash Out may share safety, privacy, moderation, and repository infrastructure with Resonance, but its defining matching semantics are separate.

## Resonance

Resonance is the heart of Ventvo's connection model.

It is not:

- a Like
- a follower count
- a popularity score
- an engagement metric

Resonance asks:

> **Did this moment connect with something in me?**

The current prototype has a deterministic Resonance foundation with connection lifecycle, Threads, Maps, discovery, and Space integration. Production backend enforcement is still future work.

## Feed and Moments

The Feed is a discovery layer, not the purpose of the product.

The intended relationship is:

```text
Space
  ↓
Meaningful activity
  ↓
Moment
  ↓
Feed
  ↓
Space context
  ↓
Resonance
```

The goal is to help people encounter meaningful moments and return to their context, rather than endlessly consume disconnected posts.

## Voice Evolution

A Voice evolves through actual activity rather than XP, levels, or badges.

Current lifecycle:

```text
Seed → Expression → Resonance → Becoming
```

The lifecycle is derived from real Voice activity and is presented as a journey, not a reward system.

## Worlds and Events

Ventvo's longer-term vision includes **Worlds**: collective spaces with purpose, pulse, memory, and evolving identity.

Future **Events** can build on the same language, but Events are not currently an implemented standalone domain. They should only be introduced when they strengthen the Voice → expression → connection system.

## Privacy and Safety

Ventvo separates private account identity from the public Voice.

The Flutter prototype must never be treated as the final security boundary. Production systems must enforce:

- authentication
- authorization
- ownership
- privacy
- visibility
- moderation
- reporting
- abuse prevention
- rate limiting
- secure storage and deletion

No secrets, credentials, private tokens, or service-account files belong in the repository.

## Technology

- Flutter
- Dart
- Riverpod
- GoRouter
- Local persistence / mock repositories during prototype development
- Supabase planned for production backend services

Production backend work is intentionally deferred until the domain model and privacy boundaries are stable.

## Architecture

```text
lib/
├── core/
├── features/
│   ├── auth/
│   ├── onboarding/
│   ├── ventvo_voice/
│   ├── home/
│   ├── vents/
│   ├── feed/
│   ├── spaces/
│   ├── discussion/
│   └── crash_out/
└── systems/
    └── resonance/
```

Relevant documentation:

- [`AGENTS.md`](AGENTS.md) — agent and engineering rules
- [`PRODUCT_SYSTEM.md`](PRODUCT_SYSTEM.md) — canonical product flow
- [`PRODUCT_VISION.md`](PRODUCT_VISION.md) — long-term product vision
- [`PRODUCT_DECISIONS.md`](PRODUCT_DECISIONS.md) — recorded decisions
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — technical architecture
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — domain model
- [`RESONANCE_SPEC.md`](RESONANCE_SPEC.md) — Resonance architecture
- [`VENTVO_PRINCIPLES.md`](VENTVO_PRINCIPLES.md) — product principles
- [`SECURITY_HANDBOOK.md`](SECURITY_HANDBOOK.md) — security rules
- [`ENGINEERING_HANDBOOK.md`](ENGINEERING_HANDBOOK.md) — development workflow
- [`CHANGELOG.md`](CHANGELOG.md) — project history
- [`DEVLOG.md`](DEVLOG.md) — development log

## Development Rules

Work on `development` first.

For meaningful changes:

```text
Inspect
  ↓
Plan
  ↓
Implement
  ↓
Test
  ↓
Review
  ↓
Document
  ↓
Commit
```

Before reporting a change as clean, run:

```bash
git pull origin development
flutter analyze
flutter test
```

## Current Focus

The immediate goal is not to add every future idea.

It is to make the existing Ventvo loop feel like one product:

**Voice → Vent → Space → Resonance → Connection → Evolution**

Depth comes before breadth.

---

## North Star

> **Build something people can trust with their thoughts.**

## Crash Out Experience Threads

Crash Out now has a deeper product direction beyond a single opposite encounter.

A Crash Out may become the starting point of an **Experience Thread**: a living collection of related human experiences that emerge around the tension revealed by the Crash Out.

An Experience Thread is deliberately **not**:
- a group
- a room
- a comment section
- a conventional chat
- a people-matching surface
- a public profile relationship

It should feel conversational because people can respond to experiences, but the object being exchanged is always the **experience itself**.

A thread may unfold like:

```
Crash Out
    ↓
Opposite Experience
    ↓
Response Experience
    ↓
Related Crash Out
    ↓
Another Response
    ↓
...
```

People do not need to know one another personally. The system should let experiences find and respond to other experiences while keeping the human relationship secondary.

The experience chain, not a room or member list, is the primary object.

### Crash Out Interaction Boundary

Crash Out should not become an option-heavy workflow. After an opposing experience appears, the product should create room for the experiences to continue encountering one another rather than asking the user to choose from a menu of actions.

Responses should feel like texting because they are direct and sequential, but they should not turn Crash Out into a conventional messaging product.

The intended distinction is:

- **Find People Who Understand** → discover people/experiences through similarity.
- **Crash Out** → fall into experiences through meaningful opposition.
- **Experience Thread** → let related and opposing experiences continue to meet.
- **Resonance** → a separate expression of meaningful connection.

The product should preserve anonymity, privacy, consent, and the absence of popularity mechanics while this direction is explored.
