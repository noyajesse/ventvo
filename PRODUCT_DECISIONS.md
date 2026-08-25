# Ventvo Product Decisions

This document records the reasoning behind major product decisions.

The purpose is to preserve Ventvo's identity as the product grows.

---

# 1. Voice instead of Profile

Decision:

Ventvo uses **Voice Space** instead of a traditional profile.

Reason:

A profile represents a person.

A Voice represents how someone chooses to express themselves.

This reinforces Ventvo's identity as a platform for expression rather than performance.

---

# 2. A Vent creates a Space

Decision:

A Vent does not choose an interaction.

A Vent creates a Space.

Current Spaces:

- 🌊 Just Listen
- 💬 Open Discussion

Reason:

People should control how others meet their thoughts before they express them.

---

# 3. Crash Out is not a Vent type

Decision:

Crash Out is a separate experience.

It is never shown beside Just Listen or Open Discussion.

Reason:

Crash Out is an emotional support experience, not a response mode.

---

# 4. Echo Notes are not comments

Decision:

Echo Notes are reflections.

They are not discussion threads.

Reason:

Ventvo encourages understanding before conversation.

Echo Notes should preserve the creator's Voice while allowing another Voice to leave a meaningful reflection.

---

# 5. Resonance instead of popularity

Decision:

Ventvo avoids building around Likes, Followers, or popularity metrics.

Reason:

The goal is meaningful connection instead of performance.

Future metrics should represent understanding rather than engagement.

---

# 6. Voice Space instead of Profile

Decision:

Users return to their Voice Space.

Reason:

It should feel like a personal place, not a public profile page.

---

# 7. Build the website before launch

Decision:

After the mobile MVP is complete, build the full website before the public launch.

Reason:

The website should:

- explain the philosophy
- build community
- collect early users
- function as a complete platform after launch

---

# Guiding Question

Whenever a new feature is proposed, ask:

1. Does this make Ventvo more useful?
2. Does this make Ventvo more different?
3. Does this make Ventvo simpler?

If the answer is "yes" to fewer than two questions, reconsider the feature.

# Echo Notes

Decision:

Echo Notes are a way for a Voice to share another Voice's Vent while attaching their own expression.

Echo Notes are inspired by reposting with a personal note, but they are designed around understanding rather than popularity.

---

## Purpose

Echo Notes solve the problem of:

"How do I share something that affected me while explaining why it mattered?"

---

## How it works

A Voice sees a Vent that resonates with them.

Instead of creating a normal comment, they can create an Echo Note.

Example:

Original Vent:

◇ Nova

"I finally started something I've been afraid of for years."

Echo Note:

◇ Orion

"Needed to see this today.
I've been delaying my own project too."

---

## Rules

Echo Notes are not comments.

They are not debates.

They are not popularity signals.

They are personal reflections attached to another Voice's expression.

---

## Space Restrictions

Just Listen:

Echo Notes are disabled.

Reason:

The creator chose to be heard without inviting interaction.

---

Open Discussion:

Echo Notes are enabled.

Reason:

The creator has invited connection and conversation.

---

# 8. Shared Space Clarification

Decision:

A Space begins from an intentional Vent, but it is not limited to that Vent. A Space can become a shared experience where multiple Voices meet expressions that genuinely belong within that Space.

The first Vent establishes the initial context of the Space.

A later Voice does not "join a community" in the traditional social-media sense. They enter the Space to experience what is happening there and may contribute an expression when it genuinely belongs.

The Space therefore exists to organize **how Voices meet expression**, not simply where content is stored.

Current Space modes remain limited to:

- 🌊 Just Listen
- 💬 Open Discussion

Just Listen protects the creator's request for presence and does not allow normal discussion or Echo Notes.

Open Discussion allows perspectives and Echo Notes while remaining distinct from conventional comment threads.

## Moments and Feed

Space activity may produce meaningful **Moments**.

The Feed is a discovery layer for those Moments rather than a separate social-media world outside Spaces.

When a Voice encounters a Moment in the Feed and taps it, the intended destination is the Space from which that Moment came. The Voice should experience the surrounding Space context rather than being sent to a generic post/comment page.

```text
Voice
  ↓
Vent
  ↓
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
its Space
```

## Guardrails

Spaces must not become:

- Subreddits
- Facebook-style groups
- Discord-style channels
- Follower-based communities
- Popularity feeds
- Generic topic forums

Future Resonance or AI-assisted discovery may suggest related Spaces or expressions, but the Voice remains in control of participation.

This decision describes the intended product architecture. It does not claim that shared Spaces, persistent participation, Moments, or Feed-to-Space navigation are already implemented.
