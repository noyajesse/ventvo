# Ventvo Architecture

## Overview

Ventvo is an anonymous community platform built around authentic expression, meaningful conversation, and human connection.

Ventvo does not treat every expression as a traditional social-media post.

The core idea is:

> A person creates a moment, chooses how that moment should be experienced, and may eventually discover meaningful resonance with other people.

The primary product architecture is:

```text
Voice
  ↓
Vent
  ↓
Space
  ↓
Resonance
  ↓
Connection

Crash Out is a separate private experience:

Voice Space
  ↓
Crash Out
  ↓
Private Release
  ↓
Experience Understanding
  ↓
Meaningful Opposition
  ↓
Another Side of the Experience
```

1. Ventvo Voice

Purpose

Ventvo Voice is the anonymous public identity layer of Ventvo.

A user has a private account for authentication and security, but their public presence is represented through their Ventvo Voice.

A Ventvo Voice consists of:

Voice Name
Voice Mark
Voice Essence

The Voice is the identity attached to a user's expression inside Ventvo.

Identity Separation

Ventvo separates:

Private Account Identity

Private system information may include:

Account ID
Authentication information
Email/provider information
Security information
Moderation records

Public Ventvo Voice

The community interacts with:

Voice Name
Voice Mark
Voice Essence
Vents
Community interactions

The user's real identity should not be exposed through their public Ventvo Voice.

2. Voice Space

Voice Space is the personal environment connected to a user's Ventvo Voice.

It currently provides access to:

Voice identity
Created Vents
Private Crash Outs
Create Vent
Crash Out
Feed exploration

Current relationship:

```text
Ventvo Voice
      ↓
Voice Space
      ↓
Vents / Crash Out / Feed
```

Voice Space is not intended to become a traditional profile page.

3. Vent

Definition

A Vent is a thought, feeling, idea, experience, opinion, or moment intentionally released by a Voice into Ventvo.

A Vent is not simply a social-media post.

A Vent creates a Space that communicates how the creator wants that moment to be experienced.

Current Vent Structure

The current Vent model contains:

id
content
spaceType
voiceMark
createdAt

The Vent also maintains its relationship with the Voice that created it through the creator's Voice Mark.

Vent Relationship

```text
Voice
  ↓
Vent
  ↓
Space
```

This relationship is one of the central foundations of Ventvo.

4. Spaces

A Space defines how other people should interact with a Vent.

Ventvo currently has two core Spaces.

4.1 Just Listen

Purpose

Just Listen exists for moments where the creator wants to be heard without receiving advice or solutions.

The philosophy is:

Presence before advice.

The creator is not asking other people to fix the situation.

Current Prototype

The current prototype allows:

Creation of a Just Listen Vent
Display of the Vent as a Listening Space
A listener selecting Heard

The current Heard state is prototype behavior.

Production implementation will eventually require persistent interaction state and backend storage.

Interaction Rules

Just Listen should remain protected from:

Normal comments
Advice
Open discussion

The purpose is simply to acknowledge:

"I heard you."
### Space as a Shared Experience

The original Space architecture establishes that a Vent creates a Space that communicates how the creator wants that expression to be experienced.

This remains the foundation.

However, a Space is not limited to the original Vent or intended to function as a container for unrelated content.

A Space is a shared experience that can grow as other Voices enter and contribute expressions that genuinely belong within that experience.

The relationship is:

Voice
  ↓
Vent
  ↓
Space
  ↓
Voices meet expressions
  ↓
Space activity
  ↓
Moments
  ↓
Feed
  ↓
Moment
  ↓
its Space

The first Vent establishes the initial context of the Space.

Other Voices may participate in that Space, but participation does not mean joining a traditional social-media community. A Voice enters a Space to meet what is happening there.

The Space should therefore not become:

- A subreddit
- A Facebook-style group
- A Discord-style channel
- A generic topic forum
- A popularity-based community

The defining question for a Space is:

> How should people meet this expression?

rather than:

> How should we organize more content?

### Space Modes

Ventvo currently has only two Space modes.

#### Just Listen

Just Listen exists when the creator wants to be heard without advice, solutions, or open discussion.

