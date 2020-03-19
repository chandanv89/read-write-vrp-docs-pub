# Payment Agreements API Profile - v1.0.0-draft1 <!-- omit in toc -->

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

- Release Management of payment-order resource is same PISP R/W Payment Initiation APIs.

## Security & Access Control

### Scopes

The access tokens required for accessing the Payment Agreement APIs are fine grained, must have at least the following scope:

```
payment-agreements:rwe Payment agreement Read/Write/Edit scope
payments Payments scope
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

A PSU cannot revoke a payment-order consent once it has been authorized.

This is required to comply with Article 80 of PSD2.

#### Changes to Selected Account

For a payment-order consent, the selected debtor account cannot be changed once the consent has been authorized.

#### Consent Re-authentication

Payment consents are short-lived and cannot be re-authenticated by the PSU.

### Risk Scoring Information

During the design workshops, ASPSPs articulated a need to perform risk scoring on the payments initiated via the Payment API.

Information for risk scoring and assessment will come via:

- FAPI HTTP headers. These are defined in [Section 6.3](http://openid.net/specs/openid-financial-api-part-1-wd-02.html#client-provisions) of the FAPI specification and in the Headers section above.
- Additional fields identified by the industry as business logic security concerns which will be passed in the Risk section of the payload in the JSON object.

These are the set of additional fields in the risk section of the payload for v1.0 which will be specified by the TPP:

- PaymentContextCode.
- MerchantCategoryCode.
- MerchantCustomerIdentification.
- DeliveryAddress.

The PaymentContextCode describes the payment context and can have these values:

- BillPayment.
- EcommerceGoods.
- EcommerceServices.
- Other.
- PartyToParty.

Payments for EcommerceGoods and EcommerceServices will be expected to have a MerchantCategoryCode and MerchantCustomerIdentification populated. Payments for EcommerceGoods will also have the DeliveryAddress populated.

These fields are documented further in the Data Payload section.

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

#### OBAuthorisation1

This section describes the OBAuthorisation1 class which is used in the payment-order consent request and payment-order consent response payloads.

##### UML Diagram

![](./images/OBAuthorisation1.gif)

##### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| --- |--- |--- |--- |--- |--- |--- |
| OBAuthorisation1 | |OBAuthorisation1 |The authorisation type request from the TPP. |OBAuthorisation1 | | |
| AuthorisationType |1..1 |OBAuthorisation1/AuthorisationType |Type of authorisation flow requested. |OBExternalAuthorisation1Code |Any<br>Single | |
| CompletionDateTime |0..1 |OBAuthorisation1/CompletionDateTime |Date and time at which the requested authorisation flow must be completed. |ISODateTime | | |

#### OBMultiAuthorisation1

This section describes the OBMultiAuthorisation1 class which used in the response payloads of payment-order resources.

##### UML Diagram

![](./images/OBMultiAuthorisation1.gif)

##### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| --- |--- |--- |--- |--- |--- |--- |
| OBMultiAuthorisation1 | |OBMultiAuthorisation1 |The multiple authorisation flow response from the ASPSP. |OBMultiAuthorisation1 | | |
| Status |1..1 |OBMultiAuthorisation1/Status |Specifies the status of the authorisation flow in code form. |OBExternalStatus2Code |Authorised<br>AwaitingFurtherAuthorisation<br>Rejected | |
| NumberRequired |0..1 |OBMultiAuthorisation1/NumberRequired |Number of authorisations required for payment order (total required at the start of the multi authorisation journey). |Number | | |
| NumberReceived |0..1 |OBMultiAuthorisation1/NumberReceived |Number of authorisations received. |Number | | |
| LastUpdateDateTime |0..1 |OBMultiAuthorisation1/LastUpdateDateTime |Last date and time at the authorisation flow was updated. |ISODateTime | | |
| ExpirationDateTime |0..1 |OBMultiAuthorisation1/ExpirationDateTime |Date and time at which the requested authorisation flow must be completed. |ISODateTime | | |

#### OBDomesticRefundAccount1

This section describes the OBDomesticRefundAccount1 class which is used in the response payloads of Domestic Payment, Domestic Scheduled Payment and Domestic Standing Order.

##### UML Diagram

![](./images/OBDomesticRefundAccount1.png)

##### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| --- |--- |--- |--- |--- |--- |--- |
| OBDomesticRefundAccount1 |1..1 |OBDomesticRefundAccount1 |Unambiguous identification of the refund account to which a refund will be made as a result of the transaction. |OBDomesticRefundAccount1 | | |
| Account |1..1 |OBWritePaymentDetails1/Account |Provides the details to identify an account. |OBCashAccountCreditor3 | | |
| SchemeName |1..1 |OBDomesticRefundAccount1/Account/SchemeName |Name of the identification scheme, in a coded form as published in an external list. |OBExternalAccountIdentification4Code | | |
| Identification |1..1 |OBDomesticRefundAccount1/Account/Identification |Identification assigned by an institution to identify an account. This identification is known by the account owner. |Max256Text | | |
| Name |0..1 |OBDomesticRefundAccount1/Account/Name |Name of the account, as assigned by the account servicing institution. Usage: The account name is the name or names of the account owner(s) represented at an account level. The account name is not the product name or the nickname of the account. OB: ASPSPs may carry out name validation for Confirmation of Payee, but it is not mandatory. |Max70Text | | |
| SecondaryIdentification |0..1 |OBDomesticRefundAccount1/Account/SecondaryIdentification |This is secondary identification of the account, as assigned by the account servicing institution. This can be used by building societies to additionally identify accounts with a roll number (in addition to a sort code and account number combination). |Max34Text | | |


#### OBInternationalRefundAccount1

This section describes the OBInternationalRefundAccount1 class which is used in the response payloads of International Payment, International Scheduled Payment and International Standing Order.

##### UML Diagram

![](./images/OBInternationalRefundAccount1.png)

##### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| --- |--- |--- |--- |--- |--- |--- |
| OBInternationalRefundAccount1 |1..1 |OBInternationalRefundAccount1 |Unambiguous identification of the refund account to which a refund will be made as a result of the transaction. |OBInternationalRefundAccount1 | | |
| Creditor |0..1 |OBInternationalRefundAccount1/Creditor |Party to which an amount of money is due. |OBPartyIdentification43 | | |
| Name |0..1 |OBInternationalRefundAccount1/Creditor/Name |Name by which a party is known and which is usually used to identify that party. |Max140Text | | |
| PostalAddress |0..1 |OBInternationalRefundAccount1/Creditor/PostalAddress |Information that locates and identifies a specific address, as defined by postal services. |OBPostalAddress6 | | |
| AddressType |0..1 |OBInternationalRefundAccount1/Creditor/PostalAddress/AddressType |Identifies the nature of the postal address. |OBAddressTypeCode |Business Correspondence DeliveryTo MailTo POBox Postal Residential Statement | |
| Department |0..1 |OBInternationalRefundAccount1/Creditor/PostalAddress/Department |Identification of a division of a large organisation or building. |Max70Text | | |
| SubDepartment |0..1 |OBInternationalRefundAccount1/Creditor/PostalAddress/SubDepartment |Identification of a sub-division of a large organisation or building. |Max70Text | | |
| StreetName |0..1 |OBInternationalRefundAccount1/Creditor/PostalAddress/StreetName |Name of a street or thoroughfare. |Max70Text | | |
| BuildingNumber |0..1 |OBInternationalRefundAccount1/Creditor/PostalAddress/BuildingNumber |Number that identifies the position of a building on a street. |Max16Text | | |
| PostCode |0..1 |OBInternationalRefundAccount1/Creditor/PostalAddress/PostCode |Identifier consisting of a group of letters and/or numbers that is added to a postal address to assist the sorting of mail. |Max16Text | | |
| TownName |0..1 |OBInternationalRefundAccount1/Creditor/PostalAddress/TownName |Name of a built-up area, with defined boundaries, and a local government. |Max35Text | | |
| CountrySubDivision |0..1 |OBInternationalRefundAccount1/Creditor/PostalAddress/CountrySubDivision |Identifies a subdivision of a country such as state, region, county. |Max35Text | | |
| Country |0..1 |OBInternationalRefundAccount1/Creditor/PostalAddress/Country |Nation with its own government. |CountryCode | |^[A-Z]{2,2}$ |
| AddressLine |0..7 |OBInternationalRefundAccount1/Creditor/PostalAddress/AddressLine |Information that locates and identifies a specific address, as defined by postal services, presented in free format text. |Max70Text | | |
| Agent |0..1 |OBInternationalRefundAccount1/Agent |Financial institution servicing an account for the creditor. |OBBranchAndFinancialInstitutionIdentification6 | | |
| SchemeName |0..1 |OBInternationalRefundAccount1/Agent/SchemeName |Name of the identification scheme, in a coded form as published in an external list. |OBExternalFinancialInstitutionIdentification4Code | | |
| Identification |0..1 |OBInternationalRefundAccount1/Agent/Identification |Unique and unambiguous identification of a financial institution or a branch of a financial institution. |Max35Text | | |
| Name |0..1 |OBInternationalRefundAccount1/Agent/Name |Name by which an agent is known and which is usually used to identify that agent. |Max140Text | | |
| PostalAddress |0..1 |OBInternationalRefundAccount1/Agent/PostalAddress |Information that locates and identifies a specific address, as defined by postal services. |OBPostalAddress6 | | |
| AddressType |0..1 |OBInternationalRefundAccount1/Agent/PostalAddress/AddressType |Identifies the nature of the postal address. |OBAddressTypeCode |Business Correspondence DeliveryTo MailTo POBox Postal Residential Statement | |
| Department |0..1 |OBInternationalRefundAccount1/Agent/PostalAddress/Department |Identification of a division of a large organisation or building. |Max70Text | | |
| SubDepartment |0..1 |OBInternationalRefundAccount1/Agent/PostalAddress/SubDepartment |Identification of a sub-division of a large organisation or building. |Max70Text | | |
| StreetName |0..1 |OBInternationalRefundAccount1/Agent/PostalAddress/StreetName |Name of a street or thoroughfare. |Max70Text | | |
| BuildingNumber |0..1 |OBInternationalRefundAccount1/Agent/PostalAddress/BuildingNumber |Number that identifies the position of a building on a street. |Max16Text | | |
| PostCode |0..1 |OBInternationalRefundAccount1/Agent/PostalAddress/PostCode |Identifier consisting of a group of letters and/or numbers that is added to a postal address to assist the sorting of mail. |Max16Text | | |
| TownName |0..1 |OBInternationalRefundAccount1/Agent/PostalAddress/TownName |Name of a built-up area, with defined boundaries, and a local government. |Max35Text | | |
| CountrySubDivision |0..1 |OBInternationalRefundAccount1/Agent/PostalAddress/CountrySubDivision |Identifies a subdivision of a country such as state, region, county. |Max35Text | | |
| Country |0..1 |OBInternationalRefundAccount1/Agent/PostalAddress/Country |Nation with its own government. |CountryCode | |^[A-Z]{2,2}$ |
| AddressLine |0..7 |OBInternationalRefundAccount1/Agent/PostalAddress/AddressLine |Information that locates and identifies a specific address, as defined by postal services, presented in free format text. |Max70Text | | |
| Account |1..1 |OBInternationalRefundAccount1/Account |Unambiguous identification of the account of the creditor to which a credit entry will be posted as a result of the payment transaction. |OBCashAccountCreditor3 | | |
| SchemeName |1..1 |OBInternationalRefundAccount1/Account/SchemeName |Name of the identification scheme, in a coded form as published in an external list. |OBExternalAccountIdentification4Code | | |
| Identification |1..1 |OBInternationalRefundAccount1/Account/Identification |Identification assigned by an institution to identify an account. This identification is known by the account owner. |Max256Text | | |
| Name |1..1 |OBInternationalRefundAccount1/Account/Name |The account name is the name or names of the account owner(s) represented at an account level. Note, the account name is not the product name or the nickname of the account. OB: ASPSPs may carry out name validation for Confirmation of Payee, but it is not mandatory. |Max70Text | | |
| SecondaryIdentification |0..1 |OBInternationalRefundAccount1/Account/SecondaryIdentification |This is secondary identification of the account, as assigned by the account servicing institution. This can be used by building societies to additionally identify accounts with a roll number (in addition to a sort code and account number combination). |Max34Text | | |


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

#### OBSCASupportData1

This section describes the OBSCASupportData1 class, which is used across all  _payment order consent_  request resources, enabling PISPs to provide Supporting Data when requesting ASPSP for SCA Exemption.

##### UML Diagram

![](./images/OBSCASupportData1.gif)

##### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| --- |--- |--- |--- |--- |--- |--- |
| OBSCASupportData1 | |SCASupportData |Supporting Data provided by TPP, when requesting SCA Exemption. |OBSCASupportData1 | | |
| RequestedSCAExemptionType |0..1 |SCASupportData/RequestedSCAExemptionType |This field allows a TPP to request specific SCA Exemption for a Payment Initiation |OBExternalSCAExemptionType1Code |BillPayment<br>ContactlessTravel<br>EcommerceGoods<br>EcommerceServices<br>Kiosk<br>Parking<br>PartyToParty | |
| AppliedAuthenticationApproach |0..1 |SCASupportData/AppliedAuthenticationApproach |Specifies a character string with a maximum length of 40 characters.<br><br>Usage: This field indicates whether the PSU was subject to SCA performed by the TPP |OBExternalAppliedAuthenticationApproach1Code |CA<br>SCA | |
| ReferencePaymentOrderId |0..1 |SCASupportData/ReferencePaymentOrderId |Specifies a character string with a maximum length of 140 characters.<br><br>Usage: If the payment is recurring, then the transaction identifier of the previous payment occurrence so that the ASPSP can verify that the TPP, amount and the payee are the same as the previous occurrence. |Max128Text | | |

### Identifier Fields

This section describes the identifiers used through the Payment API flows, the direction of flow through the system, and how they are used.

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

This section gives the definitions for enumerations used in the Payment APIs.

| Code Class |Name |Definition |
| --- |--- |--- |
| OBExternalPaymentContext1Code |BillPayment |The context of the payment initiation is a bill payment. |
| OBExternalPaymentContext1Code |EcommerceGoods |The context of the payment initiation is for goods via an ecommerce channel. |
| OBExternalPaymentContext1Code |EcommerceServices |The context of the payment initiation is for services via an ecommerce channel. |
| OBExternalPaymentContext1Code |PartyToParty |The context of the payment initiation is a party to party payment. |
| OBExternalPaymentContext1Code |Other |The context of the payment initiation is of an other type. |
| OBTransactionIndividualStatus1Code |AcceptedSettlementCompleted |Settlement on the debtor's account has been completed.<br><br>Usage : this can be used by the first agent to report to the debtor that the transaction has been completed. Warning : this status is provided for transaction status reasons, not for financial information. It can only be used after bilateral agreement.<br><br>PISPs **must not** use this status as confirmation that settlement is complete on the creditor's account. |
| OBTransactionIndividualStatus1Code |AcceptedSettlementInProcess |All preceding checks such as technical validation and customer profile were successful and therefore the payment initiation has been accepted for execution. |
| OBTransactionIndividualStatus1Code |Pending |Payment initiation or individual transaction included in the payment initiation is pending. Further checks and status update will be performed. |
| OBTransactionIndividualStatus1Code |Rejected |Payment initiation or individual transaction included in the payment initiation has been rejected. |
| OBTransactionIndividualStatus1Code |AcceptedWithoutPosting |Payment instruction included in the credit transfer is accepted without being posted to the creditor customer's account. |
| OBTransactionIndividualStatus1Code |AcceptedCreditSettlementCompleted |Settlement on the creditor's account has been completed. |
| OBExternalConsentStatus1Code |AwaitingAuthorisation |The consent resource is awaiting PSU authorisation. |
| OBExternalConsentStatus1Code |Rejected |The consent resource has been rejected. |
| OBExternalConsentStatus1Code |Authorised |The consent resource has been successfully authorised. |
| OBExternalConsentStatus1Code |Consumed |The consented action has been successfully completed. This does not reflect the status of the consented action. |
| OBChargeBearerType1Code |BorneByCreditor |All transaction charges are to be borne by the creditor. |
| OBChargeBearerType1Code |BorneByDebtor |All transaction charges are to be borne by the debtor. |
| OBChargeBearerType1Code |FollowingServiceLevel |Charges are to be applied following the rules agreed in the service level and/or scheme. |
| OBChargeBearerType1Code |Shared |In a credit transfer context, means that transaction charges on the sender side are to be borne by the debtor, transaction charges on the receiver side are to be borne by the creditor. In a direct debit context, means that transaction charges on the sender side are to be borne by the creditor, transaction charges on the receiver side are to be borne by the debtor. |
| OBExternalAuthorisation1Code |Any |Any authorisation type is requested. |
| OBExternalAuthorisation1Code |Multiple |Multiple authorisation type is requested. |
| OBExternalAuthorisation1Code |Single |Single authorisation type is requested. |
| OBExternalStatus1Code |InitiationCompleted |The payment-order initiation has been completed. |
| OBExternalStatus1Code |InitiationFailed |The payment-order initiation has failed. |
| OBExternalStatus1Code |InitiationPending |The payment-order initiation is pending. |
| OBExternalStatus2Code |Authorised |The multiple authorisation flow has been fully authorised. |
| OBExternalStatus2Code |AwaitingFurtherAuthorisation |The multiple authorisation flow is awaiting further authorisation. |
| OBExternalStatus2Code |Rejected |The multiple authorisation flow has been rejected. |
| OBExternalStatus3Code |InitiationCompleted |The payment-order initiation has been completed. |
| OBExternalStatus3Code |InitiationFailed |The payment-order initiation has failed. |
| OBExternalStatus3Code |InitiationPending |The payment-order initiation is pending. |
| OBExternalStatus3Code |Cancelled |Payment initiation has been successfully cancelled after having received a request for cancellation. |
| OBExchangeRateType2Code |Actual |Exchange rate is the actual rate. |
| OBExchangeRateType2Code |Agreed |Exchange rate is the agreed rate between the parties. |
| OBExchangeRateType2Code |Indicative |Exchange rate is the indicative rate. |
| OBPriority2Code |Normal |Priority is normal. |
| OBPriority2Code |Urgent |Priority is urgent. |
| OBAddressTypeCode |Business |Address is the business address. |
| OBAddressTypeCode |Correspondence |Address is the address where correspondence is sent. |
| OBAddressTypeCode |DeliveryTo |Address is the address to which delivery is to take place. |
| OBAddressTypeCode |MailTo |Address is the address to which mail is sent. |
| OBAddressTypeCode |POBox |Address is a postal office (PO) box. |
| OBAddressTypeCode |Postal |Address is the complete postal address. |
| OBAddressTypeCode |Residential |Address is the home address. |
| OBAddressTypeCode |Statement |Address is the address where statements are sent. |
| OBTransactionIndividualExtendedISOStatus1Code |Accepted |Request is accepted. |
| OBTransactionIndividualExtendedISOStatus1Code |AcceptedCancellationRequest |Cancellation is accepted. |
| OBTransactionIndividualExtendedISOStatus1Code |AcceptedCreditSettlementCompleted |Settlement on the creditor's account has been completed. |
| OBTransactionIndividualExtendedISOStatus1Code |AcceptedCustomerProfile |Preceding check of technical validation was successful. Customer profile check was also successful. |
| OBTransactionIndividualExtendedISOStatus1Code |AcceptedFundsChecked |Preceding check of technical validation and customer profile was successful and an automatic funds check was positive. |
| OBTransactionIndividualExtendedISOStatus1Code |AcceptedSettlementCompleted |Settlement on the debtor's account has been completed.<br><br>Usage : this can be used by the first agent to report to the debtor that the transaction has been completed.<br><br>Warning : this status is provided for transaction status reasons, not for financial information. It can only be used after bilateral agreement |
| OBTransactionIndividualExtendedISOStatus1Code |AcceptedSettlementInProcess |All preceding checks such as technical validation and customer profile were successful and therefore the payment initiation has been accepted for execution. |
| OBTransactionIndividualExtendedISOStatus1Code |AcceptedTechnicalValidation |Authentication and syntactical and semantical validation are successful |
| OBTransactionIndividualExtendedISOStatus1Code |AcceptedWithChange |Instruction is accepted but a change will be made, such as date or remittance not sent. |
| OBTransactionIndividualExtendedISOStatus1Code |AcceptedWithoutPosting |Payment instruction included in the credit transfer is accepted without being posted to the creditor customer’s account. |
| OBTransactionIndividualExtendedISOStatus1Code |Cancelled |Request is cancelled. |
| OBTransactionIndividualExtendedISOStatus1Code |NoCancellationProcess |No cancellation process. |
| OBTransactionIndividualExtendedISOStatus1Code |PartiallyAcceptedCancellationRequest |Cancellation is partially accepted. |
| OBTransactionIndividualExtendedISOStatus1Code |PartiallyAcceptedTechnicalCorrect |Authentication and syntactical and semantical validation are successful. |
| OBTransactionIndividualExtendedISOStatus1Code |PaymentCancelled |Transaction has been cancelled. |
| OBTransactionIndividualExtendedISOStatus1Code |Pending |Payment initiation or individual transaction included in the payment initiation is pending. Further checks and status update will be performed. |
| OBTransactionIndividualExtendedISOStatus1Code |PendingCancellationRequest |Cancellation request is pending. |
| OBTransactionIndividualExtendedISOStatus1Code |Received |Payment initiation has been received by the receiving agent. |
| OBTransactionIndividualExtendedISOStatus1Code |Rejected |Payment initiation or individual transaction included in the payment initiation has been rejected. |
| OBTransactionIndividualExtendedISOStatus1Code |RejectedCancellationRequest |Cancellation request is rejected |
| OBTransactionIndividualStatusReason1Code |Cancelled |Reason why the payment status is cancelled |
| OBTransactionIndividualStatusReason1Code |PendingFailingSettlement |Reason why the payment status is pending (failing settlement). |
| OBTransactionIndividualStatusReason1Code |PendingSettlement |Reason why the payment status is pending (settlement). |
| OBTransactionIndividualStatusReason1Code |Proprietary |Defines a free text proprietary reason. |
| OBTransactionIndividualStatusReason1Code |ProprietaryRejection |Defines the reason that has been used by the Local Instrument system to reject the transaction |
| OBTransactionIndividualStatusReason1Code |Suspended |Reason why the payment status is suspended. |
| OBTransactionIndividualStatusReason1Code |Unmatched |Reason why the payment status is unmatched. |
| OBExternalSCAExemptionType1Code |BillPayment |Bill Payment |
| OBExternalSCAExemptionType1Code |ContactlessTravel |Contactless Travel |
| OBExternalSCAExemptionType1Code |EcommerceGoods |Ecommerce Goods |
| OBExternalSCAExemptionType1Code |EcommerceServices |Ecommerce Services |
| OBExternalSCAExemptionType1Code |Kiosk |Kisok |
| OBExternalSCAExemptionType1Code |Parking |Parking |
| OBExternalSCAExemptionType1Code |PartyToParty |Party To Party |
| OBExternalAppliedAuthenticationApproach1Code |CA |Single Factor Strong Customer Authentication |
| OBExternalAppliedAuthenticationApproach1Code |SCA |Multi Factor Strong Customer Authentication |
| OBReadRefundAccount1Code |Yes |Yes |
| OBReadRefundAccount1Code |No |No |

#### ISO Enumerations

These following ISO Enumerations are used in the Payment APIs.

| ISO Data Type |Fields |ISO Enumeration Values URL |
| --- |--- |--- |
| Min3Max4Text |MerchantCategoryCode |https://www.iso.org/standard/33365.html |
| ActiveOrHistoricCurrencyCode |Currency |https://www.iso20022.org/external_code_list.page |
| CountryCode |Country |https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements |

#### Namespaced Enumerations

The enumerated values specified by Open Banking are documented in Swagger specification and Namespaced Enumerations page.

## Alternative and Error Flows

### Idempotent Payment Order Consent

Note: this flow has been generalised for all payment-order types.

![](./images/Idempotent-Payment-Order-Consent.png)

<details>
  <summary>Diagram source</summary>

```
participant PSU
participant TPP
participant ASPSP Authorisation Server
participant ASPSP Resource Server

