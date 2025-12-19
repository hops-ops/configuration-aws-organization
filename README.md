# configuration-aws-organization

Manage your AWS Organization, Organizational Units, and Accounts as a single resource. Define your account hierarchy declaratively and let Crossplane handle the rest.

## Why AWS Organizations?

**Without Organizations:**
- Separate bills per account
- Manual IAM user management in each account
- No guardrails - anyone can do anything
- No central view of resources

**With Organizations:**
- Consolidated billing with cost allocation tags
- Centralized identity via Identity Center
- Service Control Policies (SCPs) for guardrails
- Account factory - spin up new accounts in minutes
- Delegated administration for security tools

## The Journey

### Stage 1: Adopt Your Existing Organization

Most teams already have an AWS Organization. Start by importing it.

**Why import instead of create?**
- AWS allows only one Organization per account
- Your existing OUs and accounts are preserved
- No disruption to running workloads

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: Organization
metadata:
  name: my-org
  namespace: default
spec:
  # Import existing org - get ID from: aws organizations describe-organization
  externalName: o-abc123xyz

  # Don't delete the org if this resource is deleted
  managementPolicies: ["Create", "Observe", "Update", "LateInitialize"]

  # Enable trusted access for services you use
  organization:
    awsServiceAccessPrincipals:
      - sso.amazonaws.com
```

### Stage 2: Define Your OU Structure

Organizational Units group accounts for policy application and billing.

**Recommended OU structure:**
- **Security** - Security tooling, audit logs, GuardDuty
- **Infrastructure** - Shared services, networking, CI/CD
- **Workloads** - Application accounts
  - **Workloads/Prod** - Production workloads
  - **Workloads/NonProd** - Dev, staging, sandbox

**Why this structure?**
- Security accounts are isolated from workloads
- Infrastructure is shared but separate from applications
- Prod/NonProd separation enables different SCPs

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: Organization
metadata:
  name: acme
  namespace: default
spec:
  externalName: o-abc123xyz
  managementPolicies: ["Create", "Observe", "Update", "LateInitialize"]

  organization:
    awsServiceAccessPrincipals:
      - sso.amazonaws.com
      - cloudtrail.amazonaws.com
      - config.amazonaws.com

  # Path-based OU definition - parent OUs created automatically
  organizationalUnits:
    - path: Security
    - path: Infrastructure
    - path: Workloads
    - path: Workloads/Prod
    - path: Workloads/NonProd
    - path: Workloads/Sandbox

  tags:
    organization: acme
    managed-by: crossplane
```

### Stage 3: Add Accounts to OUs

Accounts are defined inline within OUs. This keeps the hierarchy visible and ensures accounts are created in the right place.

**Why inline accounts?**
- Single source of truth for account placement
- Account creation waits for parent OU to be ready
- Easier to visualize the hierarchy

```yaml
organizationalUnits:
  - path: Security
    accounts:
      - name: acme-security
        email: aws-security@acme.example.com

  - path: Infrastructure
    accounts:
      - name: acme-shared-services
        email: aws-shared@acme.example.com

  - path: Workloads/Prod
    accounts:
      - name: acme-prod
        email: aws-prod@acme.example.com

  - path: Workloads/NonProd
    accounts:
      - name: acme-staging
        email: aws-staging@acme.example.com
      - name: acme-dev
        email: aws-dev@acme.example.com
```

### Stage 4: Import Existing Accounts

Already have accounts? Import them with `externalName`.

**Why import?**
- Preserves existing resources and configurations
- No downtime or migration needed
- Gradually bring accounts under Crossplane management

```yaml
organizationalUnits:
  - path: Security
    externalName: ou-abc1-security  # Import existing OU
    accounts:
      - name: acme-security
        email: aws-security@acme.example.com
        externalName: "111111111111"  # Import existing account
        managementPolicies: ["Create", "Observe", "Update", "LateInitialize"]

  - path: Workloads/Prod
    externalName: ou-abc1-prod
    accounts:
      - name: acme-prod
        email: aws-prod@acme.example.com
        externalName: "222222222222"
        managementPolicies: ["Create", "Observe", "Update", "LateInitialize"]
```

### Stage 5: Delegate Administration

Move service administration out of the management account.

**Why delegate?**
- Management account should only manage the Organization
- Reduces blast radius if credentials are compromised
- Teams can self-service within delegated scope
- Required for some services (IPAM, Security Hub)

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: Organization
metadata:
  name: acme
  namespace: default
spec:
  externalName: o-abc123xyz
  managementPolicies: ["Create", "Observe", "Update", "LateInitialize"]

  organization:
    awsServiceAccessPrincipals:
      - sso.amazonaws.com
      - ipam.amazonaws.com
      - guardduty.amazonaws.com
      - securityhub.amazonaws.com
      - ram.amazonaws.com

  organizationalUnits:
    - path: Security
      accounts:
        - name: acme-security
          email: aws-security@acme.example.com

    - path: Infrastructure
      accounts:
        - name: acme-shared-services
          email: aws-shared@acme.example.com

    - path: Workloads/Prod
    - path: Workloads/NonProd

  # Delegate services to appropriate accounts
  delegatedAdministrators:
    - servicePrincipal: sso.amazonaws.com
      accountRef:
        name: acme-shared-services

    - servicePrincipal: ipam.amazonaws.com
      accountRef:
        name: acme-shared-services

    - servicePrincipal: guardduty.amazonaws.com
      accountRef:
        name: acme-security

    - servicePrincipal: securityhub.amazonaws.com
      accountRef:
        name: acme-security

  tags:
    organization: acme
```

## Status

The Organization exposes IDs needed by other resources:

```yaml
status:
  ready: true
  organizationId: o-abc123xyz
  managementAccountId: "000000000000"
  rootId: r-abc1
  organizationalUnits:
    Security: ou-abc1-security
    Infrastructure: ou-abc1-infra
    Workloads/Prod: ou-abc1-prod
  accounts:
    - name: acme-security
      id: "111111111111"
      ready: true
      adminRoleArn: arn:aws:iam::111111111111:role/OrganizationAccountAccessRole
```

## Accessing Member Accounts

When accounts are created via Organizations, AWS creates `OrganizationAccountAccessRole` in each account. Create ProviderConfigs that assume this role:

```yaml
apiVersion: aws.m.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: acme-prod
spec:
  assumeRoleChain:
    - roleARN: arn:aws:iam::222222222222:role/OrganizationAccountAccessRole
  credentials:
    source: PodIdentity
```

## Development

```bash
make render               # Render default example
make test                 # Run tests
make validate             # Validate compositions
make e2e                  # E2E tests
```

## License

Apache-2.0
