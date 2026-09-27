# Ventvo Product System

## The Product in One Sentence

Ventvo gives a person a private place to release what they are carrying, an anonymous Voice to represent them, and intentional spaces where experiences can meet and become meaningful Resonance.

## The Core Loop

```text
                         VENTVO
                            │
                     Finding Your Voice
                            │
                         Seed
                            │
                         Voice
                            │
                     Voice Space
                            │
                 ┌──────────┴──────────┐
                 │                     │
             Crash Out               Vent
                 │                     │
          private release        intentional release
                 │                     │
          ┌──────┴──────┐        Space is created
          │             │               │
      Keep Private   Turn into Vent     │
          │             │               │
          └─────────────┴───────┐       │
                                ▼       ▼
                              Space
                                │
                    ┌───────────┴───────────┐
                    │                       │
               Just Listen          Open Discussion
                    │                       │
                 Heard                 Echo / Echo Note
                    │                       │
                    └───────────┬───────────┘
                                ▼
                           Resonance
                                │
                    Threads / Maps / Connection
                                │
                                ▼
                         Voice Evolution
```

The important point is that these are not isolated features. Each layer exists because of the layer before it.

## 1. Finding Your Voice

The user does not fill out a personality questionnaire.

A new Voice begins through discovery:

```text
Welcome
  ↓
Authentication foundation
  ↓
Finding Your Voice
  ↓
One of the defined Voice Seeds is discovered
  ↓
Seed manifestation
  ↓
Voice reveal
  ↓
Voice Space
```

The first Seed is a beginning, not a permanent personality classification.

Every defined Seed has its own identity, Mark, meaning, feeling, and visual manifestation. VAELOR is the reference implementation, not the only Voice.

## 2. Voice

A Voice is the anonymous identity through which a person exists inside Ventvo.

A Voice currently carries:

- Voice ID
- Seed ID
- Voice Name
- Voice Mark
- Expression
- Resonance
- creation time

The real account identity remains a separate concern from the public Voice.

A Seed gives the Voice a beginning. Experiences can change the Voice over time.

## 3. Voice Space

Voice Space is the person's home inside Ventvo, not a conventional profile page.

It should answer:

> What is my Voice becoming, and what can I do with what I am carrying?

From Voice Space a person can:

- see their Voice identity
- see their journey
- release a Vent
- Crash Out privately
- revisit kept-private Crash Outs
- explore other moments
- see Resonance activity
- enter Voice Evolution

For a new Voice with no Vents, the first action is intentionally clear: release a first moment.

## 4. Crash Out

Crash Out is a private release path, separate from Vents.

It asks:

> What is another side of what I am experiencing?

It is deliberately different from Find People Who Understand, which asks:

> Who has experienced something like me?

### Core flow

Private Crash Out
→ Experience Understanding
→ Human Tension
→ Position + Direction
→ Meaningful Opposition
→ Another Side of the Experience

### Experience Representation

A Crash Out can be understood through:

- Situation
- Human Tension
- Position
- Direction
- Need / Desire
- Emotional State
- Context
- Intensity

Human Tension + Position + Direction are the primary opposition signals.

A single Crash Out may contain multiple experience atoms. The system should identify the strongest opposition-worthy atom rather than force an entire paragraph into one category.

### Opposition rules

A valid encounter needs:

- a shared human tension;
- opposing positions or directions;
- semantic evidence that the relationship is meaningful;
- contextual support where useful;
- safety/privacy eligibility;
- sufficient confidence.

Topic overlap, different emotions, literal antonyms, or random disagreement are not enough.

Ventvo must not manufacture an opposite. No meaningful opposite means no encounter.

### Privacy

The raw Crash Out remains private. It must never be published merely so Ventvo can discover an opposing experience.

Delayed encounters, if introduced later, require a privacy-safe retained representation and an explicit retention/deletion design. Deleting the Crash Out must remove its matching representation.

### Encounter

The encounter should describe the relationship between experiences rather than expose an algorithmic result.

Preferred direction:

> You wanted someone to notice.
>
> Someone else wanted to be left alone.
>
> Two sides of needing people.

The other person is never described as “your opposite”, and the core encounter does not require follows, likes, messages, comments, or connection requests.

### Product separation

- Find People Who Understand → similarity / understanding.
- Resonance → meaningful connection.
- Crash Out → meaningful opposition.
- Echo → expression caused by another experience.

The current deterministic CrashOutOppositeExperienceService is prototype scaffolding. It should evolve toward:

CrashOutExperienceInterpreter
→ ExperienceRepresentation
→ CrashOutOppositionEngine
→ Candidate Eligibility
→ CrashOutEncounter