note over PSU, ASPSP Resource Server
Step 2: Setup Payment Order Consent (generalised for all payment orders)
end note
TPP <-> ASPSP Authorisation Server: Establish TLS 1.2 MA
TPP -> ASPSP Authorisation Server: Initiate Client Credentials Grant
ASPSP Authorisation Server -> TPP: token
TPP <-> ASPSP Resource Server: Establish TLS 1.2 MA
TPP -> ASPSP Resource Server: POST /payment-order-consents (x-idempotency-key={TPP-guid-1})
ASPSP Resource Server -> ASPSP Resource Server: Create new resource (ConsentId=1001)
alt unexpected failure
TPP -> ASPSP Resource Server: POST /payment-order-consents (x-idempotency-key={TPP-guid-1})
note right of ASPSP Resource Server
    The resource server recognizes that
    this is the same request as earlier.
    A new resource is not created.
    The ConsentId remains the same (e.g. 1001) as above.
    The status of the resource may be different if it has changed.

    This operation can be retried multiple times if required.
end note
end alt

ASPSP Resource Server -> TPP: HTTP 201(Created), ConsentId=1001
TPP -> PSU: Redirect (ConsentId)

option footer=bar
```

</details>

### Idempotent Payment Order

Note: this flow has been generalised for all payment-order types.

![](./images/IdempotentPaymentOrder.png)

<details>
  <summary>Diagram source</summary>

```
participant PSU
participant TPP
participant ASPSP Authorisation Server
participant ASPSP Resource Server

