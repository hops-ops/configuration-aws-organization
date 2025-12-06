import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "test-organization-render-minimal"
        spec= {
            assertResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta2"
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
            xrPath: "examples/organizations/example-minimal.yaml"
            xrdPath: "apis/organizations/definition.yaml"
            timeoutSeconds: 120
            validate: True
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name: "test-organization-render-with-accounts"
        spec= {
            compositionPath: "apis/organizations/composition.yaml"
            xrPath: "examples/organizations/example-standard.yaml"
            xrdPath: "apis/organizations/definition.yaml"
            timeoutSeconds: 120
            validate: True
            observedResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta2"
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
                    apiVersion: "organizations.aws.m.upbound.io/v1beta2"
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
                    apiVersion: "organizations.aws.m.upbound.io/v1beta2"
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
                    apiVersion: "organizations.aws.m.upbound.io/v1beta2"
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
                    apiVersion: "organizations.aws.m.upbound.io/v1beta2"
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
                    apiVersion: "organizations.aws.m.upbound.io/v1beta2"
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
                }
            ]
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name: "test-organization-render-standard"
        spec= {
            assertResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta2"
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
            xrPath: "examples/organizations/example-standard.yaml"
            xrdPath: "apis/organizations/definition.yaml"
            timeoutSeconds: 120
            validate: True
        }
    }
]
items= _items
