# Ventvo

> VENT your thoughts. FIND your people. FEEL understood.

Ventvo is an anonymous social platform built around authentic expression, meaningful conversation, and human connection.

Instead of traditional profiles and follower-based identity, users create a **Ventvo Voice** — a private digital identity that represents them inside the Ventvo community.

---

# Vision

Ventvo exists to help people:

1. **Vent their thoughts**
2. **Find their people**
3. **Feel understood**

Ventvo is designed around meaningful human moments rather than popularity, followers, likes, or performance.

---

# Core Concepts

## Ventvo Voice

A Ventvo Voice is the anonymous public identity of a user.

A Voice includes:

- Voice Name
- Voice Mark
- Voice Essence

The user's real account identity remains private while their Voice represents them publicly.

---

## Voice Space

Voice Space is the personal space connected to a user's Ventvo Voice.

It provides access to:

- The user's Voice identity
- Created Vents
- Private Crash Outs
- Vent creation
- Crash Out
- Community Feed

---

## Vents

A **Vent** is a thought, feeling, experience, opinion, or moment intentionally released into Ventvo.

A Vent is not simply a social-media post.

A Vent creates a **Space** that tells other people how the creator wants that moment to be experienced.

Current Vent structure includes:

- Vent ID
- Content
- Space Type
- Voice Mark
- Creation time

---

# Vent Spaces

Ventvo currently has two core spaces.

## Just Listen

Just Listen is for moments where someone does not want solutions.

Its purpose is simple:

> "I just need someone to hear me."

Current prototype interaction:

- A person creates a Just Listen Vent.
- Other Voices can acknowledge that they heard it.

The current interaction is a prototype and will later use persistent backend state.

Just Listen is intentionally protected from normal discussion and advice.

---

## Open Discussion

Open Discussion is for moments where the creator welcomes conversation and different perspectives.

Current prototype:

- A Vent is created as an Open Discussion.
- Other Voices can enter the discussion.
- A dedicated discussion screen allows responses.

Future development will add:

- Persistent discussions
- Real participant data
- Echo Notes
- Conversation rules
- Resonance connections

---

# Resonance

**Resonance is one of Ventvo's central systems.**

Resonance represents meaningful human connection.

It is not:

- A Like
- A follower count
- A popularity score
- An engagement metric

Resonance answers a deeper question:

> "Did this moment connect with something in me?"

Resonance will eventually connect Vents and Voices through deeper systems such as:

- Resonance Threads
- Resonance Maps
- Future connection discovery

These systems are part of Ventvo's long-term architecture and are not yet fully implemented.

---

# Echo

Echo is a future interaction layer built around meaningful responses to another person's moment.

Echo should not become a normal comment system.

An Echo represents a Voice responding because something in the original moment resonated with them.

---

# Echo Notes

Echo Notes are deeper reflections associated with an Echo.

They are intentionally different from ordinary comments.

An Echo Note should communicate something closer to:

> "I understand this because I have experienced something similar."

The full Echo and Echo Note systems are still under development.

---

# Crash Out

Crash Out is a separate Ventvo experience.

It is **not a type of Vent**.

Crash Out gives someone a private place to release something they are carrying before deciding what should happen next.

Current flow:

