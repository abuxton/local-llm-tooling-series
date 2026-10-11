# Reproducible Baseline Local Environment

**Status:** Baseline configuration for issue
[#70](https://github.com/abuxton/abuxton.github.io/issues/70).  
**Purpose:** Provide a public, repeatable local-first environment for the
series. It is not a production deployment path or a privacy guarantee.

## Pinned components

| Component | Pin | Verification |
| --- | --- | --- |
| Host profile | Apple Silicon with 48 GB unified memory | Record the actual model, macOS version, and free-memory headroom for each run. |
| Local runtime | [Ollama v0.40.1](https://github.com/ollama/ollama/releases/tag/v0.40.1) | `ollama-darwin.tgz` SHA-256: `66e1587711f3a06315b23782ba74897001da6c8b8edf6c0371f7533015a076dd`. |
| Local model | `qwen2.5-coder:7b` | Registry manifest digest: `sha256:dae161e27b0e90dd1856c8bb3209201fd6736d8eb66298e75ed87571486f4364`. |
| Agent client | `aider-chat==0.86.1` | Installed solely from [`requirements-agent.txt`](../requirements-agent.txt). |
| IaC CLI | [Terraform v1.13.5](https://github.com/hashicorp/terraform/releases/tag/v1.13.5) | `terraform version` must report exactly `Terraform v1.13.5` before using the fixture. |

Ollama's registry tag is resolved to the manifest digest above before the
experiment begins. Record `ollama show qwen2.5-coder:7b --verbose` with the
run metadata; do not commit that output unless it has been reviewed for
sensitive content. The model is obtained from its publisher through Ollama;
this repository neither copies nor redistributes model weights. Review the
model licence and intended-use terms before download.

## Install the local runtime and agent

The runtime release is versioned and checksummed. Download only the named
artifact, verify it, then unpack it according to the
[Ollama release instructions](https://github.com/ollama/ollama/releases/tag/v0.40.1).
Do not run a network installer that can select a newer release.

```sh
curl --fail --location --output ollama-darwin.tgz \
  https://github.com/ollama/ollama/releases/download/v0.40.1/ollama-darwin.tgz
printf '%s  %s\n' \
  '66e1587711f3a06315b23782ba74897001da6c8b8edf6c0371f7533015a076dd' \
  ollama-darwin.tgz | shasum -a 256 --check
```

Start the verified local runtime, then retrieve the declared model:

```sh
ollama serve
ollama pull qwen2.5-coder:7b
ollama show qwen2.5-coder:7b --verbose
```

Use an isolated Python environment for the pinned agent:

```sh
python3 -m venv .venv
. .venv/bin/activate
python -m pip install --requirement requirements-agent.txt
./scripts/run-local-agent.sh
```

`run-local-agent.sh` fixes the OpenAI-compatible endpoint to
`http://127.0.0.1:11434/v1`, disables automatic commits, and prevents Aider
from retaining chat-history files. It intentionally does not configure a
cloud endpoint or a fallback. A later routing experiment may use one only
after an explicit, reviewed routing decision.

## Secrets and data boundary

Do not put credentials, tokens, client data, personal data, private
infrastructure details, model weights, raw prompts, runtime caches, or raw
agent logs in this repository or in an agent prompt. The `.gitignore` rules
exclude common local configuration, model, log, agent, and Terraform
artifacts, but they are not a substitute for review.

Use `git status --ignored` before committing and inspect every staged file.
The local endpoint uses the literal `ollama` value only as a placeholder for
OpenAI-compatible clients; it is not a credential. If a prompt needs a real
secret, exclude that task from the experiment instead of injecting it through
an environment variable.

## Local logging

Keep run metadata and any unredacted diagnostic output in the ignored `logs/`
directory. Record the following in a reviewed, publishable aggregate only:

- machine model, memory, operating-system version, and free-memory headroom;
- runtime, model manifest, Terraform, and agent versions;
- task, prompt-template, and repository revisions;
- start/end times, completion state, validation/plan result, and failure
  category; and
- applicable API cost only when an approved cloud comparison is used.

Raw prompts, responses, tool transcripts, and file paths can contain sensitive
information. They remain local and are never a default publication artifact.

## Safe Terraform sandbox

[`terraform/sandbox`](../terraform/sandbox) declares only the Terraform-core
`terraform_data` resource. It has no provider configuration, remote backend,
credentials, modules, or reachable infrastructure target. The only supported
commands are:

```sh
make sandbox-validate
make sandbox-plan
```

`make sandbox-plan` initializes with `-backend=false`, disables refresh, writes
an ignored local plan file, prints it for inspection, and then stops. The
Makefile deliberately has no `apply`, `destroy`, or deployment target.

> **Human-review boundary:** A person must inspect both the generated source
> diff and the printed Terraform plan before any command that could change
> infrastructure. This fixture must never be repointed at a real provider or
> backend.

## Sources

- [Ollama v0.40.1 release](https://github.com/ollama/ollama/releases/tag/v0.40.1),
  accessed 8 October 2026. The release supplies the runtime artifact and
  published SHA-256 digest.
- [Ollama model library: Qwen2.5-Coder](https://ollama.com/library/qwen2.5-coder),
  accessed 8 October 2026. The registry manifest digest above identifies the
  selected local model artifact.
- [Aider installation documentation](https://aider.chat/docs/install.html),
  accessed 8 October 2026. It documents the isolated Python installation used
  for the pinned CLI client.
- [Terraform v1.13.5 release](https://github.com/hashicorp/terraform/releases/tag/v1.13.5),
  accessed 8 October 2026. It supplies the version range used by the isolated
  validation and plan fixture.
