# Research and Design Decisions

**Status:** Approved design baseline  
**Scope:** Local or hybrid LLM-assisted development for deliberately safe
Terraform and platform-engineering tasks.  
**Out of scope:** Production infrastructure changes, claims of absolute data
privacy, and a general claim that a local model replaces a cloud model.

## Question

Can a version-pinned local-first workflow complete defined Terraform and
platform-engineering tasks at an acceptable quality, latency, and operating
cost, while keeping human review as the control point for infrastructure
changes?

## Selected approach

The experiment uses a local-first workflow with an explicit cloud fallback:

| Concern | Decision |
| --- | --- |
| Local runtime | Evaluate an OpenAI-compatible local runtime on Apple Silicon. The baseline issue records the exact release, installation artifact, checksum where available, and configuration. |
| Primary model class | Evaluate a quantized code-capable mixture-of-experts model that fits with headroom in 48 GB of unified memory. Record the exact model publisher, revision, quantization, licence, and artifact checksum before every run. |
| Fallback | Use a cloud model only when the local run is stopped by a published routing rule. Do not silently retry through a cloud provider. |
| Agent integration | Use a CLI coding agent that can target the local OpenAI-compatible endpoint and records tool activity. The baseline issue pins its version and configuration. |
| IaC target | Use a self-contained Terraform fixture that validates and plans without provider credentials or remote state. |
| Approval | A human reads the generated diff and Terraform plan before any command that could affect infrastructure. The test fixture must never have credentials or a reachable production target. |
| Logging | Store experiment metadata and redacted metrics locally. Commit only reviewed, publishable aggregate results and prompt templates. |

The runtime and model are intentionally not treated as permanent choices. The
evaluation compares a declared pair of versions; a later run with different
versions is a new result, not a replacement for the first result.

## Why local-first, not local-only

The local-first design makes data movement a deliberate decision. It can
support offline work and remove API rate limits for local tasks, but it does
not make a workflow private by itself. Editor extensions, telemetry, model
downloads, remote repositories, tool calls, and cloud fallbacks remain
possible data paths.

The fallback is retained as a comparison point and escape hatch. It is
permitted only after a visible routing decision, with the prompt content and
reason recorded in the run metadata. Tasks containing credentials, personal
data, client data, or private infrastructure details are excluded rather than
routed.

## Alternatives considered

| Alternative | Decision |
| --- | --- |
| Cloud-only | Retained as a comparison condition, but it cannot answer whether a local workflow is useful. |
| Local-only | Rejected as the default because it hides the quality, latency, and cost trade-off of a controlled fallback. |
| Automatic quality-based routing | Deferred. A router may choose an inappropriate target or transmit more prompt content than intended. The first evaluation uses explicit, reviewable rules. |
| Real cloud infrastructure | Rejected. A local test target prevents an experiment from becoming a deployment path. |

## Risks and controls

| Risk | Control |
| --- | --- |
| Prompt or log disclosure | Exclude sensitive inputs, use redacted templates, and review all publishable artifacts. |
| Model licence incompatibility | Record the model card, licence, revision, and intended use before download. Do not redistribute weights. |
| Unrepeatable results | Record hardware, operating system, runtime, model revision and quantization, harness version, task revision, prompts, run order, and repeat count. |
| Invalid Terraform safety signal | Use offline validation and a fixture with no credentials, backend, or live provider target. |
| Selective reporting | Publish every attempted run in the defined corpus, including failures, timeouts, and abandoned tasks. |
| Cost claims without context | Separate applicable variable API and electricity estimates from sunk hardware cost, and state assumptions. |

## Evaluation protocol

The corpus will contain small, self-contained Terraform and platform tasks with
expected validation and plan outcomes. Each model-and-routing condition runs
every task at least three times from a clean checkout.

For each run, record:

- task completion and reviewer acceptance;
- `terraform fmt -check`, `terraform validate`, and plan quality;
- wall-clock latency and generated-token rate when exposed by the runtime;
- peak memory and CPU or GPU utilisation when the platform reports it;
- applicable API cost and the assumptions behind any electricity estimate;
- failure mode, timeout, tool-call error, and human intervention; and
- the machine specification, operating system, runtime, model, harness, task,
  prompt-template, and repository revisions.

The published evaluation must distinguish observations from recommendations. A
result on one machine and one model revision is not a general performance
claim.

## Sources and licences

The source material is cited as evidence and is not copied into this
repository. Before a source-derived artifact is added, its licence and
attribution requirements must be recorded.

1. Kevin Lewis, "[My local model setup on an M4 Pro Mac mini](https://lws.io/blog/my-local-model-setup/)" (1 September 2026; accessed 9 September 2026). This is a practitioner report, not a benchmark. It motivates the 48 GB Apple Silicon comparison profile and the need to record memory headroom.
2. [Awesome AI Model Routing](https://github.com/Not-Diamond/awesome-ai-model-routing) (accessed 9 September 2026). This catalogue establishes routing as an active design space; it does not validate a router for this experiment.
3. [Awesome Local LLM](https://github.com/rafska/awesome-local-llm) (accessed 9 September 2026). This catalogue is used to locate runtimes and evaluation resources, not as performance evidence.
4. [Awesome Agents](https://github.com/kyrolabs/awesome-agents) (accessed 9 September 2026). This catalogue is used to find agent integration alternatives.
5. [Awesome IaC](https://github.com/brandonhimpfen/awesome-iac) (accessed 9 September 2026). This catalogue identifies Terraform validation and testing tools relevant to the safe fixture.
