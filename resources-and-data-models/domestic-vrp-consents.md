# Domestic VRP consents - v1.0.0-draft1 <!-- omit in toc -->

- [Overview](#overview)
- [Endpoints](#endpoints)
  - [POST /domestic-vrp-consents](#post-domestic-vrp-consents)
  - [GET /domestic-vrp-consents/{ConsentId}](#get-domestic-vrp-consentsconsentid)
  - [DELETE /domestic-vrp-consents/{ConsentId}](#delete-domestic-vrp-consentsconsentid)
  - [POST /domestic-vrp-consents/{ConsentId}/funds-confirmation](#post-domestic-vrp-consentsconsentidfunds-confirmation)
- [State Model - VRP consents](#state-model---vrp-consents)
- [Data Model](#data-model)
  - [OBCashAccountDebtorWithName](#obcashaccountdebtorwithname)
  - [OBCashAccountCreditor3](#obcashaccountcreditor3)
  - [OBBranchAndFinancialInstitutionIdentification6](#obbranchandfinancialinstitutionidentification6)
  - [OBDomesticVRPInitiation](#obdomesticvrpinitiation)
  - [OBDomesticVRPControlParameters](#obdomesticvrpcontrolparameters)
  - [OBRisk](#obrisk)
  - [OBDomesticVRPConsentRequest](#obdomesticvrpconsentrequest)
  - [OBDomesticVRPConsentResponse](#obdomesticvrpconsentresponse)
  - [OBVRPFundsConfirmationRequest](#obvrpfundsconfirmationrequest)
  - [OBVRPFundsConfirmationResponse](#obvrpfundsconfirmationresponse)
- [Usage Examples](#usage-examples)
  - [POST /domestic-vrp-consents](#post-domestic-vrp-consents-1)
    - [Request](#request)
    - [Response](#response)
  - [GET /domestic-vrp-consents/{ConsentId}](#get-domestic-vrp-consentsconsentid-1)
    - [Request](#request-1)
    - [Response](#response-1)
  
## Overview

The Domestic VRP Consents resource is used by a TPP to register a consent to initiate one or more of domestic payments within the control parameters agreed with the PSU.

This resource description should be read in conjunction with a compatible Variable Recurring Payments API Profile.

The PISP must call the end-point with the appropriate scope that they have been assigned.
The ASPSP may use the scope to limit to functionality to sweeping or non-sweeping usage of the VRP.

## Endpoints

| Resource | Operation |Endpoint |Mandatory  |Scope |Grant Type |Message Signing |Idempotency Key |Request Object |Response Object |
| -------- |-------------- |-------- |----------- |----- |---------- |--------------- |--------------- |-------------- |--------------- |
|domestic-vrp-consents |POST |POST /domestic-vrp-consents |Mandatory |vrp-consents:sweeping, vrp-consents:other |Client Credentials |Signed Request Signed Response |Yes | OBDomesticVRPConsentRequest |OBDomesticVRPConsentResponse |
|domestic-vrp-consents |GET |GET /domestic-vrp-consents/{ConsentId} |Mandatory |vrp-consents:sweeping, vrp-consents:other |Client Credentials |Signed Response |No |NA |OBDomesticVRPConsentResponse |
|domestic-vrp-consents |DELETE |DELETE /domestic-vrp-consents/{ConsentId} |Mandatory |vrp-consents:sweeping, vrp-consents:other |Client Credentials | NA |No |NA |None |
|domestic-vrp-consents |POST |POST /domestic-vrp-consents/{ConsentId}/funds-confirmation |Mandatory |vrp-consents:sweeping, vrp-consents:other |Authorization Code |Signed Request Signed Response |No |OBVRPFundsConfirmationRequest |OBVRPFundsConfirmationResponse |

### POST /domestic-vrp-consents

The API endpoint allows the TPP to ask an ASPSP to create a new `domestic-vrp-consents` resource.

The request payload may contain Debtor Accounts, but the PSU may not have been identified by the ASPSP.

The endpoint allows the TPP to send a copy of the consent (between PSU and TPP) to the ASPSP for the PSU to authorise.

The ASPSP creates the resource and responds with a unique ConsentId to refer to the resource.

The default/initial Status of the resource is set to `AwaitingAuthorisation`.

If the parameters specified by the TPP in this resource are not valid, or fail any rules, the ASPSP must return a 400 Bad Request. In such a situation a resource is not created.

### GET /domestic-vrp-consents/{ConsentId}

A TPP can retrieve a VRP consent resource that they have created to check its status at any point of time using this API.

### DELETE /domestic-vrp-consents/{ConsentId}

A TPP can delete a VRP consent resource that they have created by calling this API.

### POST /domestic-vrp-consents/{ConsentId}/funds-confirmation

This API endpoint allows the TPP to ask an ASPSP to confirm funds on the `DebtorAccount` associated with the `domestic-vrp-consent`.

An ASPSP can only respond to a funds confirmation request if the resource has a Status of `Authorized`.

If resource has any other Status, the ASPSP must respond with a 400 (Bad Request) and a `UK.OBIE.Resource.InvalidConsentStatus` error code.

## State Model - VRP consents

The state model for the VRP consents resource follows the generic consent state model. However, it does not use the `Consumed` status.

!["VRP consents Status"](./images/VRP-State-Diagram.png)

All `domestic-vrp-consents` start off with a state of `AwaitingAuthorisation`

Once the PSU authorises the resource - the state of the resource will be set to `Authorised`.

If the PSU rejects the consent, the state will be set to `Rejected`.

The available status codes for the VRP consents resource are:

- AwaitingAuthorisation
- Rejected
- Authorised

The definitions for the Status:

|  | Status |Status Description |
| ---| ------ |------------------ |
| 1 |AwaitingAuthorisation |The consent resource is awaiting PSU authorisation. |
| 2 |Rejected |The consent resource has been rejected. |
| 3 |Authorised |The consent resource has been successfully authorised. |
| 4 |Revoked |The consent resource has been revoked by the PSU, via ASPSP's online channel. |

## Data Model

The data dictionary section gives the detail on the payload content for the VRP consent API flows.

### OBCashAccountDebtorWithName

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __SchemeName__ (1..1) | `SchemeName` | Name of the identification scheme, in a coded form as published in an external list. | Namespaced Enumeration OBExternalAccountIdentification4Code
| __Identification__ (1..1) | `Identification` | Identification assigned by an institution to identify an account. This identification is known by the account owner. | Max256Text
| __Name__ (1..1) | `Name` | Name of the account, as assigned by the account servicing institution.  Usage: The account name is the name or names of the account owner(s) represented at an account level. The account name is not the product name or the nickname of the account. | Max70Text  
| __SecondaryIdentification__ (0..1) | `SecondaryIdentification` | This is secondary identification of the account, as assigned by the account servicing institution.  This can be used by building societies to additionally identify accounts with a roll number (in addition to a sort code and account number combination) | Max34Text

### OBCashAccountCreditor3

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __SchemeName__ (1..1) | `SchemeName` | Name of the identification scheme, in a coded form as published | __Identification__ (1..1) | `Identification` |Identification assigned by an institution to identify an account. This identification is known by the account owner.   |Max256Text
| __Name__ (1..1) | `Name` |Name of the account, as assigned by the account servicing institution, in consent with the account owner in order to provide an additional means of identification of the account.  Usage: The account name is different from the account owner name. The account name is used in certain user communities to provide a means of identifying the account, in addition to the account owner's identity and the account number. OB: No name validation is expected for confirmation of payee.|Max70Text  
| __SecondaryIdentification__ (0..1) | `SecondaryIdentification` |This is secondary identification of the account, as assigned by the account servicing institution.  This can be used by building societies to additionally identify accounts with a roll number__ (in addition to a sort code and account number combination).             |Max34Text

### OBBranchAndFinancialInstitutionIdentification6
| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __SchemeName__ (0..1) | `SchemeName` |Name of the identification scheme, in a coded form as published in an external list. |OBExternalFinancialInstitutionIdentification4Code
| __Identification__ (0..1) | `Identification` |Unique and unambiguous identification of a financial institution or a branch of a financial institution.  | Max35Text  
| __Name__ (0..1) | `Name` | Name by which an agent is known and which is usually used to identify that agent. | Max140Text
| __PostalAddress__ (0..1) | `PostalAddress` |Information that locates and identifies a specific address, as defined by postal services.| OBPostalAddress6
| __AddressType__ (0..1) | `PostalAddress. AddressType` |Identifies the nature of the postal address. |OBAddressTypeCode  |Business Correspondence DeliveryTo MailTo POBox Postal Residential Statement
| __Department__ (0..1) | `PostalAddress. Department` |Identification of a division of a large organisation or building. | Max70Text  
| __SubDepartment__ (0..1) | `PostalAddress. SubDepartment` |Identification of a sub-division of a large organisation or building. |Max70Text
| __StreetName__ (0..1) | `PostalAddress. StreetName`   |Name of a street or thoroughfare.    |Max70Text  
| __BuildingNumber__ (0..1) | `PostalAddress. BuildingNumber` |Number that identifies the position of a building on a street.   |Max16Text  
| __PostCode__ (0..1) | `PostalAddress. PostCode` |Identifier consisting of a group of letters and. or numbers that is added to a postal address to assist the sorting of mail.    |Max16Text  
| __TownName__ (0..1) | `PostalAddress. TownName` |Name of a built-up area, with defined boundaries, and a local government. |Max35Text  
| __CountrySubDivision__ (0..1) | `PostalAddress. CountrySubDivision` |Identifies a subdivision of a country such as state, region, county.      |Max35Text  
| __Country__ (0..1) | `PostalAddress. Country` | Nation with its own government.      |CountryCode
| __AddressLine__  (0..7) | `PostalAddress. AddressLine` |Information that locates and identifies a specific address, as defined by postal services, presented in free format text.      |Max70Text  

### OBDomesticVRPInitiation

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __DebtorAccount__ (0..1) | `DebtorAccount` | Unambiguous identification of the account of the debtor to which a debit entry will be made as a result of the transaction. | [OBCashAccountDebtorWithName](#OBCashAccountDebtorWithName)
| __CreditorAgent__ (0..1) | `CreditorAgent` | Financial institution servicing an account for the creditor.     | OBBranchAndFinancialInstitutionIdentification6
| __CreditorAccount__ (0..1) | `CreditorAccount`   |Unambiguous identification of the account of the creditor to which a credit entry will be posted as a result of the payment transaction.       |OBCashAccountCreditor3


### OBDomesticVRPControlParameters

The VRP consent is a common class used in `domestic-payment-consents` requests and responses

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __ValidFromDateTime__ (0..1) | `ValidFromDateTime` | Start date time for which the consent remains valid. | ISODateTime
| __ValidToDateTime__ (0..1) | `ValidToDateTime`   | End date time for which the consent remains valid. | ISODateTime
| __Reference__ (0..1) | `Reference`    |Unique reference, as assigned by the creditor, to unambiguously refer to the consent.     | Max35Text  
| __MaximumIndividualAmount__ (0..1) | `ControlParameters. MaximumIndividualAmount` | Maximum amount that can be specified in a payment instruction under this VRP consent| ActiveOrHistoricCurrencyAndAmount  
| __Amount__ (1..1) | `ControlParameters. MaximumIndividualAmount. Amount` | A number of monetary units specified in an active currency where the unit of currency is explicit and compliant with ISO 4217.
| __Currency__ (1..1) | `ControlParameters. MaximumIndividualAmount. Currency` | A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".   | ActiveOrHistoricCurrencyCode  
| __MaximumMonthlyAmount__ (0..1) | `ControlParameters. MaximumMonthlyAmount` | Maximum amount that can be specified in all payment instructions in a calendar month under this VRP consent |
| __Amount__ (1..1)  | `ControlParameters. MaximumMonthlyAmount. Amount` | A number of monetary units specified in an active currency where the unit of currency is explicit and compliant with ISO 4217.
| __Currency__ (1..1) | `ControlParameters. MaximumMonthlyAmount. Currency` | A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds". | ActiveOrHistoricCurrencyCode
| __VRPType__ (1..1) | `ControlParameters. VRPType` | The types of payments that can be made under this VRP consent. This can be used to indicate whether this include sweeping payment or other ecommerce payments. A value of `UK.OBIE.VRPType.Sweeping` can only be used when the API is called with the `vrp-consents:sweeping` scope. A value of `UK.OBIE.VRPType.Other` can only be used when the API is called with teh `vrp-consents:other` scope. | OBVRPConsentType - Namespaced Enumeration

### OBRisk

The Risk block is a common class used in requests and responses

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __PaymentContextCode__ (0..1) | `PaymentContextCode`            |Specifies the payment context        |OBExternalPaymentContext1Code: BillPayment EcommerceGoods EcommerceServices Other PartyToParty
| __MerchantCategoryCode__ (0..1) | `MerchantCategoryCode`          |Category code conform to ISO 18245, related to the type of services or goods the merchant provides for the transaction.        |Min3Max4Text
| __MerchantCustomerIdentification__ (0..1) | `MerchantCustomerIdentification` |The unique customer identifier of the PSU with the merchant.              |Max70Text  
| __DeliveryAddress__ (0..1) | `DeliveryAddress` |Information that locates and identifies a specific address, as defined by postal services or in free format text.              |PostalAddress18
| __AddressLine__ (0..2) | `DeliveryAddress. AddressLine`   |Information that locates and identifies a specific address, as defined by postal services, that is presented in free format text.              |Max70Text  
| __StreetName__ (0..1) | `DeliveryAddress. StreetName`    |Name of a street or thoroughfare.    |Max70Text  
| __BuildingNumber__ (0..1) | `DeliveryAddress. BuildingNumber` |Number that identifies the position of a building on a street.            |Max16Text  
| __PostCode__ (0..1) | `DeliveryAddress. PostCode`      |Identifier consisting of a group of letters and. or numbers that is added to a postal address to assist the sorting of mail.    |Max16Text  
| __TownName__ (1..1) |`DeliveryAddress. TownName`      |Name of a built-up area, with defined boundaries, and a local government. |Max35Text  
| __CountrySubDivision__  (0..1) | `DeliveryAddress. CountrySubDivision` |Identifies a subdivision of a country, for instance state, region, county.|Max35Text  
| __Country__ (1..1) | `DeliveryAddress. Country`      |Nation with its own government, occupying a particular territory. | `^[A-Z]{2,2}$`

### OBDomesticVRPConsentRequest

![OBDomesticVRPConsentRequest](./images/OBDomesticVRPConsentRequest.gif)

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __Data__ (0..1) | `Data`
| __ControlParameters__ (1..1) | `Data. ControlParameters` | The control parameters under which this VRP must operate | [OBDomesticVRPControlParameters](#OBDomesticVRPControlParameters)
| __Initiation__ (1..1) | `Data. Initiation` | The parameters of the VRP consent that should remain unchanged for each payment under this VRP | [OBDomesticVRPInitiation](#OBDomesticVRPInitiation)
| __Risk__ (1..1) | `Risk` | The consent payload is sent by the initiating party to the ASPSP. It is used to request a consent to move funds from the debtor account to a creditor. | OBRisk

### OBDomesticVRPConsentResponse

![OBDomesticVRPConsentResponse](./images/OBDomesticVRPConsentResponse.gif)

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __Data__ (1..1) | `Data`
| __ConsentId__  (1..1)| `Data. ConsentId` | Unique identification as assigned by the ASPSP to uniquely identify the consent resource.      | Max128Text
| __CreationDateTime__ (1..1)| `Data. CreationDateTime` | Date and time at which the resource was created.|ISODateTime
| __Status__ (1..1) | `Data. Status` | Specifies the status of resource in code form.  |Authorised AwaitingAuthorisation Rejected Revoked Expired
| __StatusUpdateDateTime__ (1..1)| `Data. StatusUpdateDateTime` |Date and time at which the resource status was updated.  | ISODateTime  
| __ControlParameters__ (1..1) | `Data. ControlParameters` | The control parameters under which this VRP must operate | [OBDomesticVRPControlParameters](#OBDomesticVRPControlParameters)
| __Initiation__ (1..1) | `Data. Initiation` | The parameters of the VRP consent that should remain unchanged for each payment under this VRP |  [OBDomesticVRPInitiation](#OBDomesticVRPInitiation)
| __DebtorAccount__ (0..1) | `Data.DebtorAccount` | The approved DebtorAccount that the payment can be made from. THe value must be populated for GET responses once the consent is approved. | OBCashAccountDebtorWithName
| __Risk__ (1..1) | `Risk` | The consent payload is sent by the initiating party to the ASPSP. It is used to request a consent to move funds from the debtor account to a creditor. | OBRisk

### OBVRPFundsConfirmationRequest

The OBVRPFundsConfirmationRequest object must be used to request funds availability for a specific amount in the Debtor Account included in the VRP consents.

![OBWritePAFundsConfirmationRequest1](./images/OBWritePAFundsConfirmationRequest1.gif)

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __Data__ (1..1) | `Data`
| __ConsentId__ (1..1) | `Data. ConsentId` |Unique identification as assigned by the ASPSP to uniquely identify the funds confirmation consent resource.      | Max128Text
| __Reference__ (1..1) | `Data. Reference` | Unique reference, as assigned by the PISP, to unambiguously refer to the request related to the payment transaction.|Max35Text
| __InstructedAmount__ (1..1) | `Data. InstructedAmount` | Amount of money to be confirmed as available funds in the debtor account. Contains an Amount and a Currency.      |OBActiveOrHistoricCurrencyAndAmount
| __Amount__ (1..1) | `Data. InstructedAmount. Amount`| A number of monetary units specified in an active currency where the unit of currency is explicit and compliant with ISO 4217.
| __Currency__ (1..1) | `Data. InstructedAmount. Currency`       |A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds". |ActiveOrHistoricCurrencyCode `^[A-Z]{3,3}$`

### OBVRPFundsConfirmationResponse

The OBVRPFundsConfirmationResponse object will be used for a response to a call to:

- POST /domestic-vrp-consents/{ConsentId}/funds-confirmation

![OBWritePAFundsConfirmationResponse1](./images/OBWritePAFundsConfirmationResponse1.gif)

The confirmation of funds response contains the result of a funds availability check.

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __Data__ (1..1)  | `Data` |
| __FundsConfirmationId__ (1..1)  | `Data. FundsConfirmationId`  |Unique identification as assigned by the ASPSP to uniquely identify the funds confirmation resource.|Max40Text
| __ConsentId__ (1..1)  | `Data. ConsentId`   |Unique identification as assigned by the ASPSP to uniquely identify the funds confirmation consent resource.   |Max128Text
| __CreationDateTime__ (1..1)  | `Data. CreationDateTime`     |Date and time at which the resource was created. |ISODateTime
| __Reference__ (1..1)  | `Data. Reference`   |Unique reference, as assigned by the CBPII, to unambiguously refer to the request related to the payment transaction.   |Max35Text
| __FundsAvailableResult__ (1..1)  | `Data. FundsAvailableResult` |Result of a funds availability check.     |OBPAFundsAvailableResult1
| __FundsAvailableDateTime__  (1..1)  | `Data. FundsAvailableResult. FundsAvailableDateTime`       |Date and time at which the funds availability check was generated.     |ISODateTime
| __FundsAvailable__ (1..1)  | `Data. FundsAvailableResult. FundsAvailable`      |Availaility result, clearly indicating the availability of funds given the Amount in the request.   | Available AvailableWithOverdraft NotAvailable      |   |
| __DebtorAccount__ (1..1)  | `Data. FundsAvailableResult. DebtorAccount`       |The account in which these funds are available     |OBCashAccountDebtorWithName
| __InstructedAmount__ (1..1)  | `Data. InstructedAmount`     |Amount of money to be confirmed as available funds in the debtor account. Contains an Amount and a Currency.   |OBActiveOrHistoricCurrencyAndAmount
| __Amount__ (1..1)  | `Data. InstructedAmount. Amount`     |A number of monetary units specified in an active currency where the unit of currency is explicit and compliant with ISO 4217.
| __Currency__ (1..1)  | `Data. InstructedAmount. Currency`   |A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".      |ActiveOrHistoricCurrencyCode

## Usage Examples

### POST /domestic-vrp-consents

#### Request

```json
POST /domestic-vrp-consents HTTP/1.1
Authorization: Bearer 2YotnFZFEjr1zCsicMWpAA
x-idempotency-key: FRESCO.21302.GFX.20
x-jws-signature: TGlmZSdzIGEgam91cm5leSBub3QgYSBkZXN0aW5hdGlvbiA=..T2ggZ29vZCBldmVuaW5nIG1yIHR5bGVyIGdvaW5nIGRvd24gPw==
x-fapi-customer-ip-address: 104.25.212.99
x-fapi-interaction-id: 93bac548-d2de-4546-b106-880a5018460d
Content-Type: application/json
Accept: application/json
```

```json
{
  "Data": {
    "ControlParameters": {
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "Reference": "Mandatory reference",
      "MaximumIndividualAmount": {
        "Amount": "165.88",
        "Currency": "GBP"
      },
      "MaximumMonthlyAmount": {
        "Amount": "1000",
        "Currency": "GBP"
      },
      "VRPType": "UK.OBIE.VRPType.Sweeping"
    },
    "Initiation": {
      "DebtorAccount": {
        "SchemeName": "UK.OBIE.IBAN",
        "Identification": "GB76LOYD30949301273801",
        "Name": "Marcus Sweeptum"
      },
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweeptum"
      }
    }
  },
  "Risk": {
    "PaymentContextCode": "PartyToParty"
  }
}
```

#### Response

```json
HTTP/1.1 201 Created
x-jws-signature: V2hhdCB3ZSBnb3QgaGVyZQ0K..aXMgZmFpbHVyZSB0byBjb21tdW5pY2F0ZQ0K
x-fapi-interaction-id: 93bac548-d2de-4546-b106-880a5018460d
Content-Type: application/json
```

```json
{
  "Data": {
    "ConsentId": "fe615446-e53a-45ed-954c-ae5d1f97a93b",
    "CreationDateTime": "2017-06-05T15:15:15+00:00",
    "Status": "AwaitingAuthorisation",
    "StatusUpdateDateTime": "2017-06-05T15:15:15+00:00",
    "ControlParameters": {
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "Reference": "Mandatory reference",
      "MaximumIndividualAmount": {
        "Amount": "165.88",
        "Currency": "GBP"
      },
      "MaximumMonthlyAmount": {
        "Amount": "1000",
        "Currency": "GBP"
      },
      "VRPType": "UK.OBIE.VRPType.Sweeping"
    },
    "Initiation": {
      "DebtorAccount": {
        "SchemeName": "UK.OBIE.IBAN",
        "Identification": "GB76LOYD30949301273801",
        "Name": "Marcus Sweeptum"
      },
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweeptum"
      }
    }
  },
  "Risk": {
    "PaymentContextCode": "PartyToParty"
  },
  "Links": {
    "Self": "https://api.alphabank.com/open-banking/v1.0/vrp/domestic-vrp-consents/fe615446-e53a-45ed-954c-ae5d1f97a93b"
  },
  "Meta": {}
}
```

### GET /domestic-vrp-consents/{ConsentId}

After consent authorisation

#### Request

```json
GET /domestic-vrp-consents/fe615446-e53a-45ed-954c-ae5d1f97a93b HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
x-fapi-auth-date: Sun, 10 Sep 2017 19:43:31 GMT
x-fapi-customer-ip-address: 104.25.212.99
x-fapi-interaction-id: 93bac548-d2de-4546-b106-880a5018460d
Accept: application/json
```

#### Response

```json
HTTP/1.1 200 OK
x-jws-signature: V2hhdCB3ZSBnb3QgaGVyZQ0K..aXMgZmFpbHVyZSB0byBjb21tdW5pY2F0ZQ0K
x-fapi-interaction-id: 93bac548-d2de-4546-b106-880a5018460d
Content-Type: application/json
```

```json
{
  "Data": {
    "ConsentId": "fe615446-e53a-45ed-954c-ae5d1f97a93b",
    "CreationDateTime": "2017-06-05T15:15:15+00:00",
    "Status": "AwaitingAuthorisation",
    "StatusUpdateDateTime": "2017-06-05T15:15:15+00:00",
    "ControlParameters": {
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "Reference": "Mandatory reference",
      "MaximumIndividualAmount": {
        "Amount": "165.88",
        "Currency": "GBP"
      },
      "MaximumMonthlyAmount": {
        "Amount": "1000",
        "Currency": "GBP"
      },
      "VRPType": "UK.OBIE.VRPType.Sweeping"
    },
    "Initiation": {
      "DebtorAccount": {
        "SchemeName": "UK.OBIE.IBAN",
        "Identification": "GB76LOYD30949301273801",
        "Name": "Marcus Sweeptum"
      },
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweeptum"
      }
    },
    "DebtorAccount": {
      "SchemeName": "UK.OBIE.IBAN",
      "Identification": "GB76LOYD30949301273801",
      "Name": "Marcus Sweeptum"
    }
  },
  "Risk": {
    "PaymentContextCode": "PartyToParty"
  },
  "Links": {
    "Self": "https://api.alphabank.com/open-banking/v1.0/vrp/domestic-vrp-consents/fe615446-e53a-45ed-954c-ae5d1f97a93b"
  },
  "Meta": {}
}
```
