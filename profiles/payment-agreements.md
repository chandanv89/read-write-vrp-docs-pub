# Payment Agreements API Profile - v1.0.0-draft1 <!-- omit in toc -->

<!-- start-toc -->

<!-- end-toc -->

## Overview

The Payment Agreement API Profile describes the flows and common functionality for the Payment Agrement Setup and subsequent Payment Order submissions, which allows a Third Party Provider ('TPP') to:

- Register an intent to **stage** a payment-agreement consent.
- Optionally confirm available funds for a payment-order of
  - Specified amount
- Subsequently **submit** the payment-order for processing.
- Optionally retrieve the status of a payment-agreement **consent** and/or payment-order **resource**.

This profile should be read in conjunction with a compatible Read/Write Data API Profile which provides a description of the elements that are common across all the Read/Write Data APIs, and compatible individual resources.

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

### Design Principles

#### Scheme Agnostic

The API has been designed to be agnostic to the underlying payment scheme that is responsible for carrying out the payments under the Payment Agreement.

The design ensures that the field lengths, payloads and other design principals align with OBIE Payment Initiation standards, and be closely aligned with ISO20022 message format.

#### Status Codes

The API uses two status codes that serve two different purposes:

- The HTTP Status Code reflects the outcome of the API call (the HTTP operation on the resource).
- The Status field for the payment-agreement consent reflects the status of the PSU consent authorisation.
- The Status field for the payment-order resource reflects the status of the payment-order initiation or execution.

## Basics

### Overview

The figure below provides a **general** outline of a payment agrrement flow for all payment-order types using the Payment Agreement APIs. The payment-order types covered in this profile include:

- Domestic payments.

The payment-agreement consent and payment-order resource in the following flow generalises for the different payment-order types.

![Payments Flow](./images/VRP-ThreeCornerModel.png)

#### Steps

Step 1: Agree Payment-Agreement Initiation

- This flow begins with a PSU consenting setup of payment agreement. The consent is between the PSU and the TPP.
- The debtor account details and other mandatory Control Paremeters must be specified at this stage.

Step 2: Setup Payment-Agreement Consent

- The TPP connects to the ASPSP that services the PSU's payment account and creates a new **payment-agreement consent** resource. This informs the ASPSP that one of its PSUs intends to setup a **payment-agreement**. The ASPSP responds with an identifier for the payment-agreement consent resource (the ConsentId, which is the intent identifier).
- This step is carried out by making a **POST** request to the **payment-agreement-consent** resource.

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

- Once the PSU is authenticated and authorised the **payment-agreement-consent** , the TPP can check whether funds are available to make the payment.
- This is carried out by making a **POST** request, calling the **funds-confirmation** operator on the **payment-agreement-consent** resource.

Step 5: Create Payment-Order

- The TPP may then create **payment-order** resource, as and when under the perimeters of the Control Parameters specified in the Payment Agreement consent, for processing.
- This is carried out by making a **POST** request to the appropriate **payment-order** resource.
- The ASPSP returns the identifier for the payment-order resource to the TPP.

Step 6: Get Consent/Payment-Order/Payment-Details Status

- The TPP can check the status of the payment-agreement consent (with the ConsentId) or payment-order resource (with the payment-order resource identifier) or payment-details (with the payment-order resource identifier) .
- This is carried out by making a **GET** request to the **payment-agreement consent** or **payment-order** or **payment-details** resource.

#### Sequence Diagram

![Payments Flow](./images/payment-agreement-flow.png)

[Diagram source](./images/Payments-Flow.puml)

### Payment Restrictions

The standard does not provide a uniform set of restrictions for payment-order types that can be supported through this API.

For example, but not limited to:

- The Payment Order attributes breach the Control Parameters specified by the Payment Agreement Consent.
- The Payment Order cannot be executed because of the lack of funds or breach of limits excercised by th ASPSP.

In addition to the Control Parameters, each ASPSP **may** determine appropriate restrictions that they support based on their individual practices, standards and limitations. These restrictions should be documented on ASPSP developer portals.

An ASPSP **must** reject the payment-agreement **consent** if the ASPSP is unable to handle the request.