note over PSU, ASPSP Resource Server
 Step 4: Create payment-order (generalised for all payment orders)
end note
TPP <-> ASPSP Resource Server: Establish TLS 1.2 MA
TPP -> ASPSP Resource Server: POST /payment-orders ConsentId = 1001, x-idempotency-key={TPP-guid-2}

alt TPP attempts to POST to /payment-orders with same ConsentId
TPP -> ASPSP Resource Server: POST /payment-orders ConsentId = 1001, x-idempotency-key={TPP-guid-2}
ASPSP Resource Server -> TPP: HTTP 201 (Created), PaymentOrderId

note right of ASPSP Resource Server
    The resource server recognizes that this
    is the same request as earlier.
    A new resource is not created.
    The PaymentOrderId remains the same as above.
    The status of the resource may be different if it has changed.

    The operation can be retried multiple times if required.
end note
end alt
option footer=bar
```

</details>

### Multi-Auth Payment Order Consent

![](./images/Multi-Auth-Payment-Order-Consent.png)

<details>
  <summary>Diagram source</summary>

```
autonumber

participant PSU Initial Authoriser
participant PSU Final Authoriser
participant TPP
participant ASPSP Authorisation Server
participant ASPSP Resource Server

note over PSU Initial Authoriser, ASPSP Resource Server
Step 1: Agree domestic payment Initiation
end note
PSU Initial Authoriser -> TPP: Agree domestic payment initiation request

