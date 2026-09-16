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

Crash Out is a private release path, separate from Vents.

```text
Voice Space
   ↓
Crash Out
   ↓
Release
   ↓
Fate
```

The user remains in control of what happens next:

- **Let Go**
- **Keep Private**
- **Turn into a Vent**
- **Find People Who Understand** — future private connection path

A private Crash Out must never become public merely because matching or discovery occurs later.

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
