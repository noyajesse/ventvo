# Ventro Architecture

## Overview

Ventro is an anonymous community platform designed for people to express their thoughts, frustrations, experiences, and opinions without the pressure of traditional social media.

The goal is to create a space where people can share honestly, find others with similar experiences, and have meaningful conversations.

Unlike traditional social platforms that focus on followers, popularity, and personal branding, Ventro focuses on authenticity, connection, and expression.

---

# Core Concept

Ventro supports two main types of expression:

## Personal Vents

Users can share personal experiences, emotions, challenges, and situations.

Examples:
- Personal struggles
- Life experiences
- Challenges
- Advice requests

## World Vents

Users can discuss opinions, social topics, events, and ideas.

Examples:
- Society
- Culture
- Current issues
- General discussions

---

# Platform Philosophy

Ventro is built around:

- Anonymous expression
- Meaningful conversations
- Emotional honesty
- Community support
- Reduced social pressure

The platform should avoid becoming a popularity competition.

---

# Initial Technology Stack

## Frontend

Technology:
- Flutter
- Dart

Purpose:
- Cross-platform mobile application development
- Android and iOS support

---

## Backend

Planned:

- Backend API
- Authentication system
- Database
- Cloud storage

(The final backend technology will be decided after evaluating requirements.)

---

# Core Features (MVP)

## User System

Users should be able to:

- Create an account
- Maintain an anonymous identity
- Manage their profile
- Control privacy settings

---

## Crashouts (Posts)

Users should be able to:

- Create a Crashout
- Select a category or mood
- Read other Crashouts
- React to posts
- Respond through comments

---

## Community Interaction

Users should be able to:

- Validate posts
- Join discussions
- Find similar experiences
- Report harmful content

---

# Main App Screens (Initial)

## Welcome Screen

Purpose:
Introduce Ventro and its purpose.

---

## Authentication Screen

Purpose:
Allow users to create accounts or sign in.

---

## Home Feed

Purpose:
Display community Crashouts.

Possible sections:
- Trending
- Recent
- Categories

---

## Create Crashout Screen

Purpose:
Allow users to express themselves.

Possible inputs:
- Text
- Mood
- Category
- What type of response they want

---

## Comments/Discussion Screen

Purpose:
Allow meaningful conversations.

---

## Profile Screen

Purpose:
Manage user settings and history.

---

# Initial Data Structure

Planned entities:

## Users

Stores:
- User ID
- Username
- Profile settings
- Account information

---

## Crashouts

Stores:
- Crashout ID
- Author ID
- Content
- Category
- Timestamp
- Reaction count

---

## Comments

Stores:
- Comment ID
- Crashout ID
- Author ID
- Content
- Timestamp

---

## Reports

Stores:
- Report ID
- Content ID
- Reason
- Status

---

# Security Considerations

Because Ventro involves anonymous expression, security is a priority.

Initial security goals:

- Protect user information
- Prevent harassment
- Prevent spam
- Provide reporting tools
- Moderate harmful content
- Secure authentication

---

# Development Approach

Every feature follows:

1. Planning
2. Architecture review
3. Implementation
4. Testing
5. Security review
6. Git commit
7. GitHub backup

---

# Current Status

Version:
0.1.0

Current achievement:

- Flutter environment configured
- Project created
- GitHub connected
- Initial documentation created

Next phase:

Designing the user experience and implementing the first Ventro screens.
---

# Product Decisions

## Identity System

Ventro uses a hybrid anonymous identity model.

Users have private accounts for security and accountability, but their public identity remains anonymous.

Public users see:
- Anonymous username
- Avatar
- User-created identity

Private system data:
- Account ID
- Authentication information
- Security information

This allows freedom of expression while preventing abuse.

---

## Feed System

Ventro will use a personalized feed.

Initial version:
- User-selected interests
- Categories
- Mood preferences
- Engagement history

Future versions may include:
- Machine learning recommendations
- Similar experience matching

Privacy principle:
Personalization should improve discovery without exposing private user information.

---

## Content System

The main content type in Ventro is called a Crashout.

Users can create Crashouts containing:

- Text
- Optional images
- Category
- Mood

Initial categories:
- Personal Life
- Relationships
- School & Career
- Society & World
- Advice Needed
- Random

Mood selection:
- Angry
- Sad
- Stressed
- Disappointed
- Confused
- Hopeful
- Funny
- Thinking

---

## Interaction System

Users can:

- Validate Crashouts
- Respond through comments
- Report harmful content

Validation replaces traditional "likes" because it represents understanding rather than popularity.

---

## Safety Philosophy

Ventro prioritizes anonymous expression while maintaining accountability.

The platform will include:

- Reporting system
- Content moderation
- Account restrictions
- Abuse prevention systems

---

## Future Expansion

Ventro may introduce Circles.

Circles are interest-based communities where users can connect around shared interests.

Examples:
- Anime & Manga
- Gaming
- Technology
- Movies
- Books

Circles will be developed after the core Ventro experience is established.