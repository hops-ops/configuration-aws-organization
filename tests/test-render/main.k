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
                        name: "hops-org"
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
        metadata.name: "test-organization-render-standard"
        spec= {
            assertResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta2"
                    kind: "Organization"
                    metadata: {
                        name: "acme-org"
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
