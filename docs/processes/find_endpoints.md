# Find endpoints [mCSD ITI-90]

## Summary

Find endpoints is the process of identifying and retrieving compatible care services as outlined in the mCSD protocol
 [ITI-90](https://profiles.ihe.net/ITI/mCSD/ITI-90.html). This guarantees that the EPD/PACS can locate the registered
 data provider endpoints where it can subsequently access the healthcare data. Both the query to the addressing service
 and its returned resources are semantically aligned with FHIR.

## Process overview

1. **EPD/PACS:** Requests a list of resources from the Addressing Service based on query parameters
2. **Addressing Service:** Accepts the query request and returns a list of matching resources

![Find endpoints](../images/structurizr-FindEndpoints.svg "Find endpoints")

## Interface definitions

2\. [Find Endpoints [ITI-90]](../../docs/interface-definitions/find-endpoints.md)
