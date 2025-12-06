# configuration-aws-organization

`configuration-aws-organization` is a Crossplane configuration package that creates and manages AWS Organizations with default organizational unit structures based on AWS best practices. It publishes the `Organization` composite resource definition that standardizes how teams create and configure AWS Organizations.

## Features

- Creates AWS Organizations with all features enabled or consolidated billing only.
- Configures default organizational unit (OU) structures following AWS Control Tower patterns.
- Supports hierarchical OU creation with parent/child relationships.
- Enables organization-level policy types (SCPs, tag policies, backup policies, AI services opt-out policies).
- Manages delegated administrator accounts for AWS services (IPAM, Security Hub, GuardDuty, etc.).
- Automatically merges the `hops: "true"` tag with any caller-provided tags.
- Projects organization details and OU IDs into status for easy consumption by other XRDs.
- Ships with validation, testing, and publishing automation.
- Depends on `configuration-aws-account` so you can vend member accounts alongside the organization.

## Prerequisites

- An AWS management/root account for creating the organization.
- Crossplane installed in the target cluster.
- Crossplane providers:
  - `provider-aws-organizations` (≥ v2.0.0)
- Crossplane functions:
  - `function-auto-ready` (≥ v0.5.1)
- Access to GitHub Container Registry (GHCR) for pulling the package image.

## Installing the Package

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: configuration-aws-organization
spec:
  package: ghcr.io/hops-ops/configuration-aws-organization:latest
  packagePullSecrets:
    - name: ghcr
  skipDependencyResolution: true
```

## Example Composites

### Minimal Organization

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: Organization
metadata:
  name: hops-org
  namespace: platform
spec:
  managementPolicies:
    - "*"
  featureSet: ALL
```

### Standard Organization with AWS Best Practice OUs

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: Organization
metadata:
  name: acme-org
  namespace: customer-acme
spec:
  managementPolicies:
    - "*"
  featureSet: ALL
  organizationalUnits:
    - name: Security
      accounts:
        - name: security
          email: security@acme.com
    - name: Infrastructure
      accounts:
        - name: shared-services
          email: shared-services@acme.com
    - name: Workloads
      children:
        - name: Prod
          accounts:
            - name: project-x
              email: project-x@acme.com
        - name: Non-Prod
          accounts:
            - name: project-x-dev
              email: project-x-dev@acme.com
    - name: Sandbox
  tags:
    customer: acme
    hops: "true"
```

### Organization with Delegated Administrators

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: Organization
metadata:
  name: acme-org
  namespace: customer-acme
spec:
  managementPolicies:
    - "*"
  featureSet: ALL
  organizationalUnits:
    - name: Security
      accounts:
        - name: security
          email: security@acme.com
    - name: Infrastructure
      accounts:
        - name: shared-services
          email: shared-services@acme.com
    - name: Workloads
      children:
        - name: Prod
          accounts:
            - name: project-x
              email: project-x@acme.com
        - name: Non-Prod
          accounts:
            - name: project-x-dev
              email: project-x-dev@acme.com
    - name: Sandbox
  delegatedAdministrators:
    - servicePrincipal: ipam.amazonaws.com
      accountRef:
        name: acme-infrastructure
    - servicePrincipal: securityhub.amazonaws.com
      accountRef:
        name: acme-audit
  tags:
    customer: acme
    hops: "true"
```

Accounts can optionally be declared under each OU. They render once the OU is Ready, inherit Organization tags (with optional per-account overrides), and automatically use the OU ID as `parentId` when creating the `Account` composite.

## Organizational Unit Structure

The XRD supports AWS best practice OU structures:

- **Security**: Log archive, audit accounts, security tooling, break-glass access
- **Infrastructure**: Shared infrastructure services (IPAM, DNS, networking, Transit Gateway)
- **Workloads**: Application workloads with nested Prod and Non-Prod for different policy requirements
- **Sandbox**: Individual developer accounts with relaxed policies

OUs can be nested up to 5 levels deep, and the status field provides a map of OU paths to IDs for easy reference:

```yaml
status:
  organizationId: "o-abc123xyz"
  managementAccountId: "123456789012"
  rootId: "r-abc123"
  organizationalUnits:
    /Security: "ou-abc1-11111111"
    /Infrastructure: "ou-abc1-22222222"
    /Workloads: "ou-abc1-33333333"
    /Workloads/Prod: "ou-abc1-44444444"
    /Workloads/Non-Prod: "ou-abc1-55555555"
    /Sandbox: "ou-abc1-66666666"
  ready: true
```

## Local Development

- `make render` – render the minimal example composite.
- `make render-all` – render all example composites.
- `make validate` – run Crossplane schema validation against the XRD and examples.
- `make test` – execute `up test` regression tests.
- `make e2e` – run end-to-end tests against a real AWS account.
- `make publish tag=<version>` – build and push the configuration package.

Keep `.github/` and `.gitops/` workflows aligned when making automation changes.

## CI/CD Pipelines

Automated workflows handle quality assurance, testing, and publishing:

- **`on-pr.yaml`**: Pull request validation, testing, and preview package publishing
- **`on-push-main.yaml`**: Version bumping and tagging on main branch pushes
- **`on-version-tagged.yaml`**: Production releases with package publishing

### Quality Gates

Before release, the pipeline validates:
- XRD schema compliance
- Composition rendering
- Crossplane beta validation for examples
- Unit tests
- End-to-end tests against real AWS infrastructure

## Testing

The project includes comprehensive testing infrastructure:

### Crossplane Beta Validation

Validates XRD schemas and compositions against examples:

```bash
crossplane beta validate apis/organizations examples/organizations
```

### Composition Rendering Tests

Tests pipeline execution and resource generation:

```bash
up test run tests/test*
```

### End-to-End Tests

Tests against real AWS infrastructure:

```bash
# Create tests/e2etest-organization/aws-creds with your AWS credentials
make e2e
```

### Manual Testing

Render compositions to verify outputs:

```bash
make render       # Preview minimal example
make render-all   # Preview all examples
```

## Dependency Management

Automated dependency updates using [Renovate](https://docs.renovatebot.com/):

- **Crossplane providers and functions** in upbound.yaml
- **Helm charts** in Go template files
- Version constraints and requirements

## License

Apache-2.0 License. See [LICENSE](LICENSE) for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes:
   ```bash
   make validate
   make test
   ```
4. Submit a pull request

## Support

- **Issues**: [GitHub Issues](https://github.com/hops-ops/configuration-aws-organization/issues)
- **Discussions**: [GitHub Discussions](https://github.com/hops-ops/configuration-aws-organization/discussions)

## Maintainer

- **Patrick Lee Scott** <pat@patscott.io>

## Links

- **GitHub Repository**: [github.com/hops-ops/configuration-aws-organization](https://github.com/hops-ops/configuration-aws-organization)
- **Container Registry**: [ghcr.io/hops-ops/configuration-aws-organization](https://ghcr.io/hops-ops/configuration-aws-organization)
- **AWS Organizations Documentation**: [docs.aws.amazon.com/organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html)
