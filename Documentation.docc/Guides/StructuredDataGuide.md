# Structured Data Guide

AxiomWeb metadata supports first-class structured data nodes and graph composition.

## Key Rules
- Use typed `StructuredDataNode` values.
- Build graph via `Metadata.structuredData`.
- Strict validation fails builds when required fields are missing.
- JSON-LD output is deterministic and deduplicated by `@id`.
