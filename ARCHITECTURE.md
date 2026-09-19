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

Crash Out is a separate expression pathway:

Voice Space
  ↓
Crash Out
  ↓
Private Release
  ↓
Fate
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

It is not a Vent type.

It is not intended to be:

A diary
A notes application
A collection of ordinary posts

Crash Out provides a private release pathway.

It allows a person to release something they are carrying before deciding what, if anything, should happen next.

Crash Out Architecture

```text
Voice Space
     ↓
Crash Out
     ↓
Release
     ↓
Fate
```

The Crash Out remains separate from the normal Vent system unless the user explicitly chooses to move it into that system.

12. Crash Out Model

The current Crash Out model supports:

id
content
type
createdAt
status

Current statuses include:

released
keptPrivate
convertedToVent

The model is intentionally separate from the Vent model.

13. Crash Out Fate

After releasing a Crash Out, the user can eventually choose what happens next.

The intended outcomes are:

Let Go
Keep Private
Turn into a Vent
Find People Who Understand

13.1 Let Go

Let Go removes the Crash Out from the user's private Crash Out storage.

Current behavior:

```text
Crash Out
  ↓
Let Go
  ↓
Deleted
  ↓
Voice Space
```

13.2 Keep Private

Keep Private stores the Crash Out privately.

Current behavior:

```text
Crash Out
  ↓
Keep Private
  ↓
Private Crash Outs
```

Private Crash Outs:

Do not appear in the normal Feed
Are not normal Vents
Are accessible only through the user's private space

13.3 Turn into a Vent

This is a future pathway.

Intended architecture:

```text
Crash Out
  ↓
Turn into a Vent
  ↓
Vent
  ↓
Space
  ↓
Feed
  ↓
Resonance
```

The conversion should only happen when the user explicitly chooses it.

13.4 Find People Who Understand

Find People Who Understand is an explicit connection pathway.

The intended experience is not:

"Your algorithmic match is User #123."

Instead, it should surface relevant experiences/Voices that may genuinely understand the user's experience.

For a public Vent:

```text
Vent
  ↓
Resonance discovery
  ↓
Related experience
  ↓
This resonates with me
  ↓
Suggested connection
```

For a private Crash Out, the user may explicitly request understanding without making the Crash Out public:

```text
Crash Out
  ↓
Explicit private understanding request
  ↓
Resonance discovery
  ↓
Relevant public experiences
  ↓
User chooses whether to leave a Resonance
  ↓
Suggested connection
```

The Crash Out remains private. It is not indexed or exposed as a public source merely because it is used to discover relevant public experiences.

After a Resonance is left, the connection follows the shared lifecycle:

```text
Suggested
   ↓
Accepted
   ↓
Active
   ↓
Shared connection experience
```

The receiving Voice controls whether the suggested connection is accepted. The active experience should remain grounded in the shared experience that created the connection rather than becoming a generic direct-message system.

The current prototype implements the public Vent discovery → suggested connection step and provides a local Your Resonances state view. Real recipient delivery, multi-Voice acceptance, and backend persistence remain future work.

14. Human Connection System

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

24. AI Matching Direction

AI may eventually assist Ventvo in discovering meaningful similarities between experiences.

The purpose would be:

Help people discover others who may genuinely understand their experience.

AI should not be used to:

Diagnose users
Provide therapy
Determine someone's mental health
Replace human connection

The system should focus on meaningful similarity and connection.

AI matching will be developed only after the underlying Resonance and connection architecture is established.

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
        ↓
Voice Evolution
```

The system should not turn into a personality quiz or force users into a permanent identity.

---

# Latest Architecture Addition — Shared Space Architecture

## Space Definition

The existing Ventvo foundation remains:

> A Vent creates a Space that communicates how the creator wants that expression to be experienced.

This remains true.

The architecture is now clarified so that a Space is not limited to the first Vent and is not a container for unrelated content.

A Space can become a shared experience where multiple Voices meet expressions that genuinely belong within that Space.

The core relationship is:

```text
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
tap Moment
  ↓
its Space
```

The first Vent establishes the initial context of the Space. A later Voice may enter the Space and contribute an expression when it genuinely belongs within that experience.

Participation does not mean joining a traditional social-media community. A Voice enters a Space to meet what is happening there.

## Space Is Not a Traditional Social Platform Structure

Space must not become:

- A subreddit
- A Facebook-style group
- A Discord-style channel
- A follower-based community
- A popularity feed
- A generic topic forum

A Space exists to organize **how Voices meet expression**, not simply where content is stored.

The defining question is:

> How should people meet this expression?

not:

> How can we organize more content?

## Space Modes

Ventvo currently has only two Space modes.

### Just Listen

Just Listen exists when the creator wants to be heard without advice, solutions, or open discussion.

```text
Expression
  ↓
Presence
  ↓
Heard
```

Just Listen protects the creator's intention. Normal comments, advice, Echo Notes, and open discussion do not belong in this experience.

The meaningful interaction remains:

> I heard you.

### Open Discussion

Open Discussion exists when the creator welcomes perspectives and conversation around the expression.

```text
Expression
  ↓
Perspective
  ↓
Echo / Echo Note
  ↓
Understanding
```

Open Discussion should not become a conventional comment thread. Responses should contribute perspective and preserve the intentional nature of the Space.

## Space Participation

A Space may contain expressions from multiple Voices.

Ventvo must not automatically force a Vent into a Space merely because the subject matter appears similar.

Future Resonance or AI-assisted discovery may suggest that a Voice may resonate with an existing Space, but the Voice remains in control of whether they enter or contribute.

## Space Activity and Moments

Space activity represents what happens when Voices express and meet one another inside a Space.

A Moment is a meaningful glimpse of Space activity.

The Feed surfaces Moments from Spaces.

The Feed therefore does not replace the Space and is not a separate social-media destination for consuming generic posts.

When a Voice encounters a Moment in the Feed and taps it, the intended destination is the Space from which that Moment came so the Voice can experience the surrounding context.

```text
Space
  ↓
Space activity
  ↓
Moment
  ↓
Feed
  ↓
tap Moment
  ↓
return to its Space
```

## Current Implementation Boundary

This is an architecture and product decision. It does **not** claim that shared Spaces, persistent multi-Voice participation, Moments, or Feed-to-Space navigation are already implemented.

The existing prototype remains the implementation baseline until these systems are deliberately built and validated.

The existing Just Listen and Open Discussion semantics remain the foundation of the implementation and should not be replaced with generic social-media interactions.