note over PSU Initial Authoriser, ASPSP Resource Server
 Step 2: Setup Payment-Order Consent
end note
TPP <-> ASPSP Authorisation Server: Establish TLS 1.2 MA
TPP -> ASPSP Authorisation Server: Initiate Client Credential Grant
ASPSP Authorisation Server -> TPP: access-token
TPP <-> ASPSP Resource Server: Establish TLS 1.2 MA
TPP -> ASPSP Resource Server: POST /domestic-payment-consents
state over ASPSP Resource Server: Consent Status: AwaitingAuthorisation
ASPSP Resource Server -> TPP: HTTP 201 (Created),ConsentId
TPP -> PSU Initial Authoriser: HTTP 302 (Found),Redirect (ConsentId)

note over PSU Initial Authoriser, ASPSP Resource Server
 Step 3: Authorize Consent - Initial Authoriser
end note
PSU Initial Authoriser -> ASPSP Authorisation Server: Follow redirect (ConsentId)
PSU Initial Authoriser <-> ASPSP Authorisation Server: Authenticate (SCA if required) and Authorise consent
state over ASPSP Resource Server: Consent Status: Authorised
ASPSP Authorisation Server -> PSU Initial Authoriser: HTTP 302 (Found), Redirect (authorization-code)
PSU Initial Authoriser -> TPP: Follow redirect (authorization-code)
TPP <-> ASPSP Authorisation Server: Establish TLS 1.2 MA
TPP -> ASPSP Authorisation Server: Exchange authorization-code for access token
ASPSP Authorisation Server -> TPP: access-token

