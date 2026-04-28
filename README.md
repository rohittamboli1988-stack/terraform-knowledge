# Terraform Knowledge Repository

This repository contains Terraform best practices, L1 resource examples, and
L2 module examples used by the **Digital Worker** AI agent pipeline.

The planner agent reads `best-practices/` to guide plan generation.
The codegen agent reads `l1/` and `l2/` to generate correct Terraform files.

## Structure

```
best-practices/   Markdown guides for naming, tagging, and resource-specific rules
l1/               Minimal single-resource Terraform examples (raw resources)
l2/               Reusable modules that compose multiple L1 resources
```

## Usage

No authentication required — all content is read via public HTTPS.

```bash
# Configure the Digital Worker to use this repo:
export GIT_KNOWLEDGE_OWNER=<your-github-username>
export GIT_KNOWLEDGE_REPO=terraform-knowledge
export GIT_KNOWLEDGE_BRANCH=main
```
