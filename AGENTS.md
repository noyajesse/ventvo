# Ventvo — Agent Instructions

## 1. What Ventvo Is

Ventvo is a social platform built around one core idea:

> People should be able to express what they are carrying, control how others respond, and find people they genuinely resonate with.

Ventvo is not intended to be a Reddit clone, a traditional social-media feed, or a generic anonymous posting app.

The product should feel human, intentional, safe, and emotionally aware.

The goal is not to make Ventvo do everything automatically. Human interaction should remain natural. Ventvo should create the conditions for meaningful interaction rather than forcing it.

---

# 2. Core Philosophy

### Voice

Anonymity in Ventvo does not mean becoming a meaningless username.

A user has a persistent **Ventvo Voice**.

A Voice allows a person to remain anonymous while still having a recognizable identity, personality, expression, and presence.

The philosophy is:

> You can be anonymous without being invisible.

Do not replace the Voice concept with conventional usernames as the primary identity model.

---

# 3. Core Product Concepts

Ventvo has several distinct layers.

### Crash Out

Crash Out is the private emotional release mechanism.

Its philosophy:

> You don't have to make sense of it yet. Just let it out.

A Crash Out is never a public Vent by default.

The current Crash Out direction is **meaningful opposition**, not similarity matching or user-selected fates:

Crash Out
→ Experience Understanding
→ Meaningful Opposition
→ Enter the relevant Crash Out Space
→ Encounter many experiences on opposing sides of the same human tension
→ Open, ongoing replies between experiences

A Crash Out Space is a dedicated, ongoing community-like environment organized around a meaningful human tension and its opposing sides. It can contain many experiences and replies; it is not a temporary private chat or a one-to-one Experience Thread. The initial opposite experience is the doorway into this broader space, not the end of the journey.

Do not carry the earlier temporary/private-chat concept into this opposition feature. Keep the focus on the opposing experiences, the broader community, and ongoing replies. An encounter is about experiences, not people, and the system must never manufacture an opposite experience just to produce a result.

Crash Out should remain low-pressure and should not become a diary, therapist, conventional direct-message inbox, or generic topic subreddit. Replies are allowed and should help the conversation continue naturally around the experiences.

---

### Vent

A Vent is an intentional expression that the user is ready to bring into the social side of Ventvo.

When creating a Vent, the user controls the type of response they want.

Current response modes:

- **Just Listen**
- **Open Discussion**

#### Just Listen

The author does not want debate, advice, arguments, or attempts to fix the situation.

Other users can acknowledge that they heard the Vent.

The existing concept uses **"Heard"** rather than conventional Likes.

#### Open Discussion

The author is open to conversation and responses.

Ventvo should preserve the author's chosen interaction mode.

---

# 4. Spaces

Spaces are environments organized around the type of interaction people want.

Spaces are not simply Reddit-style communities.

The key distinction is:

> A Space defines the social environment. A Vent is something a person brings into that environment.

Initial/core Spaces can be created and maintained by Ventvo.

Examples include:

### Just Listen

A space for people who primarily want to hear others and be heard without turning everything into advice or debate.

### Open Discussion

A space for people who are willing to discuss, respond, exchange perspectives, and have conversations.

Additional Spaces may eventually exist based on the interaction or emotional context they provide.

Do not create Spaces merely because Reddit has subreddits.

Every Space should have a clear social purpose.

---

# 5. Feed

The Feed should not simply be an endless stream of every Vent.

The Feed is intended to surface **Moments**.

A Moment can emerge from an interaction or conversation within a Space and become something worth carrying beyond that immediate interaction.

Conceptually:

User
→ Vent
→ Space
→ Interaction
→ Moment
→ Feed

The Feed should therefore feel more intentional and meaningful than an infinite Reddit-style content stream.

Moments may have a lifecycle/end rather than existing forever.

Do not assume that every Vent belongs directly in the Feed.

---

# 6. Find People Who Understand

Find People Who Understand is a separate similarity/resonance pathway.

Its purpose is:

> Who has experienced something like me?

It must remain separate from Crash Out, whose defining question is:

> What is another side of what I'm experiencing?

A future understanding/resonance system may consider multiple signals, including experiences, emotional needs, interests, life experiences, shared circumstances, communication preferences, and other meaningful signals.

Matching should be based on meaningful resonance, not simple keyword similarity.

---

# 7. Resonance

Resonance is a major part of Ventvo's long-term identity.

Two people do not need to have identical lives to understand one another.

Someone may resonate with another person because of:

- a similar experience
- a shared emotional state
- a shared interest
- a similar way of thinking
- a common life situation
- a similar need for connection
- something as simple as a shared interest that creates an immediate bridge

Example:

A person may feel uncomfortable approaching strangers, but discovering that someone else loves anime can immediately create a natural connection.

Ventvo should therefore look for the things that make people think:

> "You understand something about me."

---

# 8. Resonance Maps

Resonance Maps are part of the longer-term Ventvo vision.

They should represent meaningful connections/signals around a person or Voice rather than simply listing followers or friends.

A Resonance Map should help answer questions such as:

- What kinds of experiences connect me with people?
- What interests create natural connections?
- What themes repeatedly appear in my interactions?
- Where do I resonate with other Voices?

Do not implement Resonance Maps as a generic follower graph.

They should be based on Ventvo's resonance philosophy.

---

# 9. Small Private Connections

Private connections are a future Resonance capability, not the defining output of Crash Out.

When a connection system is introduced, it should be:

- private
- intentional
- small
- human
- natural

The connection must emerge from meaningful interaction and user control. Crash Out must not automatically create a connection merely because an opposing experience surfaced.