note over PSU Initial Authoriser, ASPSP Resource Server
Step 4: Create Payment-Order
end note
TPP <-> ASPSP Resource Server: Establish TLS 1.2 MA
TPP -> ASPSP Resource Server: POST /domestic-payments
ASPSP Resource Server -> TPP: HTTP 201 (Created) DomesticPaymentId
state over ASPSP Resource Server: Consent Status: Consumed
state over ASPSP Resource Server: Payment Status: Pending
state over ASPSP Resource Server: MultiAuthorisation Status: AwaitingFurtherAuthorisation

note over PSU Initial Authoriser, ASPSP Resource Server
 Step 5: Authorize Consent - Final Authoriser
end note

PSU Final Authoriser -> ASPSP Authorisation Server: Authenticate (SCA if required) and Authorise consent

state over ASPSP Resource Server: MultiAuthorisation Status: Authorised
state over ASPSP Resource Server: Payment Status: AcceptedSettlementInProcess
state over ASPSP Resource Server: Payment Status: AcceptedSettlementComplete

    alt If TPP has registered a URL for event notification
        ASPSP Resource Server -> TPP: POST /event-notifications
        TPP -> ASPSP Resource Server: HTTP 200 (OK)
        TPP -> ASPSP Resource Server: GET /domestic-payments/{DomesticPaymentId}
        ASPSP Resource Server -> TPP: HTTP 200 (OK) domestic-payment resource
    else TPP may poll payment order status
        loop
            TPP -> ASPSP Resource Server: GET /domestic-payments/{DomesticPaymentId}
            ASPSP Resource Server -> TPP: HTTP 200 (OK) domestic-payment resource
        end
    end