```text
Voice Space
      ↓
Crash Out
      ↓
Release
      ↓
Fate 
Current outcomes include:

Let Go
Keep Private
Turn into a Vent
Find People Who Understand

The currently implemented functionality includes:

Text Crash Out creation
Release flow
Fate screen
Let Go
Keep Private
Private Crash Out storage
Private Crash Out viewing

Future Crash Out development may include:

Turn into a Vent
Find People Who Understand
Voice-based Crash Outs
Small-circle connection experiences
Resonance-based discovery

AI-assisted matching will be considered later and will not be treated as therapy or diagnosis.

Feed

The Feed is the community discovery layer of Ventvo.

Current prototype flow:

Voice
  ↓
Vent
  ↓
ventProvider
  ↓
Feed

Feed cards prioritize:

Voice identity
The expressed moment
The Space created by the Vent

Ventvo intentionally avoids building the Feed around followers, popularity, or conventional social-media metrics. 
Current Product Architecture

The current product foundation can be represented as:

                    VENTVO VOICE
                         ↓
                    VOICE SPACE
                         ↓
                        VENT
                         ↓
                       SPACE
                    ↙          ↘
              JUST LISTEN   OPEN DISCUSSION
                    ↘          ↙
                     RESONANCE
                         ↓
              FUTURE CONNECTION SYSTEMS

Crash Out remains a separate pathway:

VOICE SPACE
     ↓
CRASH OUT
     ↓
PRIVATE RELEASE
     ↓
FATE
  ↙  ↓  ↘
KEEP  LET GO  FUTURE PATHS
PRIVATE
Current Features
Authentication
Account creation flow
Authentication foundation
Separation between private account identity and public Ventvo Voice
Ventvo Voice
Voice Welcome
Voice Discovery
Voice Mark selection
Voice Name
Voice Essence
Voice creation confirmation
Voice Space
Vents
Create Vent
Store Vents through Riverpod
Connect Vents to the creator's Voice
Display Vents in Voice Space
Display Vents in Feed
Spaces
Just Listen
Listening Space
Heard prototype interaction
Open Discussion
Open Discussion Space
Discussion screen
Local response prototype
Feed
Feed screen
Vent cards
Voice identity display
Space identification
Crash Out
Crash Out entry
Text release
Fate screen
Let Go
Keep Private
Private Crash Out storage
Private Crash Out screen
Future Systems

Ventvo is still under active development.

Major future systems include:

Resonance
Resonance Threads
Resonance Maps
Echo
Echo Notes
Deeper connection discovery
Find People Who Understand
Small connection circles
Voice Crash Outs
Persistent backend interactions
AI-assisted similarity discovery

These systems should be implemented only when their product behavior and technical architecture are clearly defined.

Technology Stack
Frontend
Flutter
Dart
State Management
Riverpod
Navigation
GoRouter
Backend

Planned:

Firebase Authentication
Cloud Firestore
Firebase Storage

Backend implementation will be introduced as the application moves from prototype state toward production.

Development
Git
GitHub
VS Code
Project Structure
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
Development Status

Ventvo is currently in active prototype development.

The following foundations are functional:

Authentication foundation
Ventvo Voice creation
Voice Space
Vent creation
Vent provider
Feed foundation
Just Listen prototype
Open Discussion prototype
Crash Out entry and release flow
Crash Out fate system
Private Crash Out storage

The following are future systems:

Full Resonance system
Resonance Threads
Resonance Maps
Echo
Echo Notes
Human connection discovery
Backend persistence
AI-assisted similarity matching
Development Philosophy

Every feature must strengthen Ventvo's purpose.

Ventvo prioritizes:

Expression over performance
Understanding over popularity
Connection over engagement
Anonymous identity over traditional profiles
Human moments over social-media posts

Before building a feature, we should be able to answer:

What human problem does this solve?

If a feature does not strengthen expression, understanding, or meaningful connection, it should not be added simply because traditional social platforms have it.

Security Philosophy

Ventvo protects the person behind the Voice.

Private account information should remain separate from the public Ventvo Voice.

Security priorities include:

Authentication security
Identity separation
Authorization
Privacy protection
Input validation
Abuse prevention
Content moderation
Reporting
Secure development practices

No passwords, private credentials, API keys, or sensitive configuration should be committed to GitHub.

Branch Strategy
main → stable releases
development → active feature development

Features should be tested and reviewed before being merged into main.

Development Workflow

Every major feature follows:

Plan
Design
Architecture review
Security review
Implement
Test
Review
Document
Commit
Push to GitHub
Current Milestone

Ventvo Core Expression Foundation

Ventvo currently has the foundation for:

Voice
  ↓
Voice Space
  ↓
Vent
  ↓
Space
  ↓
Feed / Resonance foundation

and:

Voice Space
  ↓
Crash Out
  ↓
Private Release
  ↓
Fate
  ↓
Private Storage

The next development stage should focus on completing the underlying behavior of the existing product concepts before expanding into additional systems.

Brand
Tagline

VENT your thoughts. FIND your people. FEEL understood.

Ventvo is built for people who want to express what they are carrying and discover that they are not alone.