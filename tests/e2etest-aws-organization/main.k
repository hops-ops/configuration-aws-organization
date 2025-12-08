import base64
import datetime
import file
import math
import models.ai.com.ops.hops.aws.v1alpha1 as awsv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.dev.meta.v2alpha1 as metav2alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

_now = str(int(math.floor(datetime.ticks())))

_creds = file.read("secrets/aws-creds")
_base64_creds = base64.encode(_creds)

# unique so multiple runs of the test don't conflict in AWS Account
_test_org_name = "e2etest-org-" + _now

_items = [
    metav1alpha1.E2ETest{
        metadata.name: ""
        spec= {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                awsv1alpha1.Organization{
                    metadata: {
                        name: _test_org_name
                        namespace: "default"
                    }
                    spec: {
                        managementPolicies: ["*"]
                        featureSet: "ALL"
                        organizationalUnits: [
                            {
                                name: "Security"
                            }
                            {
                                name: "Infrastructure"
                            }
                            {
                                name: "Workloads"
                                children: [
                                    {
                                        name: "Prod"
                                    }
                                    {
                                        name: "Non-Prod"
                                    }
                                ]
                            }
                        ]
                        aws: {
                            providerConfig: "default"
                        }
                        tags: {
                            "hops": "true"
                            "e2etest": "true"
                            "test-run": _now
                        }
                    }
                }
            ]
            extraResources: [
                {
                    apiVersion: "v1"
                    kind: "Secret"
                    metadata: {
                        name: "aws-creds"
                        namespace: "default"
                    }
                    data: {
                        creds: _base64_creds
                    }
                },
                {
                    apiVersion: "aws.m.upbound.io/v1beta1"
                    kind: "ProviderConfig"
                    metadata: {
                        name: "default"
                        namespace: "default"
                    }
                    spec: {
                        credentials: {
                            source: "Secret"
                            secretRef: {
                                namespace: "default"
                                name: "aws-creds"
                                key: "creds"
                            }
                        }
                    }
                }
            ]
            skipDelete: False
            timeoutSeconds: 4500
        }
    }
]
items= _items