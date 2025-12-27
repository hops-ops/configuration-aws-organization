import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "test-organization-render-individual"
        spec= {
            assertResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "Organization"
                    metadata: {
                        name: "my-org"
                    }
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            kind: "ProviderConfig"
                            name: "default"
                        }
                        forProvider: {
                            awsServiceAccessPrincipals: []
                            enabledPolicyTypes: [
                                "SERVICE_CONTROL_POLICY",
                                "TAG_POLICY",
                                "BACKUP_POLICY",
                                "AISERVICES_OPT_OUT_POLICY"
                            ]
                            featureSet: "ALL"
                        }
                    }
                }
            ]
            compositionPath: "apis/organizations/composition.yaml"
            xrPath: "examples/organizations/individual.yaml"
            xrdPath: "apis/organizations/definition.yaml"
            timeoutSeconds: 120
            validate: True
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name: "test-organization-render-enterprise"
        spec= {
            compositionPath: "apis/organizations/composition.yaml"
            xrPath: "examples/organizations/enterprise.yaml"
            xrdPath: "apis/organizations/definition.yaml"
            timeoutSeconds: 120
            validate: True
            observedResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "Organization"
                    metadata: {
                        name: "acme"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "organization"
                            "crossplane.io/composition-resource-name": "organization"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {
                            id: "o-abc123"
                            masterAccountId: "111111111111"
                            roots: [{id: "r-root"}]
                        }
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-security"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-security"
                            "crossplane.io/composition-resource-name": "ou-security"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-security"}
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-infrastructure"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-infrastructure"
                            "crossplane.io/composition-resource-name": "ou-infrastructure"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-infra"}
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-workloads"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-workloads"
                            "crossplane.io/composition-resource-name": "ou-workloads"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-workloads"}
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-workloads-prod"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-workloads-prod"
                            "crossplane.io/composition-resource-name": "ou-workloads-prod"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-workloads-prod"}
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-workloads-non-prod"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-workloads-non-prod"
                            "crossplane.io/composition-resource-name": "ou-workloads-non-prod"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-workloads-nonprod"}
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-sandbox"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-sandbox"
                            "crossplane.io/composition-resource-name": "ou-sandbox"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-sandbox"}
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "DelegatedAdministrator"
                    metadata: {
                        name: "delegated-admin-0"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "delegated-admin-0"
                            "crossplane.io/composition-resource-name": "delegated-admin-0"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                    }
                }
            ]
            assertResources: [
                {
                    apiVersion: "aws.hops.ops.com.ai/v1alpha1"
                    kind: "Account"
                    metadata: {name: "acme-hops"}
                    spec: {
                        parentId: "ou-infra"
                        email: "hops@acme.com"
                        providerConfigName: "default"
                    }
                },
                {
                    apiVersion: "aws.hops.ops.com.ai/v1alpha1"
                    kind: "Account"
                    metadata: {name: "acme-prod"}
                    spec: {
                        parentId: "ou-workloads-prod"
                        email: "prod@acme.com"
                        providerConfigName: "default"
                    }
                },
                # Assert Usage resources are created
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {
                        name: "of-org-acme-by-ou-ou-security"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-security"}
                        }
                        of: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "Organization"
                            resourceRef: {name: "acme"}
                        }
                    }
                },
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {
                        name: "of-org-acme-by-ou-ou-infrastructure"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-infrastructure"}
                        }
                        of: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "Organization"
                            resourceRef: {name: "acme"}
                        }
                    }
                },
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {
                        name: "of-ou-ou-workloads-by-ou-ou-workloads-prod"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-workloads-prod"}
                        }
                        of: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-workloads"}
                        }
                    }
                },
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {
                        name: "of-ou-ou-workloads-by-ou-ou-workloads-non-prod"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-workloads-non-prod"}
                        }
                        of: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-workloads"}
                        }
                    }
                },
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {
                        name: "of-ou-ou-infrastructure-by-account-acme-hops"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "aws.hops.ops.com.ai/v1alpha1"
                            kind: "Account"
                            resourceRef: {name: "acme-hops"}
                        }
                        of: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-infrastructure"}
                        }
                    }
                },
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {
                        name: "of-ou-ou-workloads-prod-by-account-acme-prod"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "aws.hops.ops.com.ai/v1alpha1"
                            kind: "Account"
                            resourceRef: {name: "acme-prod"}
                        }
                        of: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-workloads-prod"}
                        }
                    }
                },
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {
                        name: "of-account-acme-hops-by-delegated-admin-0"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "DelegatedAdministrator"
                            resourceRef: {name: "delegated-admin-0"}
                        }
                        of: {
                            apiVersion: "aws.hops.ops.com.ai/v1alpha1"
                            kind: "Account"
                            resourceRef: {name: "acme-hops"}
                        }
                    }
                }
            ]
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name: "test-organization-render-enterprise-defaults"
        spec= {
            assertResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "Organization"
                    metadata: {
                        name: "acme"
                    }
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            kind: "ProviderConfig"
                            name: "default"
                        }
                        forProvider: {
                            featureSet: "ALL"
                        }
                    }
                }
            ]
            compositionPath: "apis/organizations/composition.yaml"
            xrPath: "examples/organizations/enterprise.yaml"
            xrdPath: "apis/organizations/definition.yaml"
            timeoutSeconds: 120
            validate: True
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name: "test-organization-render-enterprise-override"
        spec= {
            assertResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "Organization"
                    metadata: {
                        name: "acme-override"
                    }
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            kind: "ProviderConfig"
                            name: "default"
                        }
                        forProvider: {
                            featureSet: "CONSOLIDATED_BILLING"
                            enabledPolicyTypes: ["SERVICE_CONTROL_POLICY"]
                            awsServiceAccessPrincipals: ["sso.amazonaws.com"]
                        }
                    }
                }
            ]
            compositionPath: "apis/organizations/composition.yaml"
            xrPath: "examples/organizations/enterprise-override.yaml"
            xrdPath: "apis/organizations/definition.yaml"
            timeoutSeconds: 120
            validate: True
        }
    },
    # Test granular managementPolicies and external-name for OUs and accounts
    metav1alpha1.CompositionTest{
        metadata.name: "test-organization-e2e-infra-step-2"
        spec= {
            compositionPath: "apis/organizations/composition.yaml"
            xrPath: "examples/organizations/e2e-with-infrastructure.yaml"
            xrdPath: "apis/organizations/definition.yaml"
            timeoutSeconds: 120
            validate: True
            observedResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "Organization"
                    metadata: {
                        name: "hops-e2e-test"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "organization"
                            "crossplane.io/composition-resource-name": "organization"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {
                            id: "o-3lholziq1o"
                            masterAccountId: "111111111111"
                            roots: [{id: "r-root"}]
                        }
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-infrastructure"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-infrastructure"
                            "crossplane.io/composition-resource-name": "ou-infrastructure"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-abc123-infra"}
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-test"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-test"
                            "crossplane.io/composition-resource-name": "ou-test"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-test-123"}
                    }
                }
            ]
            assertResources: [
                # Test OU with external-name and orphan managementPolicies
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-infrastructure"
                        annotations: {
                            "crossplane.io/external-name": "ou-abc123-infra"
                        }
                    }
                    spec: {
                        managementPolicies: ["Create", "Observe", "Update", "LateInitialize"]
                        providerConfigRef: {
                            kind: "ProviderConfig"
                            name: "default"
                        }
                        forProvider: {
                            name: "Infrastructure"
                            parentId: "r-root"
                        }
                    }
                },
                # Test OU with default managementPolicies (no external-name)
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {name: "ou-test"}
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            kind: "ProviderConfig"
                            name: "default"
                        }
                        forProvider: {
                            name: "Test"
                            parentId: "r-root"
                        }
                    }
                },
                # Test Account with orphan managementPolicies (no externalName yet)
                {
                    apiVersion: "aws.hops.ops.com.ai/v1alpha1"
                    kind: "Account"
                    metadata: {name: "hops"}
                    spec: {
                        email: "hops@example.com"
                        parentId: "ou-abc123-infra"
                        managementPolicies: ["Create", "Observe", "Update", "LateInitialize"]
                    }
                }
            ]
        }
    },
    # Test nested OU with default policies and test account
    metav1alpha1.CompositionTest{
        metadata.name: "test-organization-e2e-infra-step-3"
        spec= {
            compositionPath: "apis/organizations/composition.yaml"
            xrPath: "examples/organizations/e2e-with-infrastructure.yaml"
            xrdPath: "apis/organizations/definition.yaml"
            timeoutSeconds: 120
            validate: True
            observedResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "Organization"
                    metadata: {
                        name: "hops-e2e-test"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "organization"
                            "crossplane.io/composition-resource-name": "organization"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {
                            id: "o-3lholziq1o"
                            masterAccountId: "111111111111"
                            roots: [{id: "r-root"}]
                        }
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-infrastructure"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-infrastructure"
                            "crossplane.io/composition-resource-name": "ou-infrastructure"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-abc123-infra"}
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-test"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-test"
                            "crossplane.io/composition-resource-name": "ou-test"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-test-123"}
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "ou-test-e2e"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-test-e2e"
                            "crossplane.io/composition-resource-name": "ou-test-e2e"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                        atProvider: {id: "ou-test-e2e-456"}
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "DelegatedAdministrator"
                    metadata: {
                        name: "delegated-admin-0"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "delegated-admin-0"
                            "crossplane.io/composition-resource-name": "delegated-admin-0"
                        }
                    }
                    status: {
                        conditions: [{type: "Ready", status: "True"}]
                    }
                }
            ]
            assertResources: [
                # Test nested OU (Test/E2E) with default policies
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {name: "ou-test-e2e"}
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            kind: "ProviderConfig"
                            name: "default"
                        }
                        forProvider: {
                            name: "E2E"
                            parentId: "ou-test-123"
                        }
                    }
                },
                # Test Account with default managementPolicies (no external-name)
                {
                    apiVersion: "aws.hops.ops.com.ai/v1alpha1"
                    kind: "Account"
                    metadata: {name: "test-account"}
                    spec: {
                        email: "test@example.com"
                        parentId: "ou-test-e2e-456"
                        managementPolicies: ["*"]
                    }
                },
                # Assert delegated admin usage resource protects the hops account
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {name: "of-account-hops-by-delegated-admin-0"}
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "DelegatedAdministrator"
                            resourceRef: {name: "delegated-admin-0"}
                        }
                        of: {
                            apiVersion: "aws.hops.ops.com.ai/v1alpha1"
                            kind: "Account"
                            resourceRef: {name: "hops"}
                        }
                    }
                }
            ]
        }
    }
]
items= _items