The intended interaction is:

Expression
  ↓
Presence
  ↓
Heard

Just Listen protects the creator's intention. Normal comments, advice, Echo Notes, and open discussion do not belong in this experience.

#### Open Discussion

Open Discussion exists when the creator welcomes perspectives and conversation around the expression.

The intended interaction is:

Expression
  ↓
Perspective
  ↓
Echo / Echo Note
  ↓
Understanding

Open Discussion should not become a conventional comment thread. Responses should contribute perspective and preserve the intentional nature of the Space.

### Space Activity and Moments

Space activity represents what happens when Voices express and meet one another inside a Space.

A Moment is a meaningful glimpse of that Space activity.

The Feed surfaces Moments from Spaces.

The Feed therefore does not replace the Space.

When a Voice encounters a Moment in the Feed and chooses to explore it, the intended destination is the Space from which that Moment came.

This allows the Voice to move from:

Moment
  ↓
Space
  ↓
Context
  ↓
Expression
  ↓
Connection

The Feed is therefore a discovery layer for Spaces rather than a separate destination for consuming generic posts.

### Space Participation

A Space may contain expressions from multiple Voices.

However, Ventvo must not automatically force an expression into a Space merely because the subject matter appears similar.

Future resonance or AI-assisted discovery may suggest that a Voice may resonate with an existing Space, but the Voice remains in control of whether they enter or contribute.

Shared Spaces are a product direction being established by this architecture decision and are not yet fully implemented.

5. Open Discussion

Purpose

Open Discussion exists for moments where the creator welcomes conversation and different perspectives.

The philosophy is:

Explore together rather than simply react.

Current Prototype

The current implementation supports:

Creation of an Open Discussion Vent
Open Discussion Space identification
Entering a dedicated Discussion screen
Local discussion responses

Future Development

The discussion system will eventually require:

Persistent discussion data
Real participant data
Conversation state
Echoes
Echo Notes
Resonance connections
Safety and moderation controls

6. Resonance

Definition

Resonance is one of Ventvo's central systems.

Resonance represents meaningful connection between people.

It is not intended to become:

A Like
A popularity score
A follower count
A generic engagement metric

Resonance answers a deeper question:

"Did this moment connect with something in me?"

Resonance Architecture

Resonance sits above individual interactions and owns the connection lifecycle.

The current product flow is:

```text
Voice
  ↓
Vent
  ↓
Space
  ↓
Resonance discovery
  ↓
Related experience
  ↓
This resonates with me
  ↓
Suggested connection
  ↓
Accepted
  ↓
Active connection
  ↓
Shared connection experience
```

A person may encounter a Vent, experience resonance with it, and choose to begin a relationship with another Voice through that resonance. Discovery is therefore a beginning, not the endpoint.

The connection is not a generic follower or direct-message relationship. Its active experience should remain grounded in the shared experience that created it.

7. Resonance Threads

Resonance Threads are a future system built on top of Resonance.

They represent connections between related moments and experiences.

A Resonance Thread may eventually allow Ventvo to connect:

```text
Moment
  ↓
Resonance
  ↓
Related Moment
  ↓
Another Voice
```

The purpose is not to create another comment feed.

The purpose is to reveal meaningful connections between experiences.

Resonance Threads are not yet implemented.

8. Resonance Maps

Resonance Maps are a future visual/system layer of the Resonance architecture.

A Resonance Map is intended to represent how moments and Voices connect through shared resonance.

Conceptually:

```text
                 Voice
                   │
                 Vent
                   │
              Resonance
              /    |    \
           Voice  Vent  Voice
             \     |     /
              Resonance
                   │
                Connection
```

The exact visual and technical implementation of Resonance Maps will be defined when the Resonance system is implemented.

Resonance Maps are not currently implemented.

9. Echo

Echo is a future interaction layer built around meaningful responses to moments.

An Echo should represent a Voice responding because something in the original moment resonated with them.

Echo should not simply become another name for a comment.

The intended distinction is:

```text
Vent
  ↓
Echo
  ↓
Possible deeper connection
```

Echo is not yet implemented as a complete system.

10. Echo Notes