## 5. Vent

A Vent is an intentional expression brought into the social side of Ventvo.

A Vent carries its Voice identity and creates a Space that defines how the moment should be met.

```text
Voice
  ↓
Vent
  ↓
Space
```

The current Vent model also records visibility, safety, lifecycle, originating Crash Out, and Seed identity so later backend enforcement can preserve the same boundaries.

## 6. Space

A Space is not a subreddit, group, or generic comment thread.

It answers:

> How should people meet this expression?

Ventvo has two core modes.

### Just Listen

The creator wants presence without conversation or advice.

```text
Expression
   ↓
Presence
   ↓
Heard / Resonance
```

No Echo, Echo Note, advice, or discussion belongs here.

### Open Discussion

The creator welcomes perspectives and intentional conversation.

```text
Expression
   ↓
Perspective
   ↓
Echo / Echo Note
   ↓
Resonance
```

## 7. Resonance

Resonance is not a Like and not an engagement score.

It represents the feeling that another person's moment connected with something in you.

The current architecture is deterministic and explainable. It is designed so that future backend or AI-assisted discovery can be added without changing the meaning of the product.

Resonance is not the end of the interaction. A meaningful Resonance can become an intentional connection.

The current connection journey is:

```
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
Shared connection experience
        ↓
Threads / Maps / future Gatherings
```

A connection is not a follower relationship or an automatic conversation. The receiving Voice remains in control of whether the suggested connection is accepted.

Resonance can lead to:
- meaningful connections
- Resonance Threads
- Resonance Maps
- future small private connection experiences
- optional Gatherings emerging from established relationships

## 8. Feed and Moments

The Feed is a discovery layer, not the center of Ventvo.

The intended relationship is:

```text
Space
  ↓
Meaningful activity
  ↓
Moment
  ↓
Feed discovery
  ↓
Return to Space
```

The user should move from a surfaced Moment into its context rather than consuming an endless stream of disconnected posts.

## 9. Voice Evolution

A Voice changes through actual experience.

The current local lifecycle derives stages from real activity:

```text
Seed
  ↓
Expression
  ↓
Resonance
  ↓
Becoming
```

The stages are not levels, achievements, or rewards. They describe the history of what the Voice has expressed and recognized.

## 10. Worlds and Future Experiences

Ventvo's longer-term vision includes Worlds and other collective experiences.

A World should have a purpose, pulse, memory, and evolving collective identity. It should not be added merely as a copy of Reddit communities or Discord servers.

Likewise, future Events should exist only when they strengthen the Voice → expression → connection system. Events are not currently a separate implemented domain in the prototype and should not be treated as if they already exist.

## 11. What Is Real in the Prototype

Currently connected foundations include:

- Voice Seed catalog and discovery
- Seed-specific manifestations
- persisted Voice identity
- Voice Space
- Voice lifecycle
- Vent creation
- Seed identity carried into Vents
- Just Listen
- Open Discussion
- Echo
- Echo Notes
- Resonance discovery and connection lifecycle
- Resonance Threads
- Resonance Maps
- Feed foundation
- Crash Out release and private storage
- Crash Out → Vent conversion path

The prototype still uses local persistence and mock/in-memory boundaries. Production authentication, backend authorization, moderation infrastructure, realtime data, and server-side privacy enforcement are not yet connected.

## 12. What We Build Next

Build depth before breadth.

### Immediate

1. Validate the complete first-run journey on device.
2. Finish the Crash Out → Find People Who Understand pathway and connect discovery to the connection lifecycle.
3. Define and build the active connection experience around shared experiences rather than generic direct messaging.
4. Tighten Feed → Space → Resonance continuity.
5. Add tests around the complete user journey and domain transitions.

The current prototype already exposes the first public Resonance → connection step and a local Your Resonances state view. The recipient-side experience remains a prototype boundary until multiple Voices and backend persistence exist.

### Then

6. Harden ownership, visibility, and safety rules.
7. Define backend contracts and authentication/session boundaries.
8. Introduce production persistence only after the domain boundaries are stable.
9. Build Worlds/collective experiences from the same core language.
10. Add AI-assisted discovery only after deterministic Resonance is proven and privacy boundaries are enforceable.

## Non-Negotiables

- Voice is not a personality quiz.
- VAELOR is not the only Voice.
- Seeds are beginnings, not rigid roles.
- Crash Out is not a Vent.
- Just Listen does not contain Echo.
- Open Discussion is not a normal comment feed.
- Resonance is not popularity.
- Feed is discovery, not the product's purpose.
- Private means private architecturally, not merely hidden in UI.
- No feature is added simply because another social platform has it.
