# Test Audit

This script tests that the changes to the audit logs prevent the bug that was
observed when attempting to create an ACL Policy with Consul Enterprise 1.16.

To run the test, you must have a Consul Enterprise license set to the
environment variable `CONSUL_ENT_LICENSE` and have [Kind](https://kind.sigs.k8s.io/) installed.
