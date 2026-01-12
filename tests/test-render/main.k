import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# =============================================================================
# Default Values Tests
# =============================================================================

# Test: providerConfigRef defaults to name=default, kind=ProviderConfig
_test_defaults_provider_config = metav1alpha1.CompositionTest {
    metadata.name = "defaults-provider-config"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {}  # No providerConfigRef specified
        }
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata.name = "test-org"
                spec.providerConfigRef = {
                    name = "default"
                    kind = "ProviderConfig"
                }
            }
        ]
    }
}

# Test: managementPolicies defaults to ["*"]
_test_defaults_management_policies = metav1alpha1.CompositionTest {
    metadata.name = "defaults-management-policies"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {}  # No managementPolicies specified
        }
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata.name = "test-org"
                spec.managementPolicies = ["*"]
            }
        ]
    }
}

# Test: organization defaults (featureSet=ALL, all 4 policy types)
_test_defaults_organization_settings = metav1alpha1.CompositionTest {
    metadata.name = "defaults-organization-settings"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {}  # No organization settings specified
        }
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata.name = "test-org"
                spec.forProvider = {
                    featureSet = "ALL"
                    enabledPolicyTypes = [
                        "SERVICE_CONTROL_POLICY"
                        "TAG_POLICY"
                        "BACKUP_POLICY"
                        "AISERVICES_OPT_OUT_POLICY"
                    ]
                    awsServiceAccessPrincipals = []
                }
            }
        ]
    }
}

# =============================================================================
# Custom Provider Config Tests
# =============================================================================

# Test: custom providerConfigRef is used
_test_custom_provider_config = metav1alpha1.CompositionTest {
    metadata.name = "custom-provider-config"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                providerConfigRef = {
                    name = "my-custom-provider"
                    kind = "ClusterProviderConfig"
                }
            }
        }
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata.name = "test-org"
                spec.providerConfigRef = {
                    name = "my-custom-provider"
                    kind = "ClusterProviderConfig"
                }
            }
        ]
    }
}

# =============================================================================
# Organization Settings Override Tests
# =============================================================================

# Test: organization.featureSet override works
_test_organization_feature_set_override = metav1alpha1.CompositionTest {
    metadata.name = "organization-feature-set-override"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organization = {
                    featureSet = "CONSOLIDATED_BILLING"
                }
            }
        }
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata.name = "test-org"
                spec.forProvider.featureSet = "CONSOLIDATED_BILLING"
            }
        ]
    }
}

# Test: organization.enabledPolicyTypes override works
_test_organization_policy_types_override = metav1alpha1.CompositionTest {
    metadata.name = "organization-policy-types-override"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organization = {
                    enabledPolicyTypes = ["SERVICE_CONTROL_POLICY"]
                }
            }
        }
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata.name = "test-org"
                spec.forProvider.enabledPolicyTypes = ["SERVICE_CONTROL_POLICY"]
            }
        ]
    }
}

# Test: organization.awsServiceAccessPrincipals override works
_test_organization_service_principals_override = metav1alpha1.CompositionTest {
    metadata.name = "organization-service-principals-override"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organization = {
                    awsServiceAccessPrincipals = ["sso.amazonaws.com", "ram.amazonaws.com"]
                }
            }
        }
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata.name = "test-org"
                spec.forProvider.awsServiceAccessPrincipals = ["sso.amazonaws.com", "ram.amazonaws.com"]
            }
        ]
    }
}

# =============================================================================
# External Name / Import Tests
# =============================================================================

# Test: externalName annotation set on Organization when importing
_test_external_name_on_organization = metav1alpha1.CompositionTest {
    metadata.name = "external-name-on-organization"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "imported-org"
            spec = {
                externalName = "o-abc123xyz"
            }
        }
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "imported-org"
                    annotations = {
                        "crossplane.io/external-name" = "o-abc123xyz"
                    }
                }
            }
        ]
    }
}

# Test: organization.managementPolicies can orphan org on deletion
_test_organization_level_management_policies = metav1alpha1.CompositionTest {
    metadata.name = "organization-level-management-policies"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organization = {
                    managementPolicies = ["Create", "Observe", "Update", "LateInitialize"]
                }
            }
        }
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata.name = "test-org"
                spec.managementPolicies = ["Create", "Observe", "Update", "LateInitialize"]
            }
        ]
    }
}

# =============================================================================
# Conditional Rendering Tests - OUs gate on Organization ready
# =============================================================================

# Test: OUs do NOT render when Organization is not ready
_test_ous_not_rendered_when_org_not_ready = metav1alpha1.CompositionTest {
    metadata.name = "ous-not-rendered-when-org-not-ready"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organizationalUnits = [
                    {path = "Security"}
                    {path = "Infrastructure"}
                ]
            }
        }
        # No observedResources - org is not ready
        # Only Organization should render, no OUs
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata.name = "test-org"
            }
        ]
        # Explicitly verify no OUs rendered (assertResources is exhaustive for specified kinds)
    }
}

