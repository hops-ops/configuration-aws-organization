# Organization Config Agent Guide

This repository publishes the `Organization` configuration package. Use this guide when updating schemas, templates, or automation for AWS Organizations.

## Repository Layout

- `apis/`: CRDs, definitions, and composition for `Organization`. Treat these files as source of truth for the released package.
- `examples/`: Renderable composite examples that demonstrate both minimal and fully featured specs. Keep them in sync with the schema.
- `functions/render/`: Go-template pipeline. Files execute in lexical order (`00-`, `10-`, `20-`), so leave numeric gaps to simplify future inserts.
- `tests/test*`: KCL-based regression tests executed via `up test`.
- `tests/e2etest*`: KCL-based regression tests executed via `up test` with `--e2e` flag. Expects `aws-creds` file to exist (but gitignored).
- `.github/`: GitHub workflows
- `.gitops/`: GitOps automation usage.
- `_output/`, `.up/`: Generated artifacts. Remove with `make clean` when needed.

This package now depends on `configuration-aws-account` and can emit `Account` composites directly from OU definitions (rendered after the OU reports Ready).

Use `examples/observed-resources/step-*` to iterate rendering:
- Step 1: Organization observed as Ready with root ID (renders top-level OUs).
- Step 2: Organization + OUs observed as Ready (renders accounts under ready OUs).

## Rendering Guidelines

- Declare every reused value in `00-desired-values.yaml.gotmpl` with sensible defaults. Avoid direct field access in later templates.
- Use `02-observed-values.yaml.gotmpl` to read organization state and OU readiness from observed resources.
- Stick to simple string concatenation and inline values. This keeps templates legible and works well with Renovate.
- Resource templates must reference only previously declared variables. If you add new variables, hoist them into the appropriate values file.
- Default tags to `{"hops": "true"}` and merge caller-provided tags afterwards.
- Favor readability over micro-templating—duplicated strings for clarity are acceptable.

## Organizational Unit Creation

- OUs are created hierarchically. Root-level OUs reference the organization's root, nested OUs reference their parent OU.
- Use observed state to gate child OU creation—only emit child OUs when the parent is ready.
- The OU path-to-ID map is projected into status for easy consumption by other XRDs (like Account).
- OU paths follow the format `/ParentOU/ChildOU` (e.g., `/Workloads/Prod`).

## Testing

- Regression tests live in `tests/test-render/main.k` and cover:
  - Default OU structure creation.
  - Hierarchical OU relationships (parent before child).
  - Tag merging with default `hops` tag.
  - Status projection of organization ID, root ID, and OU map.
- Use `assertResources` to lock the behavior you care about. Provide only the fields under test so future changes remain flexible elsewhere.
- Run `make test` (or `up test run tests/test*`) after touching templates or examples.

## E2E Testing

- Tests live under `tests/e2etest-organization` and are invoked through `up test ... --e2e`, so the Upbound CLI must be authenticated and able to reach your control plane.
- Provide real AWS credentials via `tests/e2etest-organization/aws-creds` (gitignored). The file must contain a `[default]` profile understood by the AWS SDK, for example:

  ```ini
  [default]
  aws_access_key_id = <access key>
  aws_secret_access_key = <secret key>
  ```

- Run `make e2e` (or `up test run tests/e2etest-organization --e2e`) from the repo root to execute the suite. The harness uploads the manifest in `tests/e2etest-organization/main.k`, injects the `aws-creds` Secret, and provisions a `ProviderConfig` so the test Organization composition can reach AWS.
- The spec sets `skipDelete: false`, so resources are cleaned up automatically, but be aware that cleaning up an organization requires all member accounts to be closed first. The test should handle minimal organization structures without member accounts.
- Never commit the `aws-creds` file; it is ignored on purpose and should contain only disposable test credentials.

## Development Workflow

- `make render` – render the minimal example.
- `make render-all` – render all examples.
- `make validate` – run schema validation against the XRD and examples.
- `make test` – execute the regression suite.
- `make e2e` – execute e2e tests.

Document behavioral changes in `README.md` and refresh `examples/` whenever the schema shifts.

## Crossplane Configuration Best Practices

Avoid Upbound-hosted configuration packages whenever possible—they now carry paid-account restrictions that conflict with our fully open-source workflow. Favor the equivalent `crossplane-contrib` packages so our stacks stay reproducible without subscription gates.

## XRD Pattern Reference

### Template Structure

Author compositions with Go templates that promote every variable into the `default` blocks. Hoisting all inputs up front avoids surprising template fallbacks and forces you to handle each value explicitly during composition renders.

### Variable Organization

1. Separate desired and observed values:
   - `00-desired-values.yaml.gotmpl` - Extract spec values with defaults
   - `02-observed-values.yaml.gotmpl` - Read observed resource state

2. Configuration knobs follow a consistent schema:
   - Top-level keys scoped by integration (`aws`, etc.)
   - Each with `providerConfig` for the Crossplane ProviderConfig resource to use
   - Nested `config` object for integration-specific data
   - Optional features expose an `enabled` boolean

### Resource Naming

Name resources after the XR or another meaningful identifier—avoid tacking on redundant suffixes like `-role` or `-policy` when the kind already conveys that context.

### Status Projection

Project important details into status (`99-status.yaml.gotmpl`) so users can see:
- Organization ID
- Root ID
- OU path-to-ID mappings
- Readiness state

This information is critical for dependent XRDs like Account, IdentityCenter, and IPAM.
