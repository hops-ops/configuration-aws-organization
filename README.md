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


## Integration tests

If possible, we like the integration tests to cover the full lifecycle of a component - but AWS Organizations is a special beast.

You can only have once instance of it, and I'm not even entirely sure if you can undo it. Deleting Member Accounts created by the organization takes 90 days.

For that reason, these tests are special - they are connected to a test AWS account and some resources are not deleted.

These are
1. The organization
2. a testing "infrastructure" OU
3. a testing "hops" account in infrastructure OU

The first time the tests run, they create these resources, and I know it's hacky, but, after that, we update the source code with `external-names` so on subsequent runs the existing resources, that we skipped deleting, are imported instead of created.

This allows for multiple test runs to happen at the same time given the constraints.