option footer=bar
```
</details>

### Reject the Payment Order Consent Creation After CutOffDateTime

This example illustrates a scenario where an ASPSP choses to Reject the Payment-Order consent/resource request, after the CutoffTime. We have a CHAPS payment-order consent created after the CutOffDateTime, and ASPSP rejects the Consent, and the TPP chooses to place a Scheduled Payment-Order consent.

![](./images/CHAPS-SIP-AfterCutoffTime.png)

<details>
  <summary>Diagram source</summary>

```
autonumber
participant PSU
participant TPP
participant ASPSP Authorisation Server
participant ASPSP Resource Server

note over PSU, ASPSP Resource Server
Step 1: Agree Domestic Payment-Order initiation
end note
PSU <-> TPP: Initiate a funds transfer
PSU -> TPP: Select debtor and creditor accounts

note over PSU, ASPSP Resource Server
Step 2: Setup Domestic Payment Consent
end note
TPP <-> ASPSP Authorisation Server: Establish TLS 1.2 MA
TPP -> ASPSP Authorisation Server: Initiate Client Credentials Grant
ASPSP Authorisation Server -> TPP: access-token
TPP <-> ASPSP Resource Server: Establish TLS 1.2 MA
TPP -> ASPSP Resource Server: POST /domestic-payment-consents
note over TPP, ASPSP Resource Server
CHAPS Payment cutoff time expired, so consent initiation is rejected
end note
ASPSP Resource Server -> TPP: HTTP 400 (BAD_REQUEST)
TPP -> PSU: Try setting up a Scheduled Payment

