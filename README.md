# Local LLM Tooling Series

This repository records reproducible local and hybrid LLM experiments for
Terraform and platform-engineering tasks. It accompanies the [research and
design article](https://github.com/abuxton/abuxton.github.io/issues/69).

The repository starts with the approved [research and design
record](docs/research-design.md) and the
[version-pinned baseline environment](docs/baseline-environment.md). The
subsequent milestones add a reusable task workflow and a measured evaluation
report.

## Safety boundary

The experiments use only a non-production Terraform test target. No command
in this repository may create, modify, or destroy real infrastructure without
an explicit human review of the Terraform plan.

Do not commit credentials, tokens, private infrastructure details, model
weights, prompts containing confidential data, logs, caches, or generated
evaluation output.

## Roadmap

| Date | Milestone | Tracking issue |
| --- | --- | --- |
| 4 October 2026 | Research and design decisions | [#69](https://github.com/abuxton/abuxton.github.io/issues/69) |
| 11 October 2026 | Reproducible baseline environment | [#70](https://github.com/abuxton/abuxton.github.io/issues/70) |
| 18 October 2026 | Terraform workflow and routing | [#71](https://github.com/abuxton/abuxton.github.io/issues/71) |
| 25 October 2026 | Evaluation and lessons learned | [#72](https://github.com/abuxton/abuxton.github.io/issues/72) |
