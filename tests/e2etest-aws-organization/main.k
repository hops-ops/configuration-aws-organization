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

# =============================================================================
# Persistent infrastructure - update these if re-creating the test environment
# =============================================================================

# Organization - AWS only allows one org per account, so we adopt the existing one
_test_org_name = "hops-e2etest-org"
_existing_org_id = "o-3lholziq1o"

# Test OU - persistent, imported via imports.organizationalUnits
_test_ou_path = "Test"
_test_ou_id = "ou-hdvp-fbcb7sbw"

# Test account - persistent, orphaned on delete
_test_account_name = "configuration-aws-organization"
_test_account_email = "configuration-aws-organization@ops.com.ai"
_test_account_id = "544051101726"

# =============================================================================
# Dynamic test resources - timestamped to allow concurrent test runs
# =============================================================================
_test_ou_name = "aws-organization-" + _now

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
                        # Import existing resources via the flat imports object
                        imports: {
                            organization: _existing_org_id
                            organizationalUnits: {
                                _test_ou_path: _test_ou_id
                            }
                            accounts: {
                                _test_account_name: _test_account_id
                            }
                        }
                        # Orphan only the Organization on deletion - AWS allows only one org per account
                        organization: {
                            managementPolicies: ["Create", "Observe", "Update", "LateInitialize"]
                            # Enable IAM service access for centralized root access management
                            awsServiceAccessPrincipals: [
                                "account.amazonaws.com"
                                "iam.amazonaws.com",
                                "ipam.amazonaws.com",
                                "sso.amazonaws.com",
                                "ram.amazonaws.com"
                            ]
                        }
                        organizationalUnits: [
                            # Test OU - persistent, imported via imports.organizationalUnits
                            {
                                path: _test_ou_path
                                managementPolicies: ["Create", "Observe", "Update", "LateInitialize"]
                                accounts: [
                                    {
                                        name: _test_account_name
                                        email: _test_account_email
                                        managementPolicies: ["Create", "Observe", "Update", "LateInitialize"]
                                    }
                                ]
                            }
                            # Timestamped child OUs - created and deleted each test run
                            {
                                path: "Test/" + _test_ou_name
                            }
                            {
                                path: "Test/" + _test_ou_name + "/Child-A"
                            }
                            {
                                path: "Test/" + _test_ou_name + "/Child-B"
                            }
                        ]
                        tags: {
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