Echo Notes are intended to be deeper reflections associated with an Echo.

They are not ordinary comments.

An Echo Note should allow someone to communicate something similar to:

"I understand this because I have experienced something like it."

Echo Notes should preserve the meaning of the original moment while adding another person's perspective.

The full Echo Note architecture is still under development.

11. Crash Out

Crash Out is a separate Ventvo experience.

It is not a Vent type, diary, notes application, or generic people-matching workflow.

Its defining behavior is:

Voice Space
→ Crash Out
→ Private Release
→ Experience Understanding
→ Meaningful Opposition
→ Another Side of the Experience

The Crash Out remains private. It is not published merely so Ventvo can find an opposing experience.

12. Crash Out Experience Representation

Before Ventvo can identify an opposing experience, it should interpret the private experience into:

- Situation
- Human Tension
- Position
- Direction
- Need / Desire
- Emotional State
- Context
- Intensity

The core Crash Out signals are Human Tension + Position + Direction.

A Crash Out may contain multiple experience atoms. The system should identify the strongest opposition-worthy atom instead of forcing an entire paragraph into one category.

13. Crash Out Opposition

Crash Out is intentionally different from Find People Who Understand.

Find People Who Understand asks:

> Who has experienced something like me?

Crash Out asks:

> What is another side of what I am experiencing?

A valid Crash Out encounter requires:

- shared human tension;
- opposing position/direction;
- semantic evidence;
- meaningful contextual support where useful;
- safety/privacy eligibility;
- sufficient confidence.

Shared topic, different emotion, literal antonyms, or random disagreement are not sufficient.

Context can support opposition but cannot create it.

The system must allow no encounter when no meaningful opposite exists.

Example:

Private Crash Out:

> “I wish someone would check on me. I feel like I'm always the one checking on everyone else.”

Public experience:

> “I hate when people keep checking on me. Sometimes I just want everyone to leave me alone.”

The people are not opposites. The experiences occupy opposing sides of the same human tension.

Prototype architecture:

CrashOutExperienceInterpreter
→ ExperienceRepresentation
→ CrashOutOppositionEngine
→ Candidate Eligibility
→ CrashOutEncounter

The current deterministic CrashOutOppositeExperienceService is prototype scaffolding. Its phrase-based tensions should support validation and regression tests rather than grow indefinitely into a hard-coded ruleset.

14. Crash Out Encounter

The encounter should describe the relationship between the experiences rather than expose an algorithmic result.

Preferred direction:

> You wanted someone to notice.
>
> Someone else wanted to be left alone.
>
> Two sides of needing people.

Do not call another person “your opposite”.

Do not automatically add follows, likes, messages, comments, or connection requests.

The encounter itself is the product outcome.

A Crash Out encounter may naturally lead to an Echo, but an Echo is not required.

15. Crash Out Lifecycle

Release
→ Understand experience
→ Evaluate eligible public experiences
→ Strong opposition?
  → Yes: Encounter
  → No: No encounter

A future delayed-encounter system may allow an opposite experience to surface later. That requires an explicit privacy-safe retention design.

If delayed matching is implemented, deleting the private Crash Out must also remove its matching representation.

16. Find People Who Understand

Find People Who Understand remains the similarity/understanding pathway.

Its conceptual flow is:

Experience
→ Similarity discovery
→ Related experience
→ Optional Resonance
→ Suggested connection

It must not be treated as Crash Out with different copy.

17. Human Connection System

Ventvo's connection system uses Resonance for meaningful similarity/connection relationships.

Crash Out opposition is a separate domain concern.

Shared infrastructure may include:

- candidate eligibility
- safety checks
- privacy checks
- moderation state
- repositories
- experience metadata

But Crash Out must not inherit Resonance's similarity semantics simply because both systems surface experiences.

18. Feed

Ventvo's connection system is intended to grow from Resonance rather than traditional social networking.

The long-term direction is:

```text
Expression
    ↓
Vent
    ↓
Space
    ↓
Resonance
    ↓
Echo
    ↓
Deeper Understanding
    ↓
Connection
```

The goal is meaningful connection rather than maximum engagement.

15. Feed