note over PSU, ASPSP Resource Server
Step 3: Setup Domestic Scheduled Payment Consent
end note

note over PSU, ASPSP Resource Server
Step 4: Authorize consent
end note

note over PSU, ASPSP Resource Server
Step 5: Create Domestic Scheduled Payment-Order
end note

note over PSU, ASPSP Resource Server
Step 6: Get Domestic Scheduled Payment-Order status
end note
option footer=bar
```

</details>

### Reject the Payment Order Creation After CutOffDateTime

This example illustrates a scenario where an ASPSP choses to Reject the Payment-Order consent/resource request, after the CutoffTime. We have a CHAPS payment-order Consent created and the Authorisation completed before the CutOffDateTime, but the Payment-Order submission happened after the CutOffDateTime, so the ASPSP has rejected it.

![](./images/CHAPS-SIPO-AfterCutoffTime-2.png)

<details>
  <summary>Diagram source</summary>

```
autonumber
participant PSU
participant TPP
participant ASPSP Authorisation Server
participant ASPSP Resource Server

note over PSU, ASPSP Resource Server
Step 1: Agree Domestic Payment-Order initiation
end note
PSU <-> TPP: Initiate a funds transfer
PSU -> TPP: Select debtor and creditor accounts

note over PSU, ASPSP Resource Server
Step 2: Setup Domestic Payment-Order Consent
end note
TPP <-> ASPSP Authorisation Server: Establish TLS 1.2 MA
TPP -> ASPSP Authorisation Server: Initiate Client Credentials Grant
ASPSP Authorisation Server -> TPP: access-token
TPP <-> ASPSP Resource Server: Establish TLS 1.2 MA
TPP -> ASPSP Resource Server: POST /domestic-payment-consents
ASPSP Resource Server -> TPP: HTTP 201 (Created), ConsentId
TPP -> PSU: HTTP 302 (Found), Redirect (ConsentId)