# Test: OUs render when Organization is ready
_test_ous_render_when_org_ready = metav1alpha1.CompositionTest {
    metadata.name = "ous-render-when-org-ready"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organizationalUnits = [
                    {path = "Security"}
                    {path = "Infrastructure"}
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata.name = "ou-security"
                spec.forProvider = {
                    name = "Security"
                    parentId = "r-root"
                }
            }
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata.name = "ou-infrastructure"
                spec.forProvider = {
                    name = "Infrastructure"
                    parentId = "r-root"
                }
            }
        ]
    }
}

# =============================================================================
# Nested OU Tests - child OUs gate on parent OU ready
# =============================================================================

# Test: nested OUs don't render until parent OU is ready
_test_nested_ou_gates_on_parent = metav1alpha1.CompositionTest {
    metadata.name = "nested-ou-gates-on-parent"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organizationalUnits = [
                    {path = "Workloads"}
                    {path = "Workloads/Prod"}
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
            # Parent OU (Workloads) is NOT ready yet
        ]
        # Only parent OU should render, child should not
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata.name = "ou-workloads"
                spec.forProvider = {
                    name = "Workloads"
                    parentId = "r-root"
                }
            }
        ]
    }
}

# Test: nested OU renders when parent OU is ready
_test_nested_ou_renders_when_parent_ready = metav1alpha1.CompositionTest {
    metadata.name = "nested-ou-renders-when-parent-ready"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organizationalUnits = [
                    {path = "Workloads"}
                    {path = "Workloads/Prod"}
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata = {
                    name = "ou-workloads"
                    annotations = {"crossplane.io/composition-resource-name" = "ou-workloads"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {id = "ou-workloads-abc"}
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata.name = "ou-workloads-prod"
                spec.forProvider = {
                    name = "Prod"
                    parentId = "ou-workloads-abc"  # Uses parent's observed ID
                }
            }
        ]
    }
}

# =============================================================================
# OU ManagementPolicies Override Tests
# =============================================================================

# Test: OU-level managementPolicies override spec.managementPolicies
_test_ou_management_policies_override = metav1alpha1.CompositionTest {
    metadata.name = "ou-management-policies-override"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                managementPolicies = ["*"]
                organizationalUnits = [
                    {
                        path = "Infrastructure"
                        managementPolicies = ["Create", "Observe", "Update", "LateInitialize"]
                    }
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata.name = "ou-infrastructure"
                spec.managementPolicies = ["Create", "Observe", "Update", "LateInitialize"]
            }
        ]
    }
}

# Test: OU externalName annotation set when importing
_test_ou_external_name = metav1alpha1.CompositionTest {
    metadata.name = "ou-external-name"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organizationalUnits = [
                    {path = "Infrastructure", externalName = "ou-abc123-infra"}
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata = {
                    name = "ou-infrastructure"
                    annotations = {
                        "crossplane.io/external-name" = "ou-abc123-infra"
                    }
                }
            }
        ]
    }
}

# =============================================================================
# Account Tests
# =============================================================================

# Test: Accounts render with correct parentId from observed OU
_test_account_with_parent_id = metav1alpha1.CompositionTest {
    metadata.name = "account-with-parent-id"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organizationalUnits = [
                    {
                        path = "Infrastructure"
                        accounts = [
                            {name = "hops-account", email = "hops@example.com"}
                        ]
                    }
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata = {
                    name = "ou-infrastructure"
                    annotations = {"crossplane.io/composition-resource-name" = "ou-infrastructure"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {id = "ou-infra-abc123"}
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "Account"
                metadata.name = "hops-account"
                spec = {
                    email = "hops@example.com"
                    parentId = "ou-infra-abc123"
                    providerConfigRef = {
                        name = "default"
                        kind = "ProviderConfig"
                    }
                }
            }
        ]
    }
}

# Test: Account inherits managementPolicies from spec
_test_account_inherits_management_policies = metav1alpha1.CompositionTest {
    metadata.name = "account-inherits-management-policies"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                managementPolicies = ["Create", "Observe", "Update", "LateInitialize"]
                organizationalUnits = [
                    {
                        path = "Infrastructure"
                        accounts = [
                            {name = "hops-account", email = "hops@example.com"}
                        ]
                    }
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata = {
                    name = "ou-infrastructure"
                    annotations = {"crossplane.io/composition-resource-name" = "ou-infrastructure"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {id = "ou-infra-abc123"}
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "Account"
                metadata.name = "hops-account"
                spec.managementPolicies = ["Create", "Observe", "Update", "LateInitialize"]
            }
        ]
    }
}

