## Product Direction Review - Ventvo Principles

Date: 2026-08-02

Completed:
- Reviewed Ventvo's core purpose and direction.
- Defined Ventvo as a connection system built around human moments, not a traditional social media platform.
- Created VENTVO_PRINCIPLES.md as the product decision filter for future features.

Key decisions:
- Voice remains the foundation instead of traditional profiles.
- Vents represent moments, not normal social posts.
- Connection is measured through Resonance instead of likes or popularity.
- Just Listen and Open Discussion now have different interaction rules.
- Just Listen allows Resonance but does not allow Echo Notes or Discussion.
- Open Discussion allows Resonance, Echo Notes, Discussion, and optional Crash Out.
- Echo Notes are reflections, not comments.
- Crash Out remains a temporary shared emotional space.

Development principle:
Every future feature must solve a real human problem and strengthen Ventvo's purpose of helping people express themselves and feel understood.
# Ventvo Development Log

## Version 0.1.0 - Initial Setup
---

## Version 0.1.1 - Ventvo Voice Experience

## Completed

### Ventvo Voice Identity System

- Replaced the original Ventvo Voice prototype screen.
- Created a new Ventvo Voice onboarding journey.
- Added Voice Welcome screen.
- Added Voice Discovery screen.
- Added Voice Mark selection.
- Added Voice Created confirmation screen.
- Connected authentication flow to Ventvo Voice creation.
- Improved feature organization inside the Flutter project.

### Project Structure Updates

- Reorganized features into dedicated modules:
  - auth
  - onboarding
  - ventvo_voice
  - home
  - vents
  - spaces
  - crash_out

### Git Development

- Created development branch workflow.
- Updated documentation to reflect current architecture.
- Maintained clean commits for feature progression.

Date: July 2026

## Completed

### Development Environment Setup
- Installed Flutter SDK.
- Added Flutter to system PATH.
- Verified Flutter installation using `flutter doctor`.
- Installed and configured Android SDK.
- Accepted Android licenses.
- Verified Flutter can detect development devices.

### Flutter Project Creation
- Created the Flutter project:
  - Name: project_Ventvo
  - App name: Ventvo
  - Location: C:\Development\Projects\project_Ventvo

- Tested the default Flutter application successfully.
- Confirmed the application runs in Chrome.

### Git Setup
- Installed Git.
- Configured Git username and email.
- Initialized Git repository.
- Added Flutter project files to Git tracking.
- Created first commit:

"Initial Ventvo Flutter project setup"

### GitHub Setup
- Created GitHub repository:
  https://github.com/noyajesse/Ventvo

- Connected local Flutter project to GitHub remote repository.

## Current Project State
Current Milestone:
Ventvo Voice onboarding system completed.

The application now supports anonymous identity creation through Ventvo Voice before entering the main Ventvo experience.

Ventvo is currently a clean Flutter starter project.

No custom application features have been developed yet.

The next phase will focus on:
- Designing the application architecture.
- Planning database structure.
- Designing user flows.
- Creating the first Ventvo UI screens.

## Development Workflow

Every feature should follow this process:

1. Plan the feature.
2. Design the solution.
3. Review security considerations.
4. Implement the feature.
5. Test thoroughly.
6. Review code.
7. Commit changes to Git.
8. Push changes to GitHub.
### Documentation Practice

Every major feature must include documentation updates before completion.

Development process:

1. Plan the feature
2. Build the feature
3. Test and fix issues
4. Update documentation
5. Commit changes
6. Push to GitHub

Documentation should capture:

- Feature purpose
- User experience flow
- Technical structure changes
- Important development decisions
## Ventvo Voice v0.2 Complete

Completed:
- Built Ventvo Voice onboarding flow
- Added Discovery, Resonance, Mark, Name, Birth stages
- Connected screen navigation
- Added engineering documentation
- Added security principles documentation
- Added product vision documentation

Next:
- Implement Ventvo Voice state management
- Connect Voice model across onboarding
## 2026-08-01

### Ventvo Feed Foundation

Completed the first connection between user expression and community discovery.

