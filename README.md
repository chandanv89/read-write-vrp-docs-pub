# OBIE Variable Recurring Payments (VRP) API Standards

The OBIE VRP API specification describes a collection of RESTful APIs that enable TPPs to setup an ongoing VRP Consent with PSU, and then initiate payments within the control parameters of the consent. These payments can be initiated without the PSU being present.

## Profiles

[VRP Consent API](./profiles/vrp-profile.md)

## Resources and Data Models

[VRP Consents](./resources-and-data-models/domestic-vrp-consents.md)

[Domestic VRP](./resources-and-data-models/domestic-vrps.md)

## Change Log

1. Changed all the scopes to `payments`
2. Removed references to `PATCH` operation.
3. Introduced the `ReadRefundAccount` field in the consent to indicate that `Refund` information should be included in the response.
4. Removed the `DebtorAccount` from Confirmation of Funds responses.
5. Removed the ability to indicate `AvailableWithOverdraft` in Confirmation of Funds responses.
6. Added details on `PSUAuthentictionMethod` to indicate permitted PSU authentication methods for a consent
7. Clarified the situations in which a re-authentication would be required.
8. Removed requirements around multi-auth and clarified that in the current version only single auth accounts will be supported.
9. Clarified plurality of VRPs is possible
10. Added support for `SupplementaryData` fields
11. Added support for `RemittanceInformation` fields
12. Added fields for `PeriodicLimits`
13. Added specific status code for failure of VRP payment to adhere to control parameters
14. Added support for `PSUAuthenticationMethod` fields