# Test: Account-level managementPolicies override
_test_account_management_policies_override = metav1alpha1.CompositionTest {
    metadata.name = "account-management-policies-override"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                managementPolicies = ["*"]
                organizationalUnits = [
                    {
                        path = "Infrastructure"
                        accounts = [
                            {
                                name = "imported-account"
                                email = "imported@example.com"
                                managementPolicies = ["Create", "Observe", "Update", "LateInitialize"]
                            }
                        ]
                    }
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata = {
                    name = "ou-infrastructure"
                    annotations = {"crossplane.io/composition-resource-name" = "ou-infrastructure"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {id = "ou-infra-abc123"}
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "Account"
                metadata.name = "imported-account"
                spec.managementPolicies = ["Create", "Observe", "Update", "LateInitialize"]
            }
        ]
    }
}

# =============================================================================
# Tag Merging Tests
# =============================================================================

# Test: Default hops=true tag is added
_test_default_hops_tag = metav1alpha1.CompositionTest {
    metadata.name = "default-hops-tag"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organizationalUnits = [{path = "Security"}]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata.name = "ou-security"
                spec.forProvider.tags = {
                    "hops.ops.com.ai/managed" = "true"
                    "hops.ops.com.ai/organization" = "test-org"
                }
            }
        ]
    }
}

# Test: User tags merge with default managed/organization tags
_test_user_tags_merge_with_defaults = metav1alpha1.CompositionTest {
    metadata.name = "user-tags-merge-with-defaults"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                tags = {
                    environment = "production"
                    team = "platform"
                }
                organizationalUnits = [{path = "Security"}]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata.name = "ou-security"
                spec.forProvider.tags = {
                    "hops.ops.com.ai/managed" = "true"
                    "hops.ops.com.ai/organization" = "test-org"
                    environment = "production"
                    team = "platform"
                }
            }
        ]
    }
}

# =============================================================================
# Usage Resource Tests
# =============================================================================

# Test: Usage resource protects Organization from OU deletion
_test_usage_protects_org_from_ou = metav1alpha1.CompositionTest {
    metadata.name = "usage-protects-org-from-ou"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organizationalUnits = [{path = "Security"}]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata = {
                    name = "ou-security"
                    annotations = {"crossplane.io/composition-resource-name" = "ou-security"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {id = "ou-security-123"}
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "protection.crossplane.io/v1beta1"
                kind = "Usage"
                metadata.name = "of-org-test-org-by-ou-ou-security"
                spec = {
                    replayDeletion = True
                    by = {
                        apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                        kind = "OrganizationalUnit"
                        resourceRef.name = "ou-security"
                    }
                    of = {
                        apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                        kind = "Organization"
                        resourceRef.name = "test-org"
                    }
                }
            }
        ]
    }
}

# Test: Usage resource protects parent OU from child OU deletion
_test_usage_protects_parent_ou_from_child = metav1alpha1.CompositionTest {
    metadata.name = "usage-protects-parent-ou-from-child"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organizationalUnits = [
                    {path = "Workloads"}
                    {path = "Workloads/Prod"}
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata = {
                    name = "ou-workloads"
                    annotations = {"crossplane.io/composition-resource-name" = "ou-workloads"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {id = "ou-workloads-abc"}
                }
            }
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata = {
                    name = "ou-workloads-prod"
                    annotations = {"crossplane.io/composition-resource-name" = "ou-workloads-prod"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {id = "ou-workloads-prod-xyz"}
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "protection.crossplane.io/v1beta1"
                kind = "Usage"
                metadata.name = "of-ou-ou-workloads-by-ou-ou-workloads-prod"
                spec = {
                    replayDeletion = True
                    by = {
                        apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                        kind = "OrganizationalUnit"
                        resourceRef.name = "ou-workloads-prod"
                    }
                    of = {
                        apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                        kind = "OrganizationalUnit"
                        resourceRef.name = "ou-workloads"
                    }
                }
            }
        ]
    }
}

# Test: Usage resource protects OU from Account deletion
_test_usage_protects_ou_from_account = metav1alpha1.CompositionTest {
    metadata.name = "usage-protects-ou-from-account"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                organizationalUnits = [
                    {
                        path = "Infrastructure"
                        accounts = [{name = "hops-account", email = "hops@example.com"}]
                    }
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "OrganizationalUnit"
                metadata = {
                    name = "ou-infrastructure"
                    annotations = {"crossplane.io/composition-resource-name" = "ou-infrastructure"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {id = "ou-infra-123"}
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "protection.crossplane.io/v1beta1"
                kind = "Usage"
                metadata.name = "of-ou-ou-infrastructure-by-account-hops-account"
                spec = {
                    replayDeletion = True
                    by = {
                        apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                        kind = "Account"
                        resourceRef.name = "hops-account"
                    }
                    of = {
                        apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                        kind = "OrganizationalUnit"
                        resourceRef.name = "ou-infrastructure"
                    }
                }
            }
        ]
    }
}

