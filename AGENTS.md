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

## Rendering & Validating Compositions

### Local Rendering with `up composition render`

Use `up composition render` to see what resources your composition will create without deploying to a cluster. This is essential for debugging templates and understanding the multi-step reconciliation flow.

**Basic rendering:**
```bash
make render-enterprise
# or directly:
up composition render --xrd=apis/organizations/definition.yaml \
  apis/organizations/composition.yaml \
  examples/organizations/enterprise.yaml
```

### Simulating Reconciliation Steps with Observed Resources

Crossplane compositions often create resources in stages—the render function is called repeatedly with both the desired state (your XR) and the observed state (status from previously created resources) until everything is Ready. To test this locally:

**Structure:**
```
examples/observed-resources/
└── enterprise/                # Named after the example XR
    └── steps/
        ├── 1/                 # First reconciliation loop
        │   └── organization.yaml
        └── 2/                 # Second reconciliation loop
            └── organization-and-ous.yaml
```

Each step directory contains YAML manifests with realistic `status.conditions` and `status.atProvider` data that mimic what Crossplane would observe from AWS:

**Step 1 (Organization ready):**
```yaml
apiVersion: organizations.aws.m.upbound.io/v1beta1
kind: Organization
metadata:
  name: acme
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: "organization"
    crossplane.io/composition-resource-name: "organization"
status:
  conditions:
    - type: Ready
      status: "True"
  atProvider:
    id: o-abc123
    masterAccountId: "111111111111"
    roots:
      - id: r-root
```

**Step 2 (Organization + OUs ready):**
Add the Organization from step 1 plus:
```yaml
apiVersion: organizations.aws.m.upbound.io/v1beta1
kind: OrganizationalUnit
metadata:
  name: ou-Infrastructure
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: "ou-Infrastructure"
    crossplane.io/composition-resource-name: "ou-Infrastructure"
status:
  conditions:
    - type: Ready
      status: "True"
  atProvider:
    id: ou-infra123
```

**Render with observed resources:**
```bash
make render-enterprise-step-1
make render-enterprise-step-2
# or directly:
up composition render --xrd=apis/organizations/definition.yaml \
  apis/organizations/composition.yaml \
  examples/organizations/enterprise.yaml \
  --observed-resources=examples/observed-resources/enterprise/steps/1/
```

**Key requirements for observed resource manifests:**
- Include both `gotemplating.fn.crossplane.io/composition-resource-name` and `crossplane.io/composition-resource-name` annotations
- Match the resource names used by `{{ setResourceNameAnnotation "..." }}` in templates
- Provide realistic `status.conditions` with Ready state
- Include `status.atProvider` fields that templates read (IDs, ARNs, etc.)

### Validating Rendered Resources

After rendering, validate the output against Crossplane schemas:

```bash
make validate
# or for specific steps:
make validate-composition-enterprise-step-1
make validate-composition-enterprise-step-2
```

This pipes rendered output through `crossplane beta validate` to catch schema errors before deployment.

### GitHub Actions Integration

Use the `unbounded-tech/workflows-crossplane` reusable workflow to validate compositions with observed resources in CI. The workflow is configured in `.github/workflows/on-pr.yaml`:

```yaml
jobs:
  validate:
    uses: unbounded-tech/workflows-crossplane/.github/workflows/validate.yaml@v0.10.0
    with:
      examples: |
        [
          { "example": "examples/organizations/individual.yaml" },
          { "example": "examples/organizations/enterprise.yaml" },
          { "example": "examples/organizations/enterprise.yaml", "observed_resources": "examples/observed-resources/enterprise/steps/1" },
          { "example": "examples/organizations/enterprise.yaml", "observed_resources": "examples/observed-resources/enterprise/steps/2" }
        ]
      api_path: apis/organizations
      error_on_missing_schemas: true
```

**Key points:**
- Each example can be validated with or without observed resources
- Multiple reconciliation steps can be validated by repeating the example with different `observed_resources` paths
- The workflow renders each configuration and validates against Crossplane schemas
- CI fails if any validation errors occur, catching issues before merge

## Rendering Guidelines

- Declare every reused value in `00-desired-values.yaml.gotmpl` with sensible defaults. Avoid direct field access in later templates.
- Use `02-observed-values.yaml.gotmpl` to read organization state and OU readiness from observed resources.
- Stick to simple string concatenation and inline values. This keeps templates legible and works well with Renovate.
- Resource templates must reference only previously declared variables. If you add new variables, hoist them into the appropriate values file.
- Default tags to `{"hops": "true"}` and merge caller-provided tags afterwards.
- Favor readability over micro-templating—duplicated strings for clarity are acceptable.

### YAML Override Pattern

Use inline defaults that get overridden by user values via YAML's last-wins behavior. This is simpler and more readable than creating default dicts and merging them.

**Example from `10-organization.yaml.gotmpl`:**
```yaml
spec:
  managementPolicies: {{ toJson $managementPolicies }}
  forProvider:
    featureSet: ALL
    enabledPolicyTypes:
      - SERVICE_CONTROL_POLICY
      - TAG_POLICY
      - BACKUP_POLICY
      - AISERVICES_OPT_OUT_POLICY
    awsServiceAccessPrincipals: []
    {{ with $organization }}
    {{ toYaml . | nindent 4 }}
    {{ end }}
  providerConfigRef:
    kind: ProviderConfig
    name: {{ $awsProviderConfig }}
```

**How it works:**
1. Define defaults inline first (`featureSet: ALL`, etc.)
2. User values from `$organization` are rendered after defaults
3. YAML's last-wins rule means user values override defaults
4. No need for dict creation, merging, or complex logic

**Benefits:**
- More readable - defaults are visible in the template
- Simpler - no dict manipulation needed
- Same behavior - overrides work naturally via YAML semantics
- Easier to maintain - change defaults directly in the template

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

### Organization-Specific E2E Considerations

- **One organization per AWS account**: AWS enforces a hard limit of one organization per account. The E2E test uses orphan management policies (`["Create", "Observe", "Update", "LateInitialize"]`) to leave the org in place between test runs.
- **Fixed resource name**: The test uses a fixed name (`e2etest-org`) rather than timestamped names. This allows Crossplane to adopt the existing organization on subsequent runs.
- **Adoption behavior**: On first run, the test creates a new organization. On subsequent runs, Crossplane should adopt the existing organization. If adoption fails, you may need to manually set the `crossplane.io/external-name` annotation.
- **Cleanup**: The test sets `skipDelete: false` to clean up Crossplane resources, but the actual AWS organization persists due to orphan management policies. To fully clean up, manually delete the organization through the AWS console or CLI.
- Never commit the `aws-creds` file; it is ignored on purpose and should contain only disposable test credentials.

## Development Workflow

- `make render` – render the enterprise example.
- `make render-all` – render all examples.
- `make validate` – run schema validation against the XRD and examples.
- `make test` – execute the regression suite.
- `make e2e` – execute e2e tests.

Document behavioral changes in `README.md` and refresh `examples/` whenever the schema shifts.

## Naming Conventions

Examples in the `examples/organizations/` directory do not use the "example-" prefix since the directory context already indicates they are examples. Use descriptive names that indicate the use case:
- `individual.yaml` - for solo founders and small teams
- `enterprise.yaml` - for production operations with multiple accounts

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
