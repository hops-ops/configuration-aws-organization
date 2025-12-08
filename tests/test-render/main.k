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
                        name: "ou-Security"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-Security"
                            "crossplane.io/composition-resource-name": "ou-Security"
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
                        name: "ou-Infrastructure"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-Infrastructure"
                            "crossplane.io/composition-resource-name": "ou-Infrastructure"
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
                        name: "ou-Workloads"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-Workloads"
                            "crossplane.io/composition-resource-name": "ou-Workloads"
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
                        name: "ou-Workloads-Prod"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-Workloads-Prod"
                            "crossplane.io/composition-resource-name": "ou-Workloads-Prod"
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
                        name: "ou-Workloads-Non-Prod"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-Workloads-Non-Prod"
                            "crossplane.io/composition-resource-name": "ou-Workloads-Non-Prod"
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
                        name: "ou-Sandbox"
                        annotations: {
                            "gotemplating.fn.crossplane.io/composition-resource-name": "ou-Sandbox"
                            "crossplane.io/composition-resource-name": "ou-Sandbox"
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
                        name: "of-org-acme-by-ou-ou-Security"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-Security"}
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
                        name: "of-org-acme-by-ou-ou-Infrastructure"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-Infrastructure"}
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
                        name: "of-ou-ou-Workloads-by-ou-ou-Workloads-Prod"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-Workloads-Prod"}
                        }
                        of: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-Workloads"}
                        }
                    }
                },
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {
                        name: "of-ou-ou-Workloads-by-ou-ou-Workloads-Non-Prod"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-Workloads-Non-Prod"}
                        }
                        of: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-Workloads"}
                        }
                    }
                },
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {
                        name: "of-ou-ou-Infrastructure-by-account-acme-hops"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "aws.hops.ops.com.ai/v1alpha1"
                            kind: "Account"
                            resourceSelector: {
                                matchLabels: {
                                    "crossplane.io/claim-name": "acme-hops"
                                    "crossplane.io/claim-namespace": "acme"
                                }
                            }
                        }
                        of: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-Infrastructure"}
                        }
                    }
                },
                {
                    apiVersion: "protection.crossplane.io/v1beta1"
                    kind: "Usage"
                    metadata: {
                        name: "of-ou-ou-Workloads-Prod-by-account-acme-prod"
                    }
                    spec: {
                        replayDeletion: True
                        by: {
                            apiVersion: "aws.hops.ops.com.ai/v1alpha1"
                            kind: "Account"
                            resourceSelector: {
                                matchLabels: {
                                    "crossplane.io/claim-name": "acme-prod"
                                    "crossplane.io/claim-namespace": "acme"
                                }
                            }
                        }
                        of: {
                            apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                            kind: "OrganizationalUnit"
                            resourceRef: {name: "ou-Workloads-Prod"}
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
                            resourceSelector: {
                                matchLabels: {
                                    "crossplane.io/claim-name": "acme-hops"
                                    "crossplane.io/claim-namespace": "acme"
                                }
                            }
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
    }
]
items= _items
