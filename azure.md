# Azure Environment Configuration

This file defines the Azure environment context for this repository.
All Azure-related operations (queries, IaC generation, architecture planning) MUST reference these values.

---

## Tenant

| Property | Value |
|---|---|
| Tenant ID | `<your-tenant-id>` |
| Tenant Name | `<your-tenant-name>` |

---

## Subscription (optional)

| Property | Value |
|---|---|
| Subscription ID | `<your-subscription-id>` |
| Subscription Name | `<your-subscription-name>` |

---

## Resource Group (optional)

| Property | Value |
|---|---|
| Resource Group | `<your-resource-group>` |
| Region | `<your-region>` |

---

## Usage Rules

- Copilot and agents MUST read this file before any Azure-related operation.
- If Tenant ID is not set, Azure operations that require tenant context MUST be refused.
- Subscription and Resource Group are optional — when not set, agents must ask the user before proceeding.
- This file is for **read-only context only** — it does not authorize agents to create, modify, or delete Azure resources.
