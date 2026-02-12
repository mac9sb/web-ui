# ADR-0002: Structured Data Is First-Class Metadata

## Status
Accepted

## Decision
Structured data is modeled as typed nodes and emitted as validated JSON-LD from metadata.

## Consequences
- No raw JSON-LD string APIs for standard use.
- Build can fail in strict mode for invalid schema nodes.
- Deterministic graph serialization enables stable snapshots.
