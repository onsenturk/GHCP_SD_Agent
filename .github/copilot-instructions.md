# Copilot Instructions for GHCP_SD_Agent

## Repository Purpose (Big Picture)
- This is a governance repository, not an application runtime.
- Core responsibilities are defined in:
  - `copilot-instructions.md` (global execution contract)
  - `agents/engineering-standards.md` (non-negotiable standards)
  - `agents/dod.md` (completion gate)
  - `agents/feature-request-template.md` and `agents/change-request-template.md` (request intake)
- Treat these files as policy sources of truth; do not introduce behavior that conflicts with them.

## Working Model for AI Agents
- Start from a request template in `agents/` and keep scope tightly bounded.
- Before implementation, explicitly cover: impacted layers, architecture plan, security, docs impact, infra impact.
- Required response sequence for feature work is defined in `copilot-instructions.md`:
  1. Impacted Layers
  2. Architecture Plan
  3. Security Considerations
  4. Documentation Updates Required
  5. Infrastructure Impact
  6. Implementation
  7. Definition of Done Validation

## Project-Specific Conventions
- Do not refactor unrelated files.
- Prefer the simplest viable solution; avoid speculative abstractions.
- Enforce layered architecture language (API / Domain / Infrastructure / Web / Mobile) in analysis.
- Azure is the only approved cloud direction unless explicitly documented otherwise.
- Infrastructure changes must be IaC-driven (Bicep or Terraform), never manual-only steps.

## Documentation and DoD Gates
- For behavior/structure/config/infra changes, update docs called out in `agents/dod.md` and `copilot-instructions.md` (for example `README.md`, `requirements.md`, `architecture.md`, `deployment.md`, OpenAPI, `.env.example` when applicable).
- A task is incomplete until explicitly validated against `agents/dod.md`.
- Security verification must be explicit (no hardcoded secrets, input validation, OWASP-oriented review, rate limiting for public APIs where applicable).

## Build/Test/Run Workflow in This Repo
- No build system or runnable app is currently defined in repository files.
- Do not invent commands; only run/describe commands that are discoverable from the repo.
- Validation here is primarily standards + documentation compliance unless executable assets are added.

## Practical Examples in This Repo
- Use `agents/feature-request-template.md` to structure new feature work.
- Use `agents/change-request-template.md` for fixes/behavior changes and mandatory impact analysis.
- Use `agents/dod.md` as the final checklist before considering work complete.