The Feed is the community discovery layer.

Current prototype flow:

```text
Voice
  ↓
Vent
  ↓
ventProvider
  ↓
Feed
```

Feed cards currently prioritize:

Voice identity
Vent expression
Space type
Appropriate interaction

The Feed should not become a follower-based popularity feed.

Future discovery behavior may use Resonance once the Resonance system exists.

16. Discussion

Open Discussion currently has a dedicated discussion experience.

Current prototype behavior:

```text
Open Discussion Vent
        ↓
Discussion Screen
        ↓
Local Responses
```

The current responses are demonstration data.

Future implementation will require persistent backend data and proper participant identity.

Discussion should remain separate from Just Listen.

17. State Management

Ventvo uses Riverpod for application state.

Current providers include systems such as:

Vent state
Ventvo Voice state
Crash Out state

Crash Out state remains independent from Vent state.

This separation is intentional.

18. Navigation

Ventvo uses Flutter navigation.

The application currently contains separate feature screens for:

Authentication
Onboarding
Ventvo Voice
Voice Space
Vents
Feed
Discussion
Crash Out

Navigation should follow feature boundaries rather than creating unnecessary dependencies between unrelated systems.

19. Project Structure

Current structure:

```text
lib/
├── core/
└── features/
    ├── auth/
    ├── onboarding/
    ├── ventvo_voice/
    │   ├── models/
    │   ├── providers/
    │   └── screens/
    ├── home/
    ├── vents/
    ├── feed/
    │   ├── screens/
    │   └── widgets/
    ├── discussion/
    ├── spaces/
    └── crash_out/
        ├── models/
        ├── providers/
        └── screens/
```

20. Backend Direction

Supabase will provide Ventvo's backend services.

Services planned:

- Supabase Authentication
- PostgreSQL Database
- Supabase Storage
- Supabase Realtime

21. Security Architecture

Ventvo must protect the person behind the Voice.

The system should enforce separation between:

```text
Private Account
      ↓
Authentication / Security
      ↓
Ventvo Voice
      ↓
Community Expression
```

Security priorities include:

Authentication
Authorization
Identity separation
Privacy
Input validation
Abuse prevention
Content moderation
Reporting
Secure data access

Users must not be able to access or modify another user's private data or protected content.

22. Product Architecture Principles

Ventvo should not copy traditional social-media architecture simply because those patterns are familiar.

The platform prioritizes:

Expression over performance
Understanding over popularity
Connection over engagement
Voice over traditional profiles
Moments over generic posts
Meaningful interaction over reaction farming

Every major feature should strengthen the central architecture:

```text
Voice
  ↓
Vent
  ↓
Space
  ↓
Resonance
  ↓
Connection
```

23. Current vs Future Systems

Implemented Foundation

Currently functional or prototyped:

Authentication foundation
Ventvo Voice creation
Voice Space
Vent creation
Vent provider
Feed foundation
Voice identity in Vents
Just Listen prototype
Open Discussion prototype
Discussion prototype
Crash Out entry
Crash Out release
Crash Out Fate
Let Go
Keep Private
Private Crash Out storage

Product Systems Not Yet Fully Implemented

These are established product directions but require further development:

Resonance Threads
Resonance Maps
Echo
Echo Notes
Persistent discussions
Persistent multi-Voice Resonance interactions
Crash Out → Vent conversion
Private Crash Out → Find People Who Understand integration
Active shared connection experience
Small connection groups
Voice Crash Outs
Backend persistence
AI-assisted similarity discovery

24. AI / Semantic Discovery Direction

AI or semantic models may eventually assist Ventvo with experience understanding and discovery.

For Resonance, this can support meaningful similarity.

For Crash Out, semantic systems may eventually help identify:

- underlying human tension;
- position;
- direction;
- contextual relationship;
- meaningful opposition.

AI must not be used to:

- diagnose users;
- determine mental health;
- provide therapy as a substitute for human support;
- expose private Crash Out text;
- manufacture psychological meaning without sufficient evidence.

The product semantics must be proven with deterministic tests before introducing complex AI infrastructure.

