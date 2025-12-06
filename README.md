# configuration-aws-organization

Create and manage an AWS Organization with optional inline account vending. Ships the `Organization` XRD plus compositions that emit:
- AWS Organizations `Organization` (always)
- Hierarchical `OrganizationalUnit`s
- Optional `DelegatedAdministrator` registrations
- Inline `Account` composites (from `configuration-aws-account`) under each OU

Defaults keep things small and readable: `featureSet: ALL`, enabled policy types, and tags merged with `hops: "true"`.

## Prerequisites
- Crossplane installed with:
  - `provider-aws-organizations` (>= v2.0.0)
  - `function-auto-ready` (>= v0.5.1)
  - `configuration-aws-account` (>= v0.3.0)
- ProviderConfig pointing at the management account (default name `default`).

## Spec
```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: Organization
metadata:
  name: acme
  namespace: acme
spec:
  managementPolicies: ["*"]          # optional, default ["*"]
  featureSet: ALL                    # ALL | CONSOLIDATED_BILLING
  enabledPolicyTypes:                # optional, defaults shown
    - SERVICE_CONTROL_POLICY
    - TAG_POLICY
    - BACKUP_POLICY
    - AISERVICES_OPT_OUT_POLICY
  organizationalUnits:
    - name: Infrastructure
      accounts:                      # optional inline accounts (become Account XRs)
        - name: acme-hops
          email: hops@acme.com
    - name: Workloads
      children:
        - name: Prod
          accounts:
            - name: acme-prod
              email: prod@acme.com
  delegatedAdministrators:           # optional
    - servicePrincipal: ipam.amazonaws.com
      accountRef:
        name: acme-hops
  tags:
    organization: acme
    hops: "true"
```

### Inline accounts
- Each `accounts` entry renders an `aws.hops.ops.com.ai/v1alpha1, Kind=Account` once its parent OU is Ready.
- Account tags merge org tags with any per-account tags.
- `providerConfigName` on an account defaults to the org’s AWS providerConfig; override per account if needed.

### Status (projection)
Status surfaces IDs for downstream XRDs:
```yaml
status:
  organizationId: o-abc123
  rootId: r-root
  organizationalUnits:
    /Infrastructure: ou-infra
    /Workloads: ou-workloads
    /Workloads/Prod: ou-workloads-prod
  ready: true
```

## Examples
- `examples/organizations/example-minimal.yaml` – smallest possible Org.
- `examples/organizations/example-standard.yaml` – OUs, inline accounts, delegated admin.
- `examples/observed-resources/step-1` – Org ready with root ID (renders OUs).
- `examples/observed-resources/step-2` – Org + OUs ready (renders accounts and delegated admins).

## Local workflow
```bash
# Render
make render-example-standard
make render-example-standard-step-1   # with observed org
make render-example-standard-step-2   # with observed org+ous

# Validate (schema)
make validate                         # runs minimal + both step renders

# Tests (KCL render assertions)
make test
```

## Notes
- Provider refs include `kind: ProviderConfig` to satisfy provider schemas.
- Accounts rely on `configuration-aws-account`; keep versions in `upbound.yaml` and `apis/organizations/configuration.yaml` aligned.
- Organization resource naming stays simple for Renovate-friendly chart/provider tracking (no templated chart sources).
