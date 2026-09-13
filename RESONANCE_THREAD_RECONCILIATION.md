# Resonance Thread Reconciliation

## Status

Implemented and verified foundation.

Thread reconciliation keeps historical Thread structure intact while deriving its current discoverability from the latest Resonance connection state.

## Why Reconciliation Exists

A Resonance Thread is a historical pattern between experiences. A connection inside that Thread can later change state:

- accepted → active
- active → closed
- active → blocked
- other valid lifecycle transitions

The Thread should not be deleted simply because one relationship closes. Instead, Resonance must refresh the Thread against the latest connection state and determine whether the Thread is currently safe and meaningful to discover.

## Core Rule

```text
Thread history ≠ current discoverability
```

Historical connections remain part of the Thread. Current connection state determines whether the Thread is active, dormant, or restricted.

## Reconciliation Flow

```text
Connection lifecycle change
        ↓
ResonanceConnectionService
        ↓
Persist updated connection
        ↓
Find Threads involving either endpoint
        ↓
ResonanceThreadReconciliationService
        ↓
Refresh current connection objects
        ↓
Preserve historical connections
        ↓
ResonanceThreadIntegrityPolicy
        ↓
ACTIVE / DORMANT / RESTRICTED
```

## Reconciliation Service

`ResonanceThreadReconciliationService` performs four responsibilities:

1. Load the persisted Thread.
2. Retrieve the latest connections involving the Thread's experiences.
3. Merge refreshed connections with historical connections.
4. Evaluate and persist the reconciled Thread.

The service does not perform matching. Matching remains centralized inside Resonance.

## Connection History

Reconciliation intentionally preserves historical connections that are no longer returned by current storage.

For example:

```text
Thread
 ├── Connection A: active
 └── Connection B: closed
```

If Connection B is no longer returned by a current discovery query, it is still retained in the Thread because it is part of the historical relationship structure.

## Integrity States

### Active

At least one meaningful live connection remains.

Meaningful live connections currently require:

- accepted or active state
- strength >= 0.6
- type of `sharedExperience`, `response`, or `perspective`

### Dormant

No meaningful live connection remains and there are no blocked connections requiring restriction.

The Thread remains stored as history but is not currently discoverable as an active Resonance Thread.

### Restricted

No meaningful live connection remains and at least one blocked connection remains.

This prevents a blocked relationship from being treated as a discoverable live connection.

### Invalid

The Thread structure violates its connection/experience invariants.

The Thread model itself already rejects these invalid structures during creation, so this policy also acts as a defensive integrity boundary.

## Connection Lifecycle Integration

`ResonanceConnectionService` now triggers reconciliation after a successful lifecycle transition.

Affected Threads are discovered through both connection endpoints:

```text
connection.sourceId
        ↓
threads involving source

connection.targetId
        ↓
threads involving target
```

Thread IDs are deduplicated before reconciliation.

This means a state change such as:

```text
ACTIVE → CLOSED
```

can immediately cause affected Threads to be re-evaluated without putting Thread logic inside the UI or inside the connection lifecycle policy.

## Architectural Boundary

```text
UI
 ↓
Riverpod
 ↓
ResonanceConnectionService
 ↓
ResonanceConnectionLifecycle
 ↓
ResonanceEngine
 ↓
ResonanceThreadReconciliationService
 ↓
ResonanceThreadIntegrityPolicy
 ↓
ResonanceRepository
```

The responsibilities remain separate:

- **Lifecycle** decides whether a connection state transition is legal.
- **Engine** coordinates Resonance operations and persistence boundaries.
- **Reconciliation** synchronizes Thread state with current connection state.
- **Integrity Policy** determines current Thread status.
- **Repository** stores the domain state.

## CS Concepts Demonstrated

### State reconciliation

The service compares persisted historical state with current authoritative state and produces a consistent domain representation.

### Separation of concerns

Lifecycle validation, reconciliation, integrity evaluation, and persistence are separate responsibilities.

### Idempotency

Running reconciliation repeatedly should produce the same effective Thread state when the underlying connection state has not changed.

### Graph consistency

A Thread represents a graph of experiences connected by Resonance connections. Reconciliation keeps the graph historically complete while evaluating which edges are currently meaningful.

### Dependency injection

Connection lifecycle code receives reconciliation as a dependency rather than constructing storage or matching logic itself. This keeps the system testable and replaceable.

## Product Boundary

This system is intentionally independent of Feed, Space, and Crash Out UI.

Those surfaces consume Resonance results. They do not own Thread matching or reconciliation.

Crash Out can eventually supply an experience to Resonance, and Feed/Space can display Resonance-derived experiences, but the underlying relationship lifecycle remains in the shared Resonance system.

## Verification

The implementation was verified with:

```bash
git pull origin development
flutter analyze
flutter test
```

Result: all tests passed with no issues.

## Next Boundary

With Thread formation, evolution, integrity, reconciliation, and lifecycle integration established, the next work should remain in the Resonance/domain layer before returning to Feed or Space UI.

The next candidate is to strengthen the **Thread/Connection query boundary and discovery rules**, so product surfaces can safely ask Resonance for active, dormant, restricted, or historically related Threads without implementing their own filtering logic.