### Release Management

This section overviews the release management and versioning strategy for the Payment Agrement API. It applies to Payment Agreement Consent and Payment Order resources, specified in the Endpoints section.

#### Payment-Agreement Consent

##### POST

- A TPP **must not** create a payment-agreement consent ConsentId on a newer version and use it to create a payment-order resource in a previous version
- A TPP **must not** create a payment-agreement consent ConsentId on a previous version and use it to create a payment-order resource in a newer version

##### GET

- A TPP **must not** access a payment-agreement ConsentId created in a newer version, via a previous version endpoint
  - E.g., A ConsentId created in v2 accessed via a v1 ConsentId
- An ASPSP **must** choose to make ConsentIds accessible in future versions
  - E.g., for a ConsentId created in v1, an ASPSP must make it available via v2, because Payment Agreement Consent is a long lived consent.

#### Payment-Agreement Consent (Confirm Funds)

##### POST

- A TPP **must not** confirm funds using a payment-agreement-consent ConsentId created in a different version.
  - E.g. A ConsentId created in v2, must not be used to confirm funds on a v1 endpoint.

#### Payment-Order Resource

- Release Management of payment-order resource is same as Payment Initiation API Profile of the Read/Write API Standards.

## Security & Access Control

### Scopes

The access tokens required for accessing the Payment Agreement APIs are fine grained, and must have at least the following scope:

```
payment-agreements:rwe Read/Write/Edit scope for Payment Agreements
payments Aligned with Payment Initiation API, Payments scope for Payment Initiation
```

Fine grained scopes allow PSU to give Read, Write and Edit permissions specifically, each for the actions TPP is allowed to perform on the Consent Resource.

### Grants Types

PISPs **must** use a client credentials grant to obtain a token to make POST requests to the payment-agreement **consent** endpoints. In the specification, this grant type is referred to as "Client Credentials".

PISPs **must** use an authorization code grant using a redirect or decoupled flow to obtain a token to make POST requests to the payment-order **resource** endpoints. This token may also be used to confirm funds on a payment-agreement **consent** resource. In the specification, this grant type is referred to as "Authorization Code".

PISPs **must** use a client credentials grant to obtain a token to make GET requests.

### Consent Authorisation

OAuth 2.0 scopes are coarse-grained and the set of available scopes are defined at the point of client registration. There is no standard method for specifying and enforcing fine-grained scopes e.g., a scope to enforce payments of a specified amount on a specified date.

A *consent authorisation* is used to define the fine-grained scope that is granted by the PSU to the TPP.

The TPP **must** begin setup of a Variale Recurring Payment, by creating a **payment-agreement consent** resource through a **POST** operation. These resources indicate the  _consent_ that the TPP claims it has been given by the PSU. At this stage, the consent is not yet authorised as the ASPSP has not yet verified this claim with the PSU.

The ASPSP responds with a ConsentId. This is the intent-id that is used when initiating the authorization code grant (as described in the Trust Framework).

As part of the authorization code grant:

- The ASPSP authenticates the PSU.
- The ASPSP plays back the consent (registered by the TPP) back to the PSU to get consent authorisation. The PSU may accept or reject the consent in its entirety (but not selectively).

Once these steps are complete, the consent is considered to have been authorised by the PSU.

#### Multiple Authorisation

- Multi Authorisation aspects of payment-agreement and payment-order resource is same PISP R/W Payment Initiation APIs.

#### Error Condition

