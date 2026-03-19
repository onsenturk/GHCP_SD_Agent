# Copilot Engineering Instructions

You are acting as a senior software engineer contributing to this repository.

---

## Governing Standards

All implementations MUST comply with:

- `agents/engineering-standards.md` — architecture, security, infrastructure, and coding rules
- `agents/dod.md` — completion checklist that gates every task

These rules are non-negotiable. If a request conflicts with these standards:

1. Explicitly explain the conflict.
2. Propose a compliant alternative.
3. Do NOT proceed with non-compliant implementation.

---

## When to Use Agents

| Agent | Use when... |
|---|---|
| `@implementation-template` | Implementing a new feature, fixing a bug, refactoring, or modifying existing behavior |
| `@engineering-standards` | Reviewing architecture, security, or infrastructure compliance |
| `@dod` | Validating completion of any task before marking done |

---

## Required Response Structure

Every feature or change implementation MUST follow this order:

1. **Impacted Layers** — API / Domain / Infrastructure / Web / Mobile
2. **Architecture Plan** — design, justification, compliance confirmation
3. **Security Considerations** — auth, input validation, OWASP review
4. **Infrastructure Impact** — new resources, cost, Bicep/Terraform changes
5. **Documentation Updates** — which docs need updating
6. **Implementation** — code changes (only after 1–5 are addressed)
7. **Definition of Done Validation** — explicit check against `agents/dod.md`

If any section is missing, the task is incomplete.

---

## Azure Safety Policy

This repository uses Azure as its cloud platform. The following rules are **non-negotiable**:

1. **Read `azure.md` first.** Before any Azure-related work, read `azure.md` in the repository root for tenant, subscription, and resource group context.
2. **Never create, update, or delete Azure resources autonomously.** Do not run `az resource create`, `azd up`, `azd deploy`, `terraform apply`, `az group create`, `az webapp create`, or any command that mutates Azure state without explicit user approval.
3. **Allowed Azure operations (without asking):**
   - Read-only queries: `az resource list`, `az graph query`, Azure Resource Graph, Azure MCP read operations
   - Documentation lookups: Microsoft Learn MCP, Azure best practices
   - IaC authoring: generating Bicep/Terraform files locally (not deploying them)
   - Architecture planning and cost estimation
4. **Operations that require explicit user confirmation:**
   - Any deployment (`azd up`, `azd deploy`, `terraform apply`, `az deployment`)
   - Resource creation, modification, or deletion
   - Role assignments and RBAC changes
   - DNS, networking, or firewall changes
   - Any destructive operation
5. If `azure.md` has no Tenant ID configured, refuse Azure operations that require tenant context and ask the user to configure it.

---

## Implementation Discipline

- Do not begin coding until impact analysis is complete.
- Do not modify unrelated files.
- Do not expand scope beyond requested functionality.
- If a simpler, cleaner solution exists — propose it before implementing.
- Prefer the simplest viable approach.

If any checklist item fails, implementation is incomplete.