Changes:
- Added Feed feature structure.
- Connected FeedScreen to ventProvider.
- Vents created by users can now appear in Feed.
- Updated VoiceSpace to display real Vent count from Riverpod.
- Added temporary navigation between VoiceSpace and Feed for testing.

Current flow:

Voice → Create Vent → ventProvider → VoiceSpace → Feed

Next:
- Improve Feed card design.
- Build Echo interaction.
- Design Echo Note system.
## 2026-08-01

# Ventvo Feed Foundation Completed

## Completed

- Connected VoiceSpace with Vent creation.
- Added Riverpod ventProvider for storing Vents.
- VoiceSpace now displays created Vents.
- Created Ventvo Feed screen.
- Connected Feed with ventProvider.
- Tested full flow:

Voice → Create Vent → VoiceSpace → Feed

## Product Decisions Locked

### Just Listen

Just Listen is a protected space.

Allowed:
- Echo

Not allowed:
- Comments
- Echo Notes
- Advice

The purpose is to let someone express themselves without pressure.

---

### Open Discussion

Open Discussion allows deeper connection.

Allowed:
- Echo
- Echo Notes
- Discussion

Echo Notes are not comments.

An Echo Note represents someone saying:

"I relate to this experience."

Echo Notes belong to an Echo, not directly to a Vent.

---

### Crash Out

Crash Out is not a Vent interaction type.

It is a temporary shared experience created when people discover a strong resonance with the same situation.

Flow:

Vent/Moment
↓
Echoes
↓
Shared resonance
↓
Crash Out experience

## Next Development Stage

Feed redesign:

- Make Feed cards feel like Ventvo.
- Introduce Voice identity.
- Prepare structure for Echo.
- Prepare future Resonance Map connection.
## Feed Identity Decision

Ventvo Feed will prioritize Voice over profile identity.

Default Feed display:
- Voice symbol
- Expression
- Interaction space

Identity can become more visible as connection and resonance grows.

Ventvo avoids follower-based identity and focuses on meaningful connection.
## Voice Identity Connected to Vents

Completed:
- Connected CreateVentScreen with ventvoVoiceProvider.
- Vents now store the Voice mark that created them.
- Feed cards now display the actual Voice identity.
- Established relationship:

Voice → Vent → Feed

This creates the foundation for future:
- Echo
- Echo Notes
- Resonance Map
- Arc
- Moments
## Feed Experience Upgrade

Completed:
- Created reusable VentCard widget.
- Connected Feed display to Voice identity.
- Updated Feed language from social media interactions to Ventvo spaces.
- Added Resonance foundation.

Current flow:

Voice → Vent → Space → Resonance → Echo
## Foundation Review - Vent System

Changes:
- Refined Vent terminology.
- Changed interactionType to spaceType.
- Updated Vent creation and display flow.
- Clarified that a Vent creates a space rather than selecting an interaction method.

Reason:
The terminology now matches Ventvo's core philosophy:
users create spaces for expression, listening, and conversation.
## 2026-08-08

# Ventvo Connection Spaces & Crash Out Foundation

## Voice Experience Progress

Completed and tested the core Ventvo Voice experience.

Changes:

* Continued development of the Ventvo Voice identity system.
* Voice creation flow is functional.
* Voice Space displays the user's Voice identity and created Vents.
* Navigation between Voice-related screens was tested.
* Back navigation was treated as a development/navigation concern rather than adding a physical back button to every screen.

Current relationship:

Voice → Voice Space → Vents → Feed

---

## Just Listen

Completed the first prototype of the Just Listen experience.

Product decision:

Just Listen is intentionally different from normal social interaction.

Purpose:

> Someone can express a moment without asking people to fix it.

Current prototype behavior:

* A user can select Just Listen when creating a Vent.
* The Feed identifies the Vent as a Listening Space.
* A listener can select "Heard".
* The current Heard/check interaction is a prototype demonstration only.

Important:

The current local Heard state is not the final production behavior.

Future production behavior will require persistent interaction state and backend storage.

---

## Open Discussion

Completed the first Open Discussion prototype.

Product decision:

Open Discussion provides a space where people can engage more deeply with a Vent.

Current prototype behavior:

* Open Discussion Vents are identified separately from Just Listen Vents.
* Feed displays an "Open Discussion Space".
* Users can select "Join Discussion".
* A dedicated DiscussionScreen has been created.
* Navigation into and back from the discussion experience has been tested.

Current state:

The discussion experience is currently a functional prototype.

Future work will include:

* Persistent discussions
* Real participant data
* Discussion state
* Echo Notes
* Proper connection and conversation rules

---

# Crash Out Direction Review

Crash Out was re-evaluated based on Ventvo's core purpose and the problem Ventvo is intended to solve.

## Product Definition

Crash Out is not intended to be a diary, notes application, or simple emotional dumping tool.

Crash Out is Ventvo's private release-and-connection pathway.

The user can release something without immediately needing to explain it, justify it, or interact with anyone.

## Crash Out Experience

Initial direction:

Crash Out
↓
Release
↓
Choose what happens next

Possible outcomes:

* Let Go
* Keep Private
* Turn into a Vent
* Find People Who Understand

The original Crash Out remains private unless the user intentionally chooses otherwise.

---

## Human Connection Direction

The strongest new direction for Crash Out is:

> Find People Who Understand.

Instead of immediately providing advice or attempting to act as therapy, Ventvo can eventually help the user discover a small group of Voices with sufficiently similar experiences.

Target experience:

Crash Out
↓
Private understanding
↓
Compatibility matching
↓
Up to 3 Voices
↓
Small Circle
↓
Just Listen / Open Discussion

Users do not need to be told that they are being "matched" in a technical sense.

The experience should feel like:

> "These are people who understand."

rather than:

> "An algorithm matched you."

---

## AI Matching Direction

AI matching is a future system component.

AI will eventually help identify meaningful similarities between experiences rather than relying only on simple keywords.

The system should consider factors such as:

* Situation
* Experience
* Context
* Connection need
* Desired interaction style

The goal is not to diagnose users or provide therapy.

The goal is to help Ventvo discover people who may genuinely understand one another.

### Development Strategy

AI matching will NOT be implemented yet.

During development, the matching experience can use demonstration data.

This allows the product experience to be tested before building the complete backend and AI infrastructure.

---

# Crash Out Technical Foundation

Crash Out has been separated from the Vent model.

This is an important architectural decision.

A Crash Out is not simply another type of Vent.

A Crash Out begins as a private release and can later become a Vent if the user chooses.

Created:

* `features/crash_out/models/crash_out.dart`
* `features/crash_out/providers/crash_out_provider.dart`

### Crash Out Model

The model currently supports:

* Text Crash Outs
* Future voice Crash Outs
* Creation timestamps
* Crash Out status
* Matching eligibility
* Connection need

Current statuses include:

* Released
* Kept Private
* Let Go
* Converted to Vent
* Finding People

Current connection needs include:

* Just Listen
* Shared Experience
* Open Discussion
* Unsure

### Provider

Created a dedicated `crashOutProvider`.

The provider currently supports:

* Adding Crash Outs
* Updating Crash Out status
* Enabling matching
* Deleting Crash Outs

The provider remains independent from `ventProvider`.

---

# Current Product Architecture

Ventvo now has two distinct expression pathways:

### Vent

Voice
↓
Vent
↓
Space
↓
Resonance
↓
Connection

### Crash Out

Private Release
↓
Choose what happens
↓
Keep / Let Go / Vent / Find People
↓
Future compatibility matching
↓
Small Circle
↓
Just Listen / Open Discussion

This separation should be preserved as development continues.

---

# Current Development Principle

Crash Out should not become a collection of unrelated features.

Every addition must strengthen one of two purposes:

1. Give someone a safe way to release what they are carrying.
2. Help them find meaningful human understanding when they want it.

The feature should remain simple enough that the user immediately understands what it is for.

## Next Development Stage

Build the Crash Out entry experience.

Planned:

* Crash Out entry screen
* Text release
* Voice release foundation
* Release/fate screen
* Demo "Find People Who Understand" experience
* Small Circle prototype
* Connection to Just Listen and Open Discussion

AI matching and backend matching infrastructure will come later.
