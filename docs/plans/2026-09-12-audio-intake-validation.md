# Local audio intake validation

Follow the approved shared audio standard, outside Flutter runtime. Extend the
existing Python audio-tooling directory with a read-only JSON intake checker.
No new dependencies, network, generation, playback, copying or promotion.

1. Add isolated unittest fixtures in temporary directories: valid evidence
   structure, missing provenance, changed file hash, path escape, false approval,
   invalid measurements and prohibited breathing/hold substitutions.
2. Reproduce failures, then implement record checks and a CLI returning only
   field/error codes, never record values. Resolve file paths inside a supplied
   root before reading. Hash the actual source/master/deliverable bytes.
3. Independently review; verify tests, analyzer and the complete diff. Document
   the schema and evidence limitations; commit only on releaf-development.

A clean report means internally consistent submitted evidence, not verification
of copyright ownership, acoustic content, authenticity or owner consent. Do not
manufacture records for missing recordings. Existing approved runtime audio is
not reclassified by this prospective intake tool.
