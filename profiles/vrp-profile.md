# Variable Recurring Payments API Profile - v1.0.0-draft1 <!-- omit in toc -->

<!-- start-toc -->

<!-- end-toc -->

## Overview

The Variable Recurring Payments API Profile describes the flows and common functionality for setting up Payment Agrements and subsequently creating one or more payment orders that meet the limitations set by the payment agreement.

The functionality includes the ability to:
- **Stage** a payment agreement consent.
- Optionally **confirm available funds** for a payment-order of a specified amount
- Subsequently **submit** the payment-order for processing.
- Optionally **retrieve the status** of a payment agreement consents and payment-orders.

This profile should be read in conjunction with a compatible Read/Write Data API Profile which provides a description of the elements that are common across all the Read/Write Data APIs.

### Document Overview

This document consists of the following parts:

**Overview:** Provides an overview of the profile.

**Basics:** Identifies the flows, restrictions and release management.

**Security & Access Control:** Specifies the means for PISPs and PSUs to authenticate themselves and provide consent.

**Data Model:** Documents mappings and enumerations that apply to all the end-points.

**Alternative Flows:** Documents rules for alternative flows.

### Resources

Each of the Payment Initiation API resources are documented in the  [Resources and Data Models](../resources-and-data-models/) area of the specification. Each resource is documented with:

- Endpoints
  - The API endpoints available for the resource.
- Data Model
  - Resource definition.
  - UML diagram.
  - Permissions as they relate to accessing the resource.
  - Data dictionary - which defines fields, re-usable classes, mandatory (1..1) or conditional (0..1) as defined in the Design Principles section, and enumerations.
- Usage Examples

## Basics

### Overview

The figure below provides a **general** outline of a VRP flow.

The flow below is documented in terms of two abstract resources:
- `payment agreement consents`: A consent created between a PSU and TPP that allows the TPP to create `payment-orders` on behalf of the PSU subject to certain controls
- `payment-orders`: A payment order created by the TPP that meets the limitations set out by an approved payment agreement consent.

![Payments Flow](./images/VRP-ThreeCornerModel.png)

#### Steps

Step 1: PSU and TPP agree upon a payment agreement consent

- This flow begins with a PSU agreeing to the setup of payment agreement. The agreement and consent is between the PSU and the TPP.
- The debtor account details and other mandatory control parameters must be specified at this stage.

Step 2: Setup payment agreement consent

- The TPP connects to the ASPSP that services the PSU's payment account and creates a new `payment-agreement-consent` resource. This informs the ASPSP that one of its PSUs intends to setup a payment agreement consent. The ASPSP responds with an identifier for the payment agreement consent resource (the ConsentId, which is the intent identifier).
- This step is carried out by making a **POST** request to the `payment-agreement-consents` resource.

Step 3: Authorise Consent

- The TPP requests the PSU to authorise the consent. The ASPSP may carry this out by using a ***redirection flow*** or a ***decoupled flow***.
  - In a redirection flow, the TPP redirects the PSU to the ASPSP.
    - The redirect includes the ConsentId generated in the previous step.
    - This allows the ASPSP to correlate the payment agreement consent that was setup.
    - The ASPSP authenticates the PSU.
    - The PSU reviews the debtor account(s) at this stage (and other control parameters, specified in Step 1).
    - The ASPSP updates the state of the payment agreement consent resource internally to indicate that the consent has been authorised.
    - Once the consent has been authorised, the PSU is redirected back to the TPP.
  - In a decoupled flow, the ASPSP requests the PSU to authorise consent on an  *authentication device* that is separate from the  *consumption device* on which the PSU is interacting with the TPP.
    - The decoupled flow is initiated by the TPP calling a back-channel authorisation request.
    - The request contains a 'hint' that identifies the PSU paired with the consent to be authorised.
    - The ASPSP authenticates the PSU
    - The PSU reviews the debtor account(s) at this stage (and other control parameters, specified in Step 1).
    - The ASPSP updates the state of the payment agreement consent resource internally to indicate that the consent has been authorised.
    - Once the consent has been authorised, the ASPSP can make a callback to the TPP to provide an access token.