---

# 10. Private Connection

Future private connections must not automatically become:

- a public Vent
- a Feed item
- a public Space
- public profile activity

Participants should control what happens to the connection afterward.

Privacy must eventually be enforced by backend authorization, not merely by Flutter UI filtering.

---

# 11. Crash Out Privacy

Crash Outs are private by default.

Current lifecycle:

### Keep Private

The Crash Out remains accessible only to its owner.

### Let Go

The Crash Out and its related private frontend data are deleted.

### Meaningful Opposition

Ventvo may surface another public experience that represents a meaningful opposite, but the original Crash Out remains private. This is not similarity matching and does not automatically create a follow, message, comment, or connection.

### Crash Out Space

When an opposing experience surfaces, the user enters a broader Crash Out Space containing many experiences that relate to the same human tension from different sides. People can reply to individual experiences and continue the conversation over time. The space is a community in its own right, not a temporary private chat or a one-to-one thread. Participants do not need to know one another.

---

# 12. Public vs Private Data

These are fundamentally different domains.

### Public

Examples:

- public Vents
- Spaces
- Moments
- Feed content
- public interaction

### Private

Examples:

- private Crash Outs
- matching requests
- private connections
- private conversations
- private identity/account mappings
- sensitive resonance information

Never assume that hiding something in the UI makes it private.

When backend persistence is introduced, authorization and access control must be enforced server-side.

---

# 13. Voice Anonymity

Ventvo Voice is the public-facing identity.

The system may know the real account behind a Voice for security and account management, but other users should interact primarily with the Voice identity.

Do not expose real identity through:

- public user IDs
- email addresses
- account metadata
- backend identifiers
- private profile information

Anonymity must be architectural, not merely visual.

---

# 14. Natural Interaction Principle

Ventvo should not try to manufacture every interaction.

The platform should provide opportunities for people to connect naturally.

Avoid excessive:

- forced prompts
- artificial engagement mechanics
- unnecessary gamification
- automated conversation
- intrusive recommendations
- manipulative notifications

Ventvo should help people discover meaningful connections without making the interaction feel engineered.

---

# 15. Reddit Lessons

Reddit is not Ventvo's enemy.

Reddit demonstrates that people are willing to share deeply when they believe:

- someone will listen
- someone will understand
- other people have experienced something similar
- they can find communities where they belong

Ventvo should learn from this without copying Reddit's structure.

Important differences:

Reddit:
- subreddit/community centered
- username-centered identity
- large public discussions
- endless content
- moderators/community rules
- broad comment sections

Ventvo:
- Voice-centered identity
- author-controlled interaction
- intentional Spaces
- Crash Out before public expression
- resonance-based connection
- small private matching
- Moments rather than an endless content stream
- stronger distinction between private release and public expression

---

# 16. Product Principles

When deciding whether to add a feature, ask:

1. Does it help people express themselves?
2. Does it help people feel understood?
3. Does it create meaningful human connection?
4. Does it preserve user control?
5. Does it respect anonymity and privacy?
6. Does it feel natural rather than forced?
7. Does it make Ventvo meaningfully different from ordinary social media?

If a feature does not support these principles, question whether Ventvo needs it.

---

# 17. Security Is the First Priority

Never treat the Flutter client as the final authority for security.

Future architecture must enforce:

- authentication
- authorization
- ownership
- privacy
- access control
- rate limiting
- abuse prevention
- reporting
- moderation
- secure storage
- secure deletion where applicable

Never commit:

- API keys
- secrets
- passwords
- private tokens
- service-account credentials
- private certificates
- `.env` secrets
- Firebase private credentials

Before introducing a backend service, define its security model first.

---

# 18. Current Prototype Reality

The current repository is a prototype.

Much of the product vision exists conceptually but is not yet implemented.

Current code uses:

- Flutter
- Riverpod
- in-memory providers
- local navigation
- prototype models

Do not assume that because a model, enum, button, or screen exists, the underlying feature is fully implemented.

Examples:

- `matchingEligible` does not mean matching exists.
- `convertedToVent` does not mean conversion is implemented.
- `CrashOutStatus.keptPrivate` does not provide real backend privacy.
- a Voice model does not mean real identity separation exists.
- a Feed screen does not mean the final Feed architecture exists.

---

# 19. Development Rules for Agents

Before modifying code:

1. Read `AGENTS.md`.
2. Read relevant existing documentation.
3. Inspect the current implementation.
4. Understand the existing architecture.
5. Do not invent product behavior that conflicts with the documented Ventvo philosophy.
6. Do not replace existing concepts with generic social-media patterns.
7. Prefer small, reversible changes.
8. Preserve existing working functionality.
9. Do not expose secrets.
10. Treat privacy/security as architectural requirements.

For major features:

1. Explain the proposed architecture.
2. Identify affected models/providers/services/screens.
3. Identify privacy/security implications.
4. Wait for approval before making major architectural changes.

---

# 20. Current Development Priority

The current priority is not to blindly add more UI.

The priority is to gradually move the prototype toward the architecture required by the established Ventvo product vision.

Important upcoming areas include:

1. domain model cleanup
2. ownership and visibility
3. Crash Out state transitions and experience lifecycle
4. Crash Out opposition/Experience Thread completion
5. Echo semantics and interaction architecture
6. private three-Voice connection architecture
7. authentication/session architecture
8. backend/repository/service boundaries
9. public Feed and Moment architecture
10. moderation/reporting/privacy infrastructure

Do not implement all of these at once.

Build incrementally and preserve the product philosophy.