note over PSU, ASPSP Resource Server
Step 3: Authorize consent
end note
PSU -> ASPSP Authorisation Server: Follow redirect (ConsentId)
PSU <-> ASPSP Authorisation Server: authenticate
PSU <-> ASPSP Authorisation Server: SCA if required
ASPSP Authorisation Server -> PSU: HTTP 302 (Found), Redirect (authorization-code)
PSU -> TPP: Follow redirect (authorization-code)
TPP <-> ASPSP Authorisation Server: Establish TLS 1.2 MA
TPP -> ASPSP Authorisation Server: Exchange authorization-code for access token
ASPSP Authorisation Server -> TPP: access-token

note over PSU, ASPSP Resource Server
Step 4: Create Domestic Payment-Order
end note
TPP <-> ASPSP Resource Server: Establish TLS 1.2 MA
note over TPP, ASPSP Authorisation Server
Delay in Redirection or
User spent too long to Authorise or
TPP took too long to submit Payment Order,
leading to Expiry of CHAPS Cutoff Time
end note

TPP -> ASPSP Resource Server: POST /domestic-payments
ASPSP Resource Server -> TPP: HTTP 400 (BAD_REQUEST)
TPP -> PSU: Try setting up a Scheduled Payment

note over PSU, ASPSP Resource Server
Step 5: Setup Domestic Scheduled Payment Consent
end note

option footer=bar
```

</details>
