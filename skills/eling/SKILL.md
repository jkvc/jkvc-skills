---
name: eling
description: >-
  Explain technical concepts, code, errors, or systems for a new-grad engineer
  or somewhat technical colleague, balancing practical impact with implementation
  detail. Use when the user says "ELING," "explain like I'm a new grad,"
  "new-grad level," "junior engineer," "somewhat technical colleague," or asks
  for an accessible technical explanation that assumes fundamentals but not
  domain expertise.
---

# Explain Like I'm a New Grad (ELING)

Explain the topic for a capable early-career engineer or somewhat technical
colleague. They can follow technical cause and effect, but may not yet know the
codebase, product domain, production practices, or historical context.

## Audience Baseline

For a new-grad engineer, assume familiarity with basic programming, data
structures, APIs, databases, version control, and testing. For a somewhat
technical colleague, assume comfort discussing systems, data, and implementation
at a conceptual level, but not necessarily writing or debugging the code.

When the audience is ambiguous, target the overlap: use real technical terms,
explain domain-specific jargon, and focus on purpose, data flow, consequences,
and tradeoffs. Do not assume company-specific systems, architectural history, or
production operations.

Respect the reader's technical foundation. Define unfamiliar terms and connect
new ideas to concepts they likely know, without using childish analogies or
removing the details needed to build sound engineering judgment.

## Understand the Subject First

Before explaining source material, understand its purpose and behavior:

- For code, inspect the relevant files and identify the role of the code before
  discussing syntax.
- For an error, distinguish the visible symptom from the likely root cause.
- For a system or concept, identify the problem it solves, where it fits, and
  its important constraints.
- Separate confirmed facts from inferences when the available context is
  incomplete.

## Shape the Explanation

Use the smallest useful subset of this progression:

1. State what it is and why it matters in one or two sentences.
2. Give the missing context: what problem it solves and where it sits in the
   larger system.
3. Bridge from a familiar concept, then use a concrete example or trace one
   realistic request through the system.
4. Explain the mechanism with correct technical terms, defining each unfamiliar
   term on first use.
5. Call out the tradeoffs, failure modes, or operational consequences that help
   develop engineering judgment.
6. End with what the reader should remember or inspect next.

Balance a manager's concern for impact with an engineer's need to understand
mechanism. Lead with user or system consequences, then show how the implementation
produces them. Give enough internal detail for the reader to reason and
collaborate, but skip implementation trivia that does not improve understanding.
Quantify impact only when the evidence supports it.

## Examples

**Database index**

"A database index is an extra data structure that makes selected lookups faster,
usually at the cost of storage and slower writes. If you know a hash map or a
book's index, the core tradeoff is similar: maintain an organized lookup path so
the database does not scan every row. For example, an index on `users.email` can
turn a login lookup from a full table scan into a targeted search. The next thing
to inspect is whether the query shape actually matches the index and whether the
write overhead is acceptable."

**API rate limiting**

"Rate limiting protects a service by capping how quickly a caller can consume
resources. Think of it as admission control in front of the handler: each request
spends from a quota, and requests beyond that quota are delayed or rejected. The
product impact is fewer overload cascades; the engineering tradeoff is that
legitimate traffic bursts can fail unless clients back off and retry safely."

**Explaining code**

"This hook keeps the component synchronized with an external subscription. On
mount it subscribes, and its cleanup unsubscribes before the component disappears
or the dependency changes. The dependency array matters because it defines when
React must replace that subscription. A missing dependency can leave the callback
using stale state; an unstable dependency can cause unnecessary resubscriptions."

## Guardrails

- Do not talk down to the reader or confuse inexperience with lack of ability.
- Do not replace precise terminology with analogy; use analogy as a bridge, then
  give the real term and mechanism.
- Do not bury the purpose under syntax or implementation trivia.
- Do not pretend a simplified model covers important exceptions. Name the caveat
  briefly and expand it when it changes a decision.
- Prefer one strong, relevant example over several shallow ones.