If the PSU does not complete a successful consent authorisation (e.g., if the PSU has not authenticated successfully), the authorization code grant ends with a redirection to the TPP with an error response as described in [RFC 6749 Section 4.1.2.1](https://tools.ietf.org/html/rfc6749#section-4.1.2.1). The PSU is redirected to the TPP with an error parameter indicating the error that occurred.

#### Consent Revocation

A PSU can revoke a payment-agreement consent once it has been authorized, from the TPP or ASPSP's portal.

Ways and mechanism is elaborated in the Resources and Data Model pages.

#### Changes to Debtor Accounts

TBC

#### Consent Re-authentication

Payment agreement consents are long-lived and can be re-authenticated by the PSU.

### Risk Scoring Information

Risk Scoring information available to OBIE Payment Initiation Payment Order is available to Payment Agreement - Payment Orders as well. So it's not repeated here.

## Data Model

### Reused Classes

#### OBRisk1

This section describes the Risk1 class which is reused in the payment-order consent and payment-order resources.

##### UML Diagram

![](./images/OBRisk1.gif)

##### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| --- |--- |--- |--- |--- |--- |--- |
| OBRisk1 | |OBRisk1 |The Risk section is sent by the initiating party to the ASPSP. It is used to specify additional details for risk scoring for Payments. |OBRisk1 | | |
| PaymentContextCode |0..1 |OBRisk1/PaymentContextCode |Specifies the payment context |OBExternalPaymentContext1Code |BillPayment<br>EcommerceGoods<br>EcommerceServices<br>Other PartyToParty | |
| MerchantCategoryCode |0..1 |OBRisk1/MerchantCategoryCode |Category code conform to ISO 18245, related to the type of services or goods the merchant provides for the transaction. |Min3Max4Text | | |
| MerchantCustomerIdentification |0..1 |OBRisk1/MerchantCustomerIdentification |The unique customer identifier of the PSU with the merchant. |Max70Text | | |
| DeliveryAddress |0..1 |OBRisk1/DeliveryAddress |Information that locates and identifies a specific address, as defined by postal services or in free format text. |PostalAddress18 | | |
| AddressLine |0..2 |OBRisk1/DeliveryAddress/AddressLine |Information that locates and identifies a specific address, as defined by postal services, that is presented in free format text. |Max70Text | | |
| StreetName |0..1 |OBRisk1/DeliveryAddress/StreetName |Name of a street or thoroughfare. |Max70Text | | |
| BuildingNumber |0..1 |OBRisk1/DeliveryAddress/BuildingNumber |Number that identifies the position of a building on a street. |Max16Text | | |
| PostCode |0..1 |OBRisk1/DeliveryAddress/PostCode |Identifier consisting of a group of letters and/or numbers that is added to a postal address to assist the sorting of mail. |Max16Text | | |
| TownName |1..1 |OBRisk1/DeliveryAddress/TownName |Name of a built-up area, with defined boundaries, and a local government. |Max35Text | | |
| CountrySubDivision |0..2 |OBRisk1/DeliveryAddress/CountrySubDivision |Identifies a subdivision of a country, for instance state, region, county. |Max35Text | | |
| Country |1..1 |OBRisk1/DeliveryAddress/Country |Nation with its own government, occupying a particular territory. |CountryCode |^[A-Z]{2,2}$ | |

#### OBCharge2

This section describes the OBCharge2 class - which is reused in the response payloads in the payment-order consent and payment-order resources.

##### UML Diagram

![](./images/OBCharge2.png)

##### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| --- |--- |--- |--- |--- |--- |--- |
| OBCharge2 | |OBCharge2 |Set of elements used to provide details of a charge for the payment initiation. |OBCharge2 | | |
| ChargeBearer |1..1 |OBCharge2/ChargeBearer |Specifies which party/parties will bear the charges associated with the processing of the payment transaction. |OBChargeBearerType1Code |BorneByCreditor<br>BorneByDebtor<br>FollowingServiceLevel<br>Shared | |
| Type |1..1 |OBCharge2/Type |Charge type, in a coded form. |OBExternalPaymentChargeType1Code | | |
| Amount |1..1 |OBCharge2/Amount |Amount of money associated with the charge type. |OBActiveOrHistoricCurrencyAndAmount | | |
| Amount |1..1 |OBCharge2/Amount/Amount |A number of monetary units specified in an active currency where the unit of currency is explicit and compliant with ISO 4217. |OBActiveCurrencyAndAmount_SimpleType | |^\d{1,13}\.\d{1,5}$ |
| Currency |1..1 |OBCharge2/Amount/Currency |A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds". |ActiveOrHistoricCurrencyCode | |^[A-Z]{3,3}$ |

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

#### SCA Support

As per current understanting, for the initiation of variable recurring Payment Agreement, the TPP must have a bilateral with ASPSP, so the SCA Parameters shall be agreed outside the scope of technical specification.

### Identifier Fields

This section describes the identifiers used through the Payment Order API flows, the direction of flow through the system, and how they are used.

The standard definitions for the elements in the API payloads are described in the Data Payload section. However, this table gives further detail on the business meaning, and how they are used.

| Generated |Identifier |Business Description |
| --- |--- |--- |
| Merchant/TPP Sent in API Payload |EndToEndIdentification |The EndToEndIdentification reference is a reference that can be populated by the debtor (or merchant in the ecommerce space). This reference is important to the debtor (could be an internal reference Id against the transaction), it Is NOT the reference information that will be primarily populated on the statement of the creditor (beneficiary). |
| Merchant/TPP Sent in API Payload |InstructionIdentification |The TPP generates the InstructionIdentification which is a unique transaction Id and passes it to the ASPSP (this is mandatory), but this does not have to go any further in the payment flow. The flow of this identifier needs to align with payment scheme rules.<br><br>The expectation is that this is unique indefinitely across all time periods. The TPP can ensure this is indefinitely unique by including a date or date time element to the field, or by inserting a unique Id. |
| Merchant/TPP Sent in API Payload |RemittanceInformation |The RemittanceInformation is the reference information that the creditor (or beneficiary) will need to reconcile (e.g. Invoice 123). |
| ASPSP / API System |ConsentId |A unique identification as assigned by the ASPSP to uniquely identify the payment-order consent resource. |
| ASPSP / API System |Payment Order Id |Anique identification as assigned by the ASPSP to uniquely identify the payment-order resource.<br><br><li>DomesticPaymentId</li><li>DomesticScheduledPaymentId</li><li>DomesticStandingOrderId</li><li>InternationalPaymentId</li><li>InternationalScheduledPaymentId</li> |
| ASPSP / Payment Scheme |Scheme Payment ID |This is generated by the ASPSP to uniquely identify a payment through a processing scheme. In the case of FPS, this is the FPID. |

The tables below identify the actor that initially creates each of the message identifiers and their transmission and visibility to other actors.

These flows are indicative and will be dependent on what payment schemes or agencies are able to support.

Key:

- O indicates the actor that creates the identifier.
- **=>** downstream direction of flow
- **<=** upstream direction of flow

#### Merchant Flow

| Identifier |PSU |Merchant |TPP |ASPSP Originating Bank |Payment Scheme |Beneficiary |
| --- |--- |--- |--- |--- |--- |--- |
| EndToEndIdentification | |O |=> |=> |=> |=> |
| RemittanceInformation | |O |=> |=> |=> |=> |
| InstructionIdentification | | |O |=> | | |
| ConsentId | | |<= |O | | |
| Payment Order Id | | |<= |O | | |
| Scheme Payment ID (e.g., FPID) | | | |O |=> |=> |

#### Party to Party Flow

| Identifier |PSU |Merchant |TPP |ASPSP Originating Bank |Payment Scheme |Beneficiary |
| --- |--- |--- |--- |--- |--- |--- |
| EndToEndIdentification | | |O |=> |=> |=> |
| RemittanceInformation |O | |=> |=> |=> |=> |
| InstructionIdentification | | |O |=> | | |
| ConsentId | | |<= |O | | |
| Payment Order Id | | |<= |O | | |
| Scheme Payment ID (e.g., FPID) | | | |O |=> |=> |

### Enumerations

#### Static Enumerations

TBC

#### ISO Enumerations

These following ISO Enumerations are used in the Payment APIs.

| ISO Data Type |Fields |ISO Enumeration Values URL |
| --- |--- |--- |
| Min3Max4Text |MerchantCategoryCode |https://www.iso.org/standard/33365.html |
| ActiveOrHistoricCurrencyCode |Currency |https://www.iso20022.org/external_code_list.page |
| CountryCode |Country |https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements |

#### Namespaced Enumerations

The enumerated values specified by Open Banking are documented in Swagger specification and Namespaced Enumerations page.

Namespaced enumerations specific to Payment Agreement specifications are TBD.

## Alternative and Error Flows

TBC