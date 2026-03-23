# ADR 0001: Offline Sync Conflict Resolution

## Status
Accepted

## Context
The app is offline-first and queues writes locally before syncing to Supabase. Concurrent edits can happen between local queue items and server-side updates.

## Decision
Use timestamp-based conflict resolution with this rule:
- if `local_timestamp > server_timestamp` -> push local
- otherwise -> prompt user for conflict decision

Queue model remains append-only retries with bounded retry count.

## Consequences
- Predictable merge policy and lower silent data loss risk.
- Requires server records to expose consistent timestamps.
- User prompts are needed in ambiguous conflicts.
