# Payment Agreement Consents - v1.0.0-draft1 <!-- omit in toc -->

<!-- start-toc -->
- [Overview](#overview)
- [Endpoints](#endpoints)
  - [POST /payment-agreement-consents](#post-payment-agreement-consents)
    - [Status](#status)
  - [GET /payment-agreement-consents/{ConsentId}](#get-payment-agreement-consentsconsentid)
    - [Status](#status-1)
  - [POST /payment-agreement-consents/{ConsentId}/funds-confirmation](#post-payment-agreement-consentsconsentidfunds-confirmation)
  - [PATCH /payment-agreement-consents/{ConsentId}](#patch-payment-agreement-consentsconsentid)
  - [State Model](#state-model)
    - [Payment Agreement Consents](#payment-agreement-consents)
- [Data Model](#data-model)
  - [Payment Agreement Consents - Request](#payment-agreement-consents---request)
    - [UML Diagram](#uml-diagram)
    - [Notes](#notes)
    - [Data Dictionary](#data-dictionary)
  - [Payment Agreement Consents - Response](#payment-agreement-consents---response)
    - [UML Diagram](#uml-diagram-1)
    - [Notes](#notes-1)
    - [Data Dictionary](#data-dictionary-1)
  - [Payment Agreement Consents - Confirmation of Funds - Request](#payment-agreement-consents---confirmation-of-funds---request)
    - [UML Diagram](#uml-diagram-2)
    - [Notes](#notes-2)
    - [Data Dictionary](#data-dictionary-2)
  - [Payment Agreement Consents - Confirmation of Funds - Response](#payment-agreement-consents---confirmation-of-funds---response)
    - [UML Diagram](#uml-diagram-3)
    - [Notes](#notes-3)
    - [Data Dictionary](#data-dictionary-3)
  - [Payment Agreement Consents Update - Request](#payment-agreement-consents-update---request)
    - [UML Diagram](#uml-diagram-4)
    - [Notes](#notes-4)
    - [Data Dictionary](#data-dictionary-4)
  - [Payment Agreement Consents Update - Response](#payment-agreement-consents-update---response)
- [Usage Examples](#usage-examples)
  - [POST /payment-agreement-consents](#post-payment-agreement-consents-1)
    - [Request](#request)
    - [Response](#response)
  - [GET /payment-agreement-consents/{ConsentId}](#get-payment-agreement-consentsconsentid-1)
    - [Request](#request-1)
    - [Response](#response-1)
<!-- end-toc -->

## Overview

The payment agreement consents resource is used by a TPP to register a consent to initiate one or more of payment-orders, but within the control parameters of the Consent agreed with the PSU.

This resource description should be read in conjunction with a compatible Variable Recurring Payments API Profile.

## Endpoints

| Resource |HTTP Operation |Endpoint |Mandatory ? |Scope |Grant Type |Message Signing |Idempotency Key |Request Object |Response Object |
| -------- |-------------- |-------- |----------- |----- |---------- |--------------- |--------------- |-------------- |--------------- |
| payment-agreement-consents |POST |POST /payment-agreement-consents |Mandatory |payment-agreements:rw |Client Credentials |Signed Request Signed Response |Yes |OBWritePaymentAgreementConsent1 |OBWritePaymentAgreementConsentResponse1 |
| payment-agreement-consents |GET |GET /payment-agreement-consents/{ConsentId} |Mandatory |payment-agreements:rw |Client Credentials |Signed Response |No |NA |OBWritePaymentAgreementConsentResponse1 |
| payment-agreement-consents |POST |POST /payment-agreement-consents/{ConsentId}/funds-confirmation |Mandatory |payment-agreements:rw |Authorization Code |Signed Request Signed Response |No |OBWritePAFundsConfirmationRequest1 |OBWritePAFundsConfirmationResponse1 |
| payment-agreement-consents |PATCH |PATCH /payment-agreement-consents/{ConsentId} |Mandatory |payment-agreements:rw |Client Credentials |Signed Request |No |OBWritePAConsentUpdateRequest1 |NA |


### POST /payment-agreement-consents

The API endpoint allows the TPP to ask an ASPSP to create a new **payment agreement consents*- resource.

- The POST action indicates to the ASPSP that a payment agreement consents has been staged. At this point, although request payload contains Debtor Accounts, but the PSU may not have been identified by the ASPSP.
- The endpoint allows the TPP to send a copy of the consent (between PSU and TPP) to the ASPSP for the PSU to authorise.
- The ASPSP creates the **payment agreement consents** resource and responds with a unique ConsentId to refer to the resource.

#### Status

The default/initial Status of the resource is set to &quot;AwaitingAuthorisation&quot; immediately after the payment agreement consents has been created. If the parameters specified by the TPP in this resource aren't valid, or fail any rules, the ASPSP must throw 400 Bad Request with appropriate message, instead of creating a Resource with an alternative status.

| Status |
| ------ |
| AwaitingAuthorisation |

### GET /payment-agreement-consents/{ConsentId}

A TPP can retrieve a payment consent resource that they have created to check its status, before or after the the PSU Authorisation.

#### Status

Once the PSU authorises the payment agreement consents resource - the Status of the payment--agreement-consent resource will be set to &quot;Authorised&quot;.

If the PSU rejects the consent or the payment agreement consents has failed some other ASPSP validation, the Status will be set to &quot;Rejected&quot;.

Once a payment agreement consents has gone past valid time period specified by the PSU, the Status of the payment agreement consents will be set to &quot;Expired&quot;.

The available status codes for the payment agreement consents resource are:

| Status |
| ------ |
| AwaitingAuthorisation |
| Rejected |
| Authorised |
| Revoked |
| Expired |

### POST /payment-agreement-consents/{ConsentId}/funds-confirmation

This API endpoint allows the TPP to ask an ASPSP to confirm funds on a **payment agreement consents** resource, for the Debtor Accounts provided to the TPP by the ASPSP during the staging of the consent.

- An ASPSP can only respond to a funds confirmation request if the **payment-agreement-consents** resource has an Authorised status. If the status is not Authorised, an ASPSP must respond with a 400 (Bad Request) and a ```UK.OBIE.Resource.InvalidConsentStatus``` error code.
- Confirmation of funds requests do not affect the status of the **payment agreement consents** resource.
- In case of a Payment Agreements Consent with multiple Debtor Accounts, the TPP must always specify the Debtor Account(s), against which the Confirmation of funds is requested.

###  PATCH /payment-agreement-consents/{ConsentId}

This endpoint can be used by the TPP to modify the payment agreement consents, partially, i.e. elements of the consent.

- An ASPSP may request the TPP to get PSU's authorisation for such a change. In such a case:
  - ASPSP must update the payment agreement consents status to `AwaitingAuthorisation`, and
  - ASPSP must respond back with HTTP Status 302, indicating to the TPP that a PSU Authentication is required.

This endpoint can be used by the TPP, in case of PSU Revoking the Consent, via TPP's channel.
The TPP can sent the request to only update the Status to be Revoked.

### State Model

#### Payment Agreement Consents

The state model for the payment agreement consents resource follows the generic consent state model. However, does not use the Consumed status, as the consent for a payment-agreement is a long-lived consent. Instead, it has a new status - Expired.

!["payment agreement consents Status"](./images/VRP-State-Diagram.png)

The definitions for the Status:

|  | Status |Status Description |
| ---| ------ |------------------ |
| 1 |AwaitingAuthorisation |The consent resource is awaiting PSU authorisation. |
| 2 |Rejected |The consent resource has been rejected. |
| 3 |Authorised |The consent resource has been successfully authorised. |
| 4 |Revoked |The consent resource has been revoked by the PSU, via ASPSP's online channel. |
| 5 |Expired |The consented duration of the payment agreement consents is elapsed, and it cannot be further modified, or reauthenticated by the PSU. |

## Data Model

The data dictionary section gives the detail on the payload content for the Payment Agreement API flows.

### Payment Agreement Consents - Request

The OBWritePaymentAgreementConsent1 object will be used for the call to:

- POST /payment-agreement-consents

#### UML Diagram

![OBWritePaymentAgreementConsent1](./images/OBWritePaymentAgreementConsent1.gif)

#### Notes

The payment agreement consents **request** contains these objects:

- PaymentAgreement
  - One or more Debtor Accounts
  - Control Parameters
  - Creditor Details
- Risk

#### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| ---- |---------- |----- |------------------ |----- |----- |------- |
|OBWritePaymentAgreementConsent1        |   |OBWritePaymentAgreementConsent1    ||OBWritePaymentAgreementConsent1    |           | |
|Data   |0..1|OBWritePaymentAgreementConsent1/Data||OBWriteDataPaymentAgreementConsent1|           | |
|PaymentAgreement       |1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement              |The Mandate payload is sent by the initiating party to the ASPSP. It is used to request a mandate to move funds from the debtor account to a creditor.         |OBPaymentAgreement1|           | |
|ValidFromDateTime      |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ValidFromDateTime |Start date time for which the agreement remains valid.    |ISODateTime        |           | |
|ValidToDateTime        |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ValidToDateTime   |End date time for which the agreement remains valid. |ISODateTime        |           | |
|Reference              |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/Reference    |Unique reference, as assigned by the creditor, to unambiguously refer to the mandate.     |Max35Text          |           | |
|ControlParameters      |1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters ||OBControlParameters1|           | |
|MaximumPaymentsAllowedPerConsent       |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters/MaximumPaymentsAllowedPerConsent|Maximum number of instructions to be created and processed for the agreement until new Consent required.  |DecimalNumber      |           | |
|MaximumCumulativeAmount|0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters/MaximumCumulativeAmount         |Maximum amount of money to be moved between the debtor and creditor cumulative for the duration of the agreement, before deduction of charges, expressed in the currency as ordered by the initiating party.        |ActiveOrHistoricCurrencyAndAmount  |           | |
|Currency|1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters/MaximumCumulativeAmount/Currency|A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".   |ActiveOrHistoricCurrencyCode       |           |^[A-Z]{3,3}$          |
|MaximumIndividualAmount|0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters/MaximumIndividualAmount         |Maximum amount of money to be moved between the debtor and creditor in an individual payment transaction, before deduction of charges, expressed in the currency as ordered by the initiating party.|ActiveOrHistoricCurrencyAndAmount  |           | |
|Currency|1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters/MaximumIndividualAmount/Currency|A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".   |ActiveOrHistoricCurrencyCode       |           |^[A-Z]{3,3}$          |
|PeriodicControl        |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters/PeriodicControl ||OBPeriodicControl1 |           | |
|AmountPerPeriod        |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters/PeriodicControl/AmountPerPeriod |Maximum amount of money to be moved between the debtor and creditor during the period specified, before deduction of charges, expressed in the currency as ordered by the initiating party.         |ActiveOrHistoricCurrencyAndAmount  |           | |
|Currency|1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters/PeriodicControl/AmountPerPeriod/Currency        |A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".   |ActiveOrHistoricCurrencyCode       |           |^[A-Z]{3,3}$          |
|CountPerPeriod         |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters/PeriodicControl/CountPerPeriod  |Number of instructions to be created and processed during the specified period            |DecimalNumber      |           | |
|Period |1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/ControlParameters/PeriodicControl/Period          |Period for which the number of instructions are to be created and processed.              |Frequency6Code     |ADHO DAIL FRTN INDA MIAN MNTH QURT WEEK YEAR    | |
|DebtorAccounts         |1..n|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/DebtorAccounts    |Unambiguous identification of the account of the debtor to which a debit entry will be made as a result of the transaction.    |OBCashAccountDebtor4|           | |
|SchemeName             |1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/DebtorAccounts/SchemeName         |Name of the identification scheme, in a coded form as published in an external list.      |OBExternalAccountIdentification4Code|UK.OBIE.BBAN UK.OBIE.IBAN UK.OBIE.PAN UK.OBIE.Paym UK.OBIE.SortCodeAccountNumber| |
|Identification         |1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/DebtorAccounts/Identification     |Identification assigned by an institution to identify an account. This identification is known by the account owner.           |Max256Text         |           | |
|Name   |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/DebtorAccounts/Name|Name of the account, as assigned by the account servicing institution.  Usage: The account name is the name or names of the account owner(s) represented at an account level. The account name is not the product name or the nickname of the account.   |Max70Text          |           | |
|SecondaryIdentification|0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/DebtorAccounts/SecondaryIdentification            |This is secondary identification of the account, as assigned by the account servicing institution.  This can be used by building societies to additionally identify accounts with a roll number (in addition to a sort code and account number combination).             |Max34Text          |           | |
|CreditorAgent          |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent|Financial institution servicing an account for the creditor.              |OBBranchAndFinancialInstitutionIdentification6     |           | |
|SchemeName             |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/SchemeName          |Name of the identification scheme, in a coded form as published in an external list.      |OBExternalFinancialInstitutionIdentification4Code  |UK.OBIE.BICFI              | |
|Identification         |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/Identification      |Unique and unambiguous identification of a financial institution or a branch of a financial institution.  |Max35Text          |           | |
|Name   |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/Name|Name by which an agent is known and which is usually used to identify that agent.         |Max140Text         |           | |
|PostalAddress          |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress       |Information that locates and identifies a specific address, as defined by postal services.|OBPostalAddress6   |           | |
|AddressType            |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress/AddressType           |Identifies the nature of the postal address.         |OBAddressTypeCode  |Business Correspondence DeliveryTo MailTo POBox Postal Residential Statement    | |
|Department             |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress/Department            |Identification of a division of a large organisation or building.         |Max70Text          |           | |
|SubDepartment          |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress/SubDepartment         |Identification of a sub-division of a large organisation or building.     |Max70Text          |           | |
|StreetName             |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress/StreetName            |Name of a street or thoroughfare.    |Max70Text          |           | |
|BuildingNumber         |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress/BuildingNumber        |Number that identifies the position of a building on a street.            |Max16Text          |           | |
|PostCode|0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress/PostCode              |Identifier consisting of a group of letters and/or numbers that is added to a postal address to assist the sorting of mail.    |Max16Text          |           | |
|TownName|0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress/TownName              |Name of a built-up area, with defined boundaries, and a local government. |Max35Text          |           | |
|CountrySubDivision     |0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress/CountrySubDivision    |Identifies a subdivision of a country such as state, region, county.      |Max35Text          |           | |
|Country|0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress/Country|Nation with its own government.      |CountryCode        |           |^[A-Z]{2,2}$          |
|AddressLine            |0..7|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAgent/PostalAddress/AddressLine           |Information that locates and identifies a specific address, as defined by postal services, presented in free format text.      |Max70Text          |           | |
|CreditorAccount        |1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAccount   |Unambiguous identification of the account of the creditor to which a credit entry will be posted as a result of the payment transaction.       |OBCashAccountCreditor3             |           | |
|SchemeName             |1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAccount/SchemeName        |Name of the identification scheme, in a coded form as published in an external list.      |OBExternalAccountIdentification4Code|UK.OBIE.BBAN UK.OBIE.IBAN UK.OBIE.PAN UK.OBIE.Paym UK.OBIE.SortCodeAccountNumber| |
|Identification         |1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAccount/Identification    |Identification assigned by an institution to identify an account. This identification is known by the account owner.           |Max256Text         |           | |
|Name   |1..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAccount/Name              |Name of the account, as assigned by the account servicing institution, in agreement with the account owner in order to provide an additional means of identification of the account.  Usage: The account name is different from the account owner name. The account name is used in certain user communities to provide a means of identifying the account, in addition to the account owner's identity and the account number. OB: No name validation is expected for confirmation of payee.|Max70Text          |           | |
|SecondaryIdentification|0..1|OBWritePaymentAgreementConsent1/Data/PaymentAgreement/CreditorAccount/SecondaryIdentification           |This is secondary identification of the account, as assigned by the account servicing institution.  This can be used by building societies to additionally identify accounts with a roll number (in addition to a sort code and account number combination).             |Max34Text          |           | |
|Risk   |0..1|OBWritePaymentAgreementConsent1/Risk|The Risk section is sent by the initiating party to the ASPSP. It is used to specify additional details for risk scoring for Payments.         |OBRisk1            |           | |
|PaymentContextCode     |0..1|OBWritePaymentAgreementConsent1/Risk/PaymentContextCode            |Specifies the payment context        |OBExternalPaymentContext1Code      |BillPayment EcommerceGoods EcommerceServices Other PartyToParty | |
|MerchantCategoryCode   |0..1|OBWritePaymentAgreementConsent1/Risk/MerchantCategoryCode          |Category code conform to ISO 18245, related to the type of services or goods the merchant provides for the transaction.        |Min3Max4Text       |           | |
|MerchantCustomerIdentification         |0..1|OBWritePaymentAgreementConsent1/Risk/MerchantCustomerIdentification|The unique customer identifier of the PSU with the merchant.              |Max70Text          |           | |
|DeliveryAddress        |0..1|OBWritePaymentAgreementConsent1/Risk/DeliveryAddress|Information that locates and identifies a specific address, as defined by postal services or in free format text.              |PostalAddress18    |           | |
|AddressLine            |0..2|OBWritePaymentAgreementConsent1/Risk/DeliveryAddress/AddressLine   |Information that locates and identifies a specific address, as defined by postal services, that is presented in free format text.              |Max70Text          |           | |
|StreetName             |0..1|OBWritePaymentAgreementConsent1/Risk/DeliveryAddress/StreetName    |Name of a street or thoroughfare.    |Max70Text          |           | |
|BuildingNumber         |0..1|OBWritePaymentAgreementConsent1/Risk/DeliveryAddress/BuildingNumber|Number that identifies the position of a building on a street.            |Max16Text          |           | |
|PostCode|0..1|OBWritePaymentAgreementConsent1/Risk/DeliveryAddress/PostCode      |Identifier consisting of a group of letters and/or numbers that is added to a postal address to assist the sorting of mail.    |Max16Text          |           | |
|TownName|1..1|OBWritePaymentAgreementConsent1/Risk/DeliveryAddress/TownName      |Name of a built-up area, with defined boundaries, and a local government. |Max35Text          |           | |
|CountrySubDivision     |0..2|OBWritePaymentAgreementConsent1/Risk/DeliveryAddress/CountrySubDivision |Identifies a subdivision of a country, for instance state, region, county.|Max35Text          |           | |
|Country|1..1|OBWritePaymentAgreementConsent1/Risk/DeliveryAddress/Country       |Nation with its own government, occupying a particular territory.         |CountryCode        |           |^[A-Z]{2,2}$          |


### Payment Agreement Consents - Response

The OBWritePaymentAgreementConsentResponse1 object will be used for a response to a call to:

- POST /payment-agreement-consents
- GET /payment-agreement-consents/{ConsentId}

#### UML Diagram

![OBWritePaymentAgreementConsentResponse1](./images/OBWritePaymentAgreementConsentResponse1.gif)

#### Notes

Them payment agreement consents **response** contains the full **original** payload from the payment agreement consents **request**, with the additional elements below:

- ConsentId
- CreationDateTime the payment agreement consents resource was created.
- Status and StatusUpdateDateTime of the payment agreement consents resource.
- PaymentAgreement played back to the TPP.

#### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| ---- |---------- |----- |------------------ |----- |----- |------- |
|OBWritePaymentAgreementConsentResponse1| |OBWritePaymentAgreementConsentResponse1 ||OBWritePaymentAgreementConsentResponse1            ||            |
|Data |0..1            |OBWritePaymentAgreementConsentResponse1/Data||OBWriteDataPaymentAgreementResponse1||            |
|PaymentAgreementId  |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreementId|OB: Unique identification as assigned by the ASPSP to uniquely identify the mandate resource.      |Max128Text   ||            |
|CreationDateTime    |1..1            |OBWritePaymentAgreementConsentResponse1/Data/CreationDateTime  |Date and time at which the resource was created.         |ISODateTime  ||            |
|Status              |1..1            |OBWritePaymentAgreementConsentResponse1/Data/Status        |Specifies the status of resource in code form.           |OBExternalRequestStatus2Code    |Authorised AwaitingAuthorisation Rejected Revoked Expired           |            |
|StatusUpdateDateTime|1..1            |OBWritePaymentAgreementConsentResponse1/Data/StatusUpdateDateTime             |Date and time at which the resource status was updated.  |ISODateTime  ||            |
|PaymentAgreement    |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement  |The Mandate payload is sent by the initiating party to the ASPSP. It is used to request a mandate to move funds from the debtor account to a creditor.              |OBPaymentAgreement1             ||            |
|ValidFromDateTime   |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ValidFromDateTime   |Start date time for which the agreement remains valid.   |ISODateTime  ||            |
|ValidToDateTime     |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ValidToDateTime |End date time for which the agreement remains valid.     |ISODateTime  ||            |
|Reference           |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/Reference       |Unique reference, as assigned by the creditor, to unambiguously refer to the mandate.              |Max35Text||            |
|ControlParameters   |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters   ||OBControlParameters1            ||            |
|MaximumPaymentsAllowedPerConsent       |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters/MaximumPaymentsAllowedPerConsent        |Maximum number of instructions to be created and processed for the agreement until new Consent required.   |DecimalNumber||            |
|MaximumCumulativeAmount |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters/MaximumCumulativeAmount  |Maximum amount of money to be moved between the debtor and creditor cumulative for the duration of the agreement, before deduction of charges, expressed in the currency as ordered by the initiating party.  |ActiveOrHistoricCurrencyAndAmount   ||            |
|Currency            |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters/MaximumCumulativeAmount/Currency        |A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".   |ActiveOrHistoricCurrencyCode    ||^[A-Z]{3,3}$|
|MaximumIndividualAmount |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters/MaximumIndividualAmount  |Maximum amount of money to be moved between the debtor and creditor in an individual payment transaction, before deduction of charges, expressed in the currency as ordered by the initiating party.          |ActiveOrHistoricCurrencyAndAmount   ||            |
|Currency            |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters/MaximumIndividualAmount/Currency        |A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".   |ActiveOrHistoricCurrencyCode    ||^[A-Z]{3,3}$|
|PeriodicControl     |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters/PeriodicControl      ||OBPeriodicControl1              ||            |
|AmountPerPeriod     |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters/PeriodicControl/AmountPerPeriod         |Maximum amount of money to be moved between the debtor and creditor during the period specified, before deduction of charges, expressed in the currency as ordered by the initiating party.|ActiveOrHistoricCurrencyAndAmount   ||            |
|Currency            |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters/PeriodicControl/AmountPerPeriod/Currency|A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".   |ActiveOrHistoricCurrencyCode    ||^[A-Z]{3,3}$|
|CountPerPeriod      |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters/PeriodicControl/CountPerPeriod          |Number of instructions to be created and processed during the specified period  |DecimalNumber||            |
|Period              |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/ControlParameters/PeriodicControl/Period   |Period for which the number of instructions are to be created and processed.    |Frequency6Code   |ADHO DAIL FRTN INDA MIAN MNTH QURT WEEK YEAR  |            |
|DebtorAccounts      |1..n            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/DebtorAccounts  |Unambiguous identification of the account of the debtor to which a debit entry will be made as a result of the transaction.   |OBCashAccountDebtor4            ||            |
|SchemeName          |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/DebtorAccounts/SchemeName              |Name of the identification scheme, in a coded form as published in an external list.|OBExternalAccountIdentification4Code|UK.OBIE.BBAN UK.OBIE.IBAN UK.OBIE.PAN UK.OBIE.Paym UK.OBIE.SortCodeAccountNumber|            |
|Identification      |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/DebtorAccounts/Identification          |Identification assigned by an institution to identify an account. This identification is known by the account owner.      |Max256Text   ||            |
|Name |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/DebtorAccounts/Name |Name of the account, as assigned by the account servicing institution.  Usage: The account name is the name or names of the account owner(s) represented at an account level. The account name is not the product name or the nickname of the account.  |Max70Text||            |
|SecondaryIdentification |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/DebtorAccounts/SecondaryIdentification |This is secondary identification of the account, as assigned by the account servicing institution.  This can be used by building societies to additionally identify accounts with a roll number (in addition to a sort code and account number combination).|Max34Text||            |
|CreditorAgent       |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent   |Financial institution servicing an account for the creditor. |OBBranchAndFinancialInstitutionIdentification6     ||            |
|SchemeName          |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/SchemeName|Name of the identification scheme, in a coded form as published in an external list.|OBExternalFinancialInstitutionIdentification4Code  |UK.OBIE.BICFI      |            |
|Identification      |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/Identification           |Unique and unambiguous identification of a financial institution or a branch of a financial institution.   |Max35Text||            |
|Name |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/Name  |Name by which an agent is known and which is usually used to identify that agent.   |Max140Text   ||            |
|PostalAddress       |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress            |Information that locates and identifies a specific address, as defined by postal services.         |OBPostalAddress6 ||            |
|AddressType         |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress/AddressType|Identifies the nature of the postal address.             |OBAddressTypeCode|Business Correspondence DeliveryTo MailTo POBox Postal Residential Statement    |            |
|Department          |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress/Department |Identification of a division of a large organisation or building.|Max70Text||            |
|SubDepartment       |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress/SubDepartment  |Identification of a sub-division of a large organisation or building.           |Max70Text||            |
|StreetName          |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress/StreetName |Name of a street or thoroughfare.     |Max70Text||            |
|BuildingNumber      |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress/BuildingNumber |Number that identifies the position of a building on a street.   |Max16Text||            |
|PostCode            |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress/PostCode   |Identifier consisting of a group of letters and/or numbers that is added to a postal address to assist the sorting of mail.   |Max16Text||            |
|TownName            |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress/TownName   |Name of a built-up area, with defined boundaries, and a local government.       |Max35Text||            |
|CountrySubDivision  |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress/CountrySubDivision            |Identifies a subdivision of a country such as state, region, county.            |Max35Text||            |
|Country             |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress/Country    |Nation with its own government.       |CountryCode  ||`^[A-Z]{2,2}$`|
|AddressLine         |0..7            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAgent/PostalAddress/AddressLine|Information that locates and identifies a specific address, as defined by postal services, presented in free format text. |Max70Text||            |
|CreditorAccount     |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAccount |Unambiguous identification of the account of the creditor to which a credit entry will be posted as a result of the payment transaction.     |OBCashAccountCreditor3          ||            |
|SchemeName          |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAccount/SchemeName             |Name of the identification scheme, in a coded form as published in an external list.|OBExternalAccountIdentification4Code|UK.OBIE.BBAN UK.OBIE.IBAN UK.OBIE.PAN UK.OBIE.Paym UK.OBIE.SortCodeAccountNumber|            |
|Identification      |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAccount/Identification         |Identification assigned by an institution to identify an account. This identification is known by the account owner.      |Max256Text   ||            |
|Name |1..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAccount/Name|Name of the account, as assigned by the account servicing institution, in agreement with the account owner in order to provide an additional means of identification of the account.  Usage: The account name is different from the account owner name. The account name is used in certain user communities to provide a means of identifying the account, in addition to the account owner's identity and the account number. OB: No name validation is expected for confirmation of payee.|Max70Text||            |
|SecondaryIdentification |0..1            |OBWritePaymentAgreementConsentResponse1/Data/PaymentAgreement/CreditorAccount/SecondaryIdentification|This is secondary identification of the account, as assigned by the account servicing institution.  This can be used by building societies to additionally identify accounts with a roll number (in addition to a sort code and account number combination).|Max34Text||            |
|DebtorAccount       |0..n            |OBWritePaymentAgreementConsentResponse1/Data/DebtorAccount |Provides the details to identify an account.             |OBCashAccountDebtor4            ||            |
|SchemeName          |1..1            |OBWritePaymentAgreementConsentResponse1/Data/DebtorAccount/SchemeName         |Name of the identification scheme, in a coded form as published in an external list.|OBExternalAccountIdentification4Code|UK.OBIE.BBAN UK.OBIE.IBAN UK.OBIE.PAN UK.OBIE.Paym UK.OBIE.SortCodeAccountNumber|            |
|Identification      |1..1            |OBWritePaymentAgreementConsentResponse1/Data/DebtorAccount/Identification     |Identification assigned by an institution to identify an account. This identification is known by the account owner.      |Max256Text   ||            |
|Name |0..1            |OBWritePaymentAgreementConsentResponse1/Data/DebtorAccount/Name|Name of the account, as assigned by the account servicing institution.  Usage: The account name is the name or names of the account owner(s) represented at an account level. The account name is not the product name or the nickname of the account.  |Max70Text||            |
|SecondaryIdentification |0..1            |OBWritePaymentAgreementConsentResponse1/Data/DebtorAccount/SecondaryIdentification|This is secondary identification of the account, as assigned by the account servicing institution.  This can be used by building societies to additionally identify accounts with a roll number (in addition to a sort code and account number combination).|Max34Text||            |

### Payment Agreement Consents - Confirmation of Funds - Request

The OBWritePAFundsConfirmationRequest1 object must be used to request funds availability for a specific amount, across the Debtor Accounts included in the payment agreement consents.
The TPP must specify at least 1 debtor account, and the specified debtor accounts must be from the set of debtor account(s), specified and later authorised by the PSU.

- POST /payment-agreement-consents/{ConsentId}/funds-confirmation

#### UML Diagram

![OBWritePAFundsConfirmationRequest1](./images/OBWritePAFundsConfirmationRequest1.gif)

#### Notes

- None

#### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| ---- |---------- |----- |------------------ |----- |----- |------- |
|OBWritePAFundsConfirmationRequest1     |  |OBWritePAFundsConfirmationRequest1     ||OBWritePAFundsConfirmationRequest1  |              |      |
|Data  |1..1 |OBWritePAFundsConfirmationRequest1/Data||OBWriteDataPAFundsConfirmation1     |              |      |
|ConsentId|1..1 |OBWritePAFundsConfirmationRequest1/Data/ConsentId     |Unique identification as assigned by the ASPSP to uniquely identify the funds confirmation consent resource.      |Max128Text        |              |      |
|Reference|1..1 |OBWritePAFundsConfirmationRequest1/Data/Reference     |Unique reference, as assigned by the CBPII, to unambiguously refer to the request related to the payment transaction.|Max35Text         |              |      |
|DebtorAccounts          |1..n |OBWritePAFundsConfirmationRequest1/Data/DebtorAccounts|Unambiguous identification of the account of the debtor to which a debit entry will be made as a result of the transaction.         |OBCashAccountDebtor4 |              |      |
|SchemeName              |1..1 |OBWritePAFundsConfirmationRequest1/Data/DebtorAccounts/SchemeName       |Name of the identification scheme, in a coded form as published in an external list.|OBExternalAccountIdentification4Code|UK.OBIE.BBAN UK.OBIE.IBAN UK.OBIE.PAN UK.OBIE.Paym UK.OBIE.SortCodeAccountNumber|      |
|Identification          |1..1 |OBWritePAFundsConfirmationRequest1/Data/DebtorAccounts/Identification   |Identification assigned by an institution to identify an account. This identification is known by the account owner. |Max256Text        |              |      |
|Name  |0..1 |OBWritePAFundsConfirmationRequest1/Data/DebtorAccounts/Name             |Name of the account, as assigned by the account servicing institution.  Usage: The account name is the name or names of the account owner(s) represented at an account level. The account name is not the product name or the nickname of the account.|Max70Text         |              |      |
|SecondaryIdentification |0..1 |OBWritePAFundsConfirmationRequest1/Data/DebtorAccounts/SecondaryIdentification         |This is secondary identification of the account, as assigned by the account servicing institution.  This can be used by building societies to additionally identify accounts with a roll number (in addition to a sort code and account number combination).            |Max34Text         |              |      |
|InstructedAmount        |1..1 |OBWritePAFundsConfirmationRequest1/Data/InstructedAmount |Amount of money to be confirmed as available funds in the debtor account. Contains an Amount and a Currency.      |OBActiveOrHistoricCurrencyAndAmount |              |      |
|Amount|1..1 |OBWritePAFundsConfirmationRequest1/Data/InstructedAmount/Amount         |A number of monetary units specified in an active currency where the unit of currency is explicit and compliant with ISO 4217.      |OBActiveCurrencyAndAmount_SimpleType|              |`^\d{1,13}$\|^\d{1,13}\.\d{1,5}$`        |
|Currency |1..1 |OBWritePAFundsConfirmationRequest1/Data/InstructedAmount/Currency       |A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds". |ActiveOrHistoricCurrencyCode        |              |^[A-Z]{3,3}$         |

### Payment Agreement Consents - Confirmation of Funds - Response

The OBWritePAFundsConfirmationResponse1 object will be used for a response to a call to:

- POST /payment-agreement-consents/{ConsentId}/funds-confirmation

#### UML Diagram

![OBWritePAFundsConfirmationResponse1](./images/OBWritePAFundsConfirmationResponse1.gif)

#### Notes

The confirmation of funds response contains the result of a funds availability check.

#### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| ---- |---------- |----- |------------------ |----- |----- |------- |
|OBWritePAFundsConfirmationResponse1    |      |OBWritePAFundsConfirmationResponse1     |             |OBWritePAFundsConfirmationResponse1                ||   |
|Data      |1..1  |OBWritePAFundsConfirmationResponse1/Data|             |OBWriteDataPAFundsConfirmationResponse1            ||   |
|FundsConfirmationId                    |1..1  |OBWritePAFundsConfirmationResponse1/Data/FundsConfirmationId  |Unique identification as assigned by the ASPSP to uniquely identify the funds confirmation resource.|Max40Text             ||   |
|ConsentId |1..1  |OBWritePAFundsConfirmationResponse1/Data/ConsentId            |Unique identification as assigned by the ASPSP to uniquely identify the funds confirmation consent resource.                     |Max128Text            ||   |
|CreationDateTime |1..1  |OBWritePAFundsConfirmationResponse1/Data/CreationDateTime     |Date and time at which the resource was created. |ISODateTime           ||   |
|Reference |1..1  |OBWritePAFundsConfirmationResponse1/Data/Reference            |Unique reference, as assigned by the CBPII, to unambiguously refer to the request related to the payment transaction.            |Max35Text             ||   |
|FundsAvailableResult                   |0..1  |OBWritePAFundsConfirmationResponse1/Data/FundsAvailableResult |Result of a funds availability check.     |OBPAFundsAvailableResult1    ||   |
|FundsAvailableDateTime                 |1..1  |OBWritePAFundsConfirmationResponse1/Data/FundsAvailableResult/FundsAvailableDateTime       |Date and time at which the funds availability check was generated.     |ISODateTime           ||   |
|FundsAvailable   |1..1  |OBWritePAFundsConfirmationResponse1/Data/FundsAvailableResult/FundsAvailable               |Availaility result, clearly indicating the availability of funds given the Amount in the request.   |xs:string             |Available AvailableWithOverdraft NotAvailable      |   |
|DebtorAccount    |0..1  |OBWritePAFundsConfirmationResponse1/Data/FundsAvailableResult/DebtorAccount                |Provides the details to identify an account.     |OBCashAccountDebtor4  ||   |
|SchemeName|1..1  |OBWritePAFundsConfirmationResponse1/Data/FundsAvailableResult/DebtorAccount/SchemeName     |Name of the identification scheme, in a coded form as published in an external list.                |OBExternalAccountIdentification4Code               |UK.OBIE.BBAN UK.OBIE.IBAN UK.OBIE.PAN UK.OBIE.Paym UK.OBIE.SortCodeAccountNumber|   |
|Identification   |1..1  |OBWritePAFundsConfirmationResponse1/Data/FundsAvailableResult/DebtorAccount/Identification |Identification assigned by an institution to identify an account. This identification is known by the account owner.             |Max256Text            ||   |
|Name      |0..1  |OBWritePAFundsConfirmationResponse1/Data/FundsAvailableResult/DebtorAccount/Name           |Name of the account, as assigned by the account servicing institution.  Usage: The account name is the name or names of the account owner(s) represented at an account level. The account name is not the product name or the nickname of the account.      |Max70Text             ||   |
|SecondaryIdentification                |0..1  |OBWritePAFundsConfirmationResponse1/Data/FundsAvailableResult/DebtorAccount/SecondaryIdentification                     |This is secondary identification of the account, as assigned by the account servicing institution.  This can be used by building societies to additionally identify accounts with a roll number (in addition to a sort code and account number combination).|Max34Text             ||   |
|InstructedAmount |1..1  |OBWritePAFundsConfirmationResponse1/Data/InstructedAmount     |Amount of money to be confirmed as available funds in the debtor account. Contains an Amount and a Currency.                     |OBActiveOrHistoricCurrencyAndAmount                ||   |
|Amount    |1..1  |OBWritePAFundsConfirmationResponse1/Data/InstructedAmount/Amount     |A number of monetary units specified in an active currency where the unit of currency is explicit and compliant with ISO 4217.   |OBActiveCurrencyAndAmount_SimpleType               ||`^\d{1,13}$\|^\d{1,13}\.\d{1,5}$` |
|Currency  |1..1  |OBWritePAFundsConfirmationResponse1/Data/InstructedAmount/Currency   |A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".               |ActiveOrHistoricCurrencyCode ||`^[A-Z]{3,3}$`            |

### Payment Agreement Consents Update - Request

The OBWritePAUpdateRequest1 object must be used to update/modify the elements of the Payment Agreement Consent

- PUT /payment-agreement-consents/{ConsentId}

#### UML Diagram

![OBWritePAUpdateRequest1](./images/OBWritePAUpdateRequest1.gif)

#### Notes

- None

#### Data Dictionary

| Name |Occurrence |XPath |EnhancedDefinition |Class |Codes |Pattern |
| ---- |---------- |----- |------------------ |----- |----- |------- |
|OBWritePAUpdateRequest1                |      |OBWritePAUpdateRequest1          |             |OBWritePAUpdateRequest1      ||   |
|fields    |0..n  |OBWritePAUpdateRequest1/fields   | JSON Path of the field to be updated, e.g., Data.PaymentAgreement.Status     |Max500Text            ||   |

### Payment Agreement Consents Update - Response

The response to the update request could be one of the following HTTP Status codes, no payload is required.

| Http Status Code| Description|
|-- | -- |
|204| No Content, updates applied successfully|
|302| Updates require PSU Authorisation|
|4xx| Validation Errors|

## Usage Examples

### POST /payment-agreement-consents

#### Request

```
POST /payment-agreement-consents HTTP/1.1
Authorization: Bearer 2YotnFZFEjr1zCsicMWpAA
x-idempotency-key: FRESCO.21302.GFX.20
x-jws-signature: TGlmZSdzIGEgam91cm5leSBub3QgYSBkZXN0aW5hdGlvbiA=..T2ggZ29vZCBldmVuaW5nIG1yIHR5bGVyIGdvaW5nIGRvd24gPw==
x-fapi-auth-date: Sun, 10 Sep 2017 19:43:31 GMT
x-fapi-customer-ip-address: 104.25.212.99
x-fapi-interaction-id: 93bac548-d2de-4546-b106-880a5018460d
Content-Type: application/json
Accept: application/json
```

```json
{
  "Data": {
    "PaymentAgreement": {
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "Reference": "Mandatory reference",
      "DebtorAccount": [
        {
          "SchemeName": "UK.OBIE.IBAN",
          "Identification": "GB76LOYD30949301273801",
          "SecondaryIdentification": "Roll 56988"
        }
      ],
      "CreditorAccount": {
          "SchemeName": "SortCodeAccountNumber",
          "Identification": "30949330000010",
          "SecondaryIdentification": "Roll 90210"
        }
      ,
      "ControlParameters": {
        "MaximumIndividualAmount": {
          "Amount": "165.88",
          "Currency": "GBP"
        },
        "MaximumCumulativeAmount": {
          "Amount": "1000",
          "Currency": "GBP"
        }
      }
    }
  },
  "Risk": {
    "PaymentContextCode": "EcommerceGoods",
    "MerchantCategoryCode": "5967",
    "MerchantCustomerIdentification": "053598653254",
    "DeliveryAddress": {
      "AddressLine": [
        "Flat 7",
        "Acacia Lodge"
      ],
      "StreetName": "Acacia Avenue",
      "BuildingNumber": "27",
      "PostCode": "GU31 2ZZ",
      "TownName": "Sparsholt",
      "CountySubDivision": [
        "Wessex"
      ],
      "Country": "UK"
    }
  }
}
```

#### Response

```
HTTP/1.1 201 Created
x-jws-signature: V2hhdCB3ZSBnb3QgaGVyZQ0K..aXMgZmFpbHVyZSB0byBjb21tdW5pY2F0ZQ0K
x-fapi-interaction-id: 93bac548-d2de-4546-b106-880a5018460d
Content-Type: application/json
```

```json
{
  "Data": {
    "ConsentId": "58923",
    "Status": "AwaitingAuthorisation",
    "CreationDateTime": "2017-06-05T15:15:13+00:00",
    "StatusUpdateDateTime": "2017-06-05T15:15:13+00:00",
    "ReadRefundAccount": "Yes",
     "PaymentAgreement": {
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "Reference": "Mandatory reference",
      "DebtorAccount": [
        {
          "SchemeName": "UK.OBIE.IBAN",
          "Identification": "GB76LOYD30949301273801",
          "SecondaryIdentification": "Roll 56988"
        }
      ],
      "CreditorAccount": {
          "SchemeName": "SortCodeAccountNumber",
          "Identification": "30949330000010",
          "SecondaryIdentification": "Roll 90210"
        }
      ,
      "ControlParameters": {
        "MaximumIndividualAmount": {
          "Amount": "165.88",
          "Currency": "GBP"
        },
        "MaximumCumulativeAmount": {
          "Amount": "1000",
          "Currency": "GBP"
        }
      }
    }
  },
  "Risk": {
    "PaymentContextCode": "EcommerceGoods",
    "MerchantCategoryCode": "5967",
    "MerchantCustomerIdentification": "053598653254",
    "DeliveryAddress": {
      "AddressLine": [
        "Flat 7",
        "Acacia Lodge"
      ],
      "StreetName": "Acacia Avenue",
      "BuildingNumber": "27",
      "PostCode": "GU31 2ZZ",
      "TownName": "Sparsholt",
      "CountySubDivision": [
        "Wessex"
      ],
      "Country": "UK"
    }
  },
  "Links": {
    "Self": "https://api.alphabank.com/open-banking/v1.0/vrp/payment-agreement-consents/58923"
  },
  "Meta": {}
}
```

### GET /payment-agreement-consents/{ConsentId}

#### Request

```
GET /payment-agreement-consents/58923 HTTP/1.1
Authorization: Bearer Jhingapulaav
x-fapi-auth-date: Sun, 10 Sep 2017 19:43:31 GMT
x-fapi-customer-ip-address: 104.25.212.99
x-fapi-interaction-id: 93bac548-d2de-4546-b106-880a5018460d
Accept: application/json
```

#### Response

```
HTTP/1.1 200 OK
x-jws-signature: V2hhdCB3ZSBnb3QgaGVyZQ0K..aXMgZmFpbHVyZSB0byBjb21tdW5pY2F0ZQ0K
x-fapi-interaction-id: 93bac548-d2de-4546-b106-880a5018460d
Content-Type: application/json
```

```json
{
  "Data": {
    "ConsentId": "58923",
    "Status": "Authorised",
    "CreationDateTime": "2017-06-05T15:15:13+00:00",
    "StatusUpdateDateTime": "2017-06-05T15:15:22+00:00",
    "ReadRefundAccount": "Yes",
     "PaymentAgreement": {
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "Reference": "Mandatory reference",
      "DebtorAccount": [
        {
          "SchemeName": "UK.OBIE.IBAN",
          "Identification": "GB76LOYD30949301273801",
          "SecondaryIdentification": "Roll 56988"
        }
      ],
      "CreditorAccount": {
          "SchemeName": "SortCodeAccountNumber",
          "Identification": "30949330000010",
          "SecondaryIdentification": "Roll 90210"
        }
      ,
      "ControlParameters": {
        "MaximumIndividualAmount": {
          "Amount": "165.88",
          "Currency": "GBP"
        },
        "MaximumCumulativeAmount": {
          "Amount": "1000",
          "Currency": "GBP"
        }
      }
    }
  },
  "Risk": {
    "PaymentContextCode": "EcommerceGoods",
    "MerchantCategoryCode": "5967",
    "MerchantCustomerIdentification": "053598653254",
    "DeliveryAddress": {
      "AddressLine": [
        "Flat 7",
        "Acacia Lodge"
      ],
      "StreetName": "Acacia Avenue",
      "BuildingNumber": "27",
      "PostCode": "GU31 2ZZ",
      "TownName": "Sparsholt",
      "CountySubDivision": [
        "Wessex"
      ],
      "Country": "UK"
    }
  },
  "Links": {
    "Self": "https://api.alphabank.com/open-banking/v1.0/vrp/payment-agreement-consents/58923"
  },
  "Meta": {}
}

```