Crash Out should evolve from deterministic prototype rules toward semantic understanding only after its domain model and privacy boundaries are stable.

25. Architecture Decision

Ventvo maintains a strict separation between its core expression systems.

Vent

An intentional expression brought into the Ventvo community.

Space

Defines how that Vent should be experienced.

Resonance

Represents meaningful connection.

Crash Out

A private release experience that exists outside the normal Vent system.

This separation should be preserved as the project grows.

26. Product Direction

Ventvo's long-term architecture is not simply:

```text
Post
↓
Like
↓
Comment
↓
Follower
```

Instead, Ventvo is designed around:

```text
Voice
↓
Moment
↓
Vent
↓
Space
↓
Resonance
↓
Understanding
↓
Connection
```

That distinction is fundamental to the product.

27. Documentation Hierarchy

Ventvo documentation follows:

```text
PRODUCT_VISION.md
       ↓
ARCHITECTURE.md
       ↓
ENGINEERING_HANDBOOK.md
       ↓
SECURITY_HANDBOOK.md
       ↓
Implementation
```

Product Vision

Defines why Ventvo exists.

Architecture

Defines how the product concepts connect.

Engineering Handbook

Defines how the software is built.

Security Handbook

Defines how users and their data are protected.

The implementation should follow these documents rather than redefining the product direction independently.

28. Current Development Principle

Before implementing a new feature, answer:

What human problem does this solve?

Then determine:

What product concept does it belong to?
Does it strengthen Voice, Vent, Space, Resonance, or Connection?
Is it a new system or part of an existing one?
Does it require backend state?
Does it introduce security or privacy risks?
How does it affect the existing architecture?

Ventvo should grow deliberately rather than accumulating unrelated social-media features.

---

# Latest Architecture Addition — Ventvo Voice Foundation

## Voice System

The Ventvo Voice system now has a dedicated core layer:

```text
lib/core/voice/
├── ventvo_voice.dart
├── ventvo_voice_seed.dart
└── ventvo_voice_system.dart
```

VentvoVoice

VentvoVoice defines the current foundational Voice vocabulary:

VAELOR
NYVEN
AUREN

Each foundation has:

Name
Principle
Mark

The current definitions are:

Voice | Principle | Mark
--- | --- | ---
VAELOR | Give it somewhere to exist. | ◇
NYVEN | You are heard. | ∿
AUREN | You can become something different. | ✦

These foundations are part of Ventvo's internal language and should not be treated as ordinary selectable personality types.

## VentvoVoiceProfile

VentvoVoiceProfile represents the balance between the three Voice foundations.

It currently stores:

vaelorWeight
nyvenWeight
aurenWeight

This allows a Voice to eventually become more nuanced than a single permanent category.

## VentvoVoiceSeed

VentvoVoiceSeed represents the initial state of a user's Voice.

It contains:

profile
mark
growth

The Seed is deliberately incomplete.

The architecture should allow the Voice to evolve as the user interacts with Ventvo rather than treating onboarding as the permanent definition of the person.

## Onboarding Architecture

The current onboarding progression is:

```text
Welcome
   ↓
Authentication
   ↓
Finding Your Voice
   ↓
Voice Reveal
```

FindingYourVoiceScreen introduces the Voice concept without forcing the user through a long personality questionnaire.

VoiceRevealScreen presents the resulting Voice foundation and Mark.

The Voice Seed is passed into the reveal experience so that the Voice identity is represented by actual domain data rather than isolated UI text.

## Visual Architecture

The following reusable core systems have been introduced:

```text
lib/core/
├── motion/
│   └── ventvo_motion.dart
│
├── theme/
│   ├── app_theme.dart
│   ├── ventvo_colors.dart
│   ├── ventvo_mark.dart
│   ├── ventvo_spacing.dart
│   └── ventvo_typography.dart
│
└── voice/
    ├── ventvo_voice.dart
    ├── ventvo_voice_seed.dart
    └── ventvo_voice_system.dart
```

This establishes a reusable foundation rather than placing visual and Voice logic directly inside individual screens.

## Design Constraint

Future Voice-related features must preserve the distinction between:

```text
Voice Foundation
        ↓
Voice Seed