# =============================================================================
# Delegated Administrator Tests
# =============================================================================

# Test: DelegatedAdministrator renders when org is ready
_test_delegated_admin_renders = metav1alpha1.CompositionTest {
    metadata.name = "delegated-admin-renders"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                delegatedAdministrators = [
                    {
                        servicePrincipal = "ipam.amazonaws.com"
                        accountRef.name = "hops-account"
                    }
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "DelegatedAdministrator"
                metadata.name = "delegated-admin-0"
                spec = {
                    forProvider = {
                        servicePrincipal = "ipam.amazonaws.com"
                        accountIdSelector.matchLabels = {
                            "crossplane.io/claim-name" = "hops-account"
                        }
                    }
                    providerConfigRef = {
                        name = "default"
                        kind = "ProviderConfig"
                    }
                }
            }
        ]
    }
}

# Test: DelegatedAdministrator doesn't render when org is not ready
_test_delegated_admin_gates_on_org = metav1alpha1.CompositionTest {
    metadata.name = "delegated-admin-gates-on-org"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                delegatedAdministrators = [
                    {
                        servicePrincipal = "ipam.amazonaws.com"
                        accountRef.name = "hops-account"
                    }
                ]
            }
        }
        # No observed resources - org is not ready
        assertResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata.name = "test-org"
            }
        ]
        # DelegatedAdministrator should NOT be rendered
    }
}

# Test: Usage protects Account from DelegatedAdministrator deletion
_test_usage_protects_account_from_delegated_admin = metav1alpha1.CompositionTest {
    metadata.name = "usage-protects-account-from-delegated-admin"
    spec = {
        compositionPath = "apis/organizations/composition.yaml"
        xrdPath = "apis/organizations/definition.yaml"
        timeoutSeconds = 120
        validate = True
        xr = {
            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
            kind = "Organization"
            metadata.name = "test-org"
            spec = {
                delegatedAdministrators = [
                    {
                        servicePrincipal = "ipam.amazonaws.com"
                        accountRef.name = "hops-account"
                    }
                ]
            }
        }
        observedResources = [
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "Organization"
                metadata = {
                    name = "test-org"
                    annotations = {"crossplane.io/composition-resource-name" = "organization"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                    atProvider = {
                        id = "o-test123"
                        masterAccountId = "111111111111"
                        roots = [{id = "r-root"}]
                    }
                }
            }
            {
                apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                kind = "DelegatedAdministrator"
                metadata = {
                    name = "delegated-admin-0"
                    annotations = {"crossplane.io/composition-resource-name" = "delegated-admin-0"}
                }
                status = {
                    conditions = [{type = "Ready", status = "True"}]
                }
            }
        ]
        assertResources = [
            {
                apiVersion = "protection.crossplane.io/v1beta1"
                kind = "Usage"
                metadata.name = "of-account-hops-account-by-delegated-admin-0"
                spec = {
                    replayDeletion = True
                    by = {
                        apiVersion = "organizations.aws.m.upbound.io/v1beta1"
                        kind = "DelegatedAdministrator"
                        resourceRef.name = "delegated-admin-0"
                    }
                    of = {
                        apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                        kind = "Account"
                        resourceRef.name = "hops-account"
                    }
                }
            }
        ]
    }
}

# Combine all tests
# Note: XR status is validated through make validate, not assertResources
# (assertResources only matches composed resources, not XR status patches)
items = [
    # Defaults tests
    _test_defaults_provider_config
    _test_defaults_management_policies
    _test_defaults_organization_settings

    # Custom provider config
    _test_custom_provider_config

    # Organization settings override
    _test_organization_feature_set_override
    _test_organization_policy_types_override
    _test_organization_service_principals_override

    # External name / import
    _test_external_name_on_organization
    _test_organization_level_management_policies

    # Conditional rendering - OUs gate on org
    _test_ous_not_rendered_when_org_not_ready
    _test_ous_render_when_org_ready

    # Nested OUs gate on parent
    _test_nested_ou_gates_on_parent
    _test_nested_ou_renders_when_parent_ready

    # OU management policies
    _test_ou_management_policies_override
    _test_ou_external_name

    # Account tests
    _test_account_with_parent_id
    _test_account_inherits_management_policies
    _test_account_management_policies_override

    # Tag merging
    _test_default_hops_tag
    _test_user_tags_merge_with_defaults

    # Usage resources
    _test_usage_protects_org_from_ou
    _test_usage_protects_parent_ou_from_child
    _test_usage_protects_ou_from_account

    # Delegated administrators
    _test_delegated_admin_renders
    _test_delegated_admin_gates_on_org
    _test_usage_protects_account_from_delegated_admin
]