Step 4: Confirm Funds (TPP confirms the availability of specific amount in Customer's funds)

- Once the PSU is authenticated and authorised the payment agreement consent, the TPP can check whether funds are available to make the payment.
- This is carried out by making a **POST** request, calling the **funds-confirmation** operator on the **payment agreement consent** resource.

Step 5: Create Payment-Order

- The TPP can then creates one or more `payment-orders` resources for processing. The payment orders must adhere to the control parameters specified by the payment agreement consent.
- This is carried out by making a **POST** request to the appropriate `payment-orders` resource.
- The ASPSP returns the identifier for the payment-orders resource to the TPP.

Step 6: Get Consent/Payment-Order/Payment-Details Status

- The TPP can check the status of the payment agreement consent (with the ConsentId) or payment-order resource (with the payment-order resource identifier) or payment-details (with the payment-order resource identifier) .
- This is carried out by making a **GET** request to the **payment agreement consent** or **payment-order** or **payment-details** resource.

#### Sequence Diagram

![Payments Flow](./images/payment agreement-flow.png)

[Diagram source](./images/Payments-Flow.puml)

### Payment Restrictions

The standard provides a set of conrol parameters that may be specified as part of the payment agreement consent. These control parameters set limits for the payment orders that can be created by the TPP.

In additional to the control parameters defined in this standard ASPSPs may implement additional control parameters, limits and restrictions.

These restrictions should be documented on ASPSP developer portals.

### Release Management

This section overviews the release management and versioning strategy for the Variable Recurring Payments API. It applies to payment agreement consent and payment order resources, specified in the Endpoints section.

#### payment-agreement-consents

##### POST

- A TPP **must not** create a `payment-agreement-consents` resource on a newer version of the API and then use it to create a `payment-orders` resource using a previous version
- A TPP **must not** create a `payment agreement consent` resource on a previous version and use it to create a `payment-orders` resource in a newer version

##### GET

- A TPP **must not** access a `payment-agreement-consents` resource created in a newer version, using a GET operation on a previous version endpoint
- An ASPSP **must** allow TPPs to access a `payment-agreement-consents` resource created using an older version of the API through a newer version endpoint

#### payment-agreement-consents (Confirm Funds)

##### POST

- A TPP **must not** confirm funds using a payment agreement consent ConsentId created in a different version.

#### payment-orders

- Release Management of payment-order resource is same as Payment Initiation API Profile of the Read/Write API Standards.

## Security & Access Control

### Scopes

As defined in resources and data models.

### Grants Types

As defined in resources and data models.

### Consent Authorisation

OAuth 2.0 scopes are coarse-grained and the set of available scopes are defined at the point of client registration. There is no standard method for specifying and enforcing fine-grained scopes e.g., a scope to enforce payments of a specified amount on a specified date.

A *consent authorisation* is used to define the fine-grained scope that is granted by the PSU to the TPP.

The TPP **must** begin setup of a Variale Recurring Payment, by creating a payment-agreement-consents resource through a **POST** operation. These resources indicate the  _consent_ that the TPP claims it has been given by the PSU. At this stage, the consent is not yet authorised as the ASPSP has not yet verified this claim with the PSU.

The ASPSP responds with a ConsentId. This is the intent-id that is used when initiating the authorization code grant (as described in the Trust Framework).

As part of the authorization code grant:

- The ASPSP authenticates the PSU.
- The ASPSP plays back the consent (registered by the TPP) back to the PSU to get consent authorisation. The PSU may accept or reject the consent in its entirety (but not selectively).

Once these steps are complete, the consent is considered to have been authorised by the PSU.

### Consent Revocation

A PSU may revoke consent for initiation of any future payment orders, by revoking the authorisation of payment agreement consent, at any point in time.

The PSU may request the TPP to revoke consent that it has authorised. If consent is revoked with the TPP:

- The TPP must cease to initiate any future payment orders or Funds Confirmations using the payment agreement consent.
- The TPP must call the PATCH operation on the payment agreement consent resource, with Status modification request to change the payment agreement consent Status to Revoked, to indicate to the ASPSP that the PSU has revoked consent.

The PSU may revoke the payment agreement consent via ASPSP's online channel. If the consent is revoked via ASPSP:

- The ASPSP must immediately update the payment agreement consent resource status to Revoked.
- The ASPSP must fail any future payment order request using the ConsentId, with the Status Revoked.
- The ASPSP must make a Notification Event available for the TPP to poll/deliver Real Time Event Notification for the event - consent-authorization-revoked.

#### Multiple Authorisation

- Multi Authorisation aspects of payment agreement and payment-order resource is same PISP R/W Payment Initiation APIs.

#### Error Condition

If the PSU does not complete a successful consent authorisation (e.g., if the PSU has not authenticated successfully), the authorization code grant ends with a redirection to the TPP with an error response as described in [RFC 6749 Section 4.1.2.1](https://tools.ietf.org/html/rfc6749#section-4.1.2.1). The PSU is redirected to the TPP with an error parameter indicating the error that occurred.

#### Consent Revocation

A PSU can revoke a payment agreement consent once it has been authorized, from the TPP or ASPSP's portal.

Ways and mechanism is elaborated in the Resources and Data Model pages.

#### Changes to Debtor Accounts

TBC

#### Consent Re-authentication

payment agreement consents are long-lived and can be re-authenticated by the PSU.

### Risk Scoring Information

Risk Scoring information available to OBIE Payment Initiation payment order is available to payment agreement - payment orders as well.

## Data Model

### Reused Classes
The standard makes use of classes that are defined in the OBIE R/W API Specifications.

#### Multi Authorisation

TBC - To be checked against product requirements.

#### OBWritePaymentDetails1

This section describes the OBWritePaymentDetails1 class which used in the response payloads of payment-detail sub resources.

##### UML Diagram

![](./images/OBWritePaymentDetails1.png)

##### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| --- |--- |--- |--- |--- |--- |--- |
| OBWritePaymentDetails1 |1..1 |OBWritePaymentDetails1 |Payment status details. |OBWritePaymentDetails1 | | |
| PaymentTransactionId |1..1 |OBWritePaymentDetails1/PaymentTransactionId |Unique identifier for the transaction within an servicing institution. This identifier is both unique and immutable. |Max210Text | | |
| Status |1..1 |OBWritePaymentDetails1/Status |Status of a transfer, as assigned by the transaction administrator. |OBTransactionIndividualExtendedISOStatus1Code |Accepted<br>AcceptedCancellationRequest<br>AcceptedCreditSettlementCompleted<br>AcceptedCustomerProfile<br>AcceptedFundsChecked<br>AcceptedSettlementCompleted<br>AcceptedSettlementInProcess<br>AcceptedTechnicalValidation<br>AcceptedWithChange<br>AcceptedWithoutPosting<br>Cancelled<br>NoCancellationProcess<br>PartiallyAcceptedCancellationRequest<br>PartiallyAcceptedTechnicalCorrect<br>PaymentCancelled<br>Pending<br>PendingCancellationRequest<br>Received<br>Rejected<br>RejectedCancellationRequest | |
| StatusUpdateDateTime |1..1 |OBWritePaymentDetails1/StatusUpdateDateTime |Date and time at which the status was assigned to the transfer. |ISODateTime | | |
| StatusDetail |0..1 |OBWritePaymentDetails1/StatusDetail |Payment status details as per underlying Payment Rail. |OBPaymentStatusDetail1 | | |
| LocalInstrument |0..1 |OBWritePaymentDetails1/StatusDetail/LocalInstrument |User community specific instrument.<br><br>Usage: This element is used to specify a local instrument, local clearing option and/or further qualify the service or service level. |OBExternalLocalInstrument1Code | | |
| Status |1..1 |OBWritePaymentDetails1/StatusDetail/Status |Status of a transfer, as assigned by the transaction administrator. |Max128Text | | |
| StatusReason |0..1 |OBWritePaymentDetails1/StatusDetail/StatusReason |Reason Code provided for the status of a transfer. |OBTransactionIndividualStatusReason1Code |Cancelled<br>PendingFailingSettlement<br>PendingSettlement<br>Proprietary<br>ProprietaryRejection<br>Suspended<br>Unmatched | |
| StatusReasonDescription |0..1 |OBWritePaymentDetails1/StatusDetail/StatusReasonDescription |Reason provided for the status of a transfer. |Max256Text | | |
