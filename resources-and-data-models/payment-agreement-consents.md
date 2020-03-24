# Domestic Payments Consents - v3.1.5 <!-- omit in toc -->

<!-- start-toc -->
- [Overview](#overview)
- [Endpoints](#endpoints)
  - [POST /payment-agreement-consents](#post-payment-agreement-consents)
    - [Status](#status)
  - [GET /payment-agreement-consents/{ConsentId}](#get-payment-agreement-consentsconsentid)
    - [Status](#status-1)
  - [POST /payment-agreement-consents/{ConsentId}/funds-confirmation](#post-payment-agreement-consentsconsentidfunds-confirmation)
  - [State Model](#state-model)
    - [Payment Agreement Consent](#payment-agreement-consent)
- [Data Model](#data-model)
  - [Payment Agreement Consent - Request](#payment-agreement-consent---request)
    - [UML Diagram](#uml-diagram)
    - [Notes](#notes)
    - [Data Dictionary](#data-dictionary)
  - [Payment Agreement Consent - Response](#payment-agreement-consent---response)
    - [UML Diagram](#uml-diagram-1)
    - [Notes](#notes-1)
    - [Data Dictionary](#data-dictionary-1)
  - [Payment Agreement Consent Confirmation of Funds - Request](#payment-agreement-consent-confirmation-of-funds---request)
    - [UML Diagram](#uml-diagram-2)
    - [Notes](#notes-2)
    - [Data Dictionary](#data-dictionary-2)
  - [Payment Agreement Consent Confirmation of Funds - Response](#payment-agreement-consent-confirmation-of-funds---response)
    - [UML Diagram](#uml-diagram-3)
    - [Notes](#notes-3)
    - [Data Dictionary](#data-dictionary-3)
- [Usage Examples](#usage-examples)
  - [POST /payment-agreement-consents](#post-payment-agreement-consents-1)
    - [Request](#request)
    - [Response](#response)
  - [GET /payment-agreement-consents/{ConsentId}](#get-payment-agreement-consentsconsentid-1)
    - [Request](#request-1)
    - [Response](#response-1)
<!-- end-toc -->

## Overview

The Payment Agreement Consent resource is used by a TPP to register an intent to initiate a series of Immediate Payments, but within the control parameters of the Consent agreed with the PSU.

This resource description should be read in conjunction with a compatible Payment Agreements API Profile.

## Endpoints

| Resource |HTTP Operation |Endpoint |Mandatory ? |Scope |Grant Type |Message Signing |Idempotency Key |Request Object |Response Object |
| -------- |-------------- |-------- |----------- |----- |---------- |--------------- |--------------- |-------------- |--------------- |
| payment-agreement-consents |POST |POST /payment-agreement-consents |Mandatory |payment-agreements:rw |Client Credentials |Signed Request Signed Response |Yes |OBWritePaymentAgreementConsent1 |OBWritePaymentAgreementConsentResponse1 |
| payment-agreement-consents |GET |GET /payment-agreement-consents/{ConsentId} |Mandatory |payment-agreements:rw |Client Credentials |Signed Response |No |NA |OBWritePaymentAgreementConsentResponse1 |
| payment-agreement-consents |POST |POST /payment-agreement-consents/{ConsentId}/funds-confirmation |Mandatory |payment-agreements:rw |Authorization Code |Signed Request Signed Response |No |OBWritePAFundsConfirmationRequest1 |OBWritePAFundsConfirmationResponse1 |
| payment-agreement-consents |PATCH |PATCH /payment-agreement-consents/{ConsentId} |Mandatory |payment-agreements:rw |Client Credentials |Signed Request |No |OBWritePAConsentUpdateRequest1 |NA |


### POST /payment-agreement-consents

The API endpoint allows the TPP to ask an ASPSP to create a new **payment-agreement-consent*- resource.

- The POST action indicates to the ASPSP that a payment agreement consent has been staged. At this point, although request payload contains Debtor Accounts, but the PSU may not have been identified by the ASPSP.
- The endpoint allows the TPP to send a copy of the consent (between PSU and TPP) to the ASPSP for the PSU to authorise.
- The ASPSP creates the **payment-agreement-consent** resource and responds with a unique ConsentId to refer to the resource.

#### Status

The default/initial Status of the resource is set to &quot;AwaitingAuthorisation&quot; immediately after the payment-agreement-consent has been created. If the parameters specified by the TPP in this resource aren't valid, or fail any rules, the ASPSP must throw 400 Bad Request with appropriate message, instead of creating a Resource with an alternative status.

| Status |
| ------ |
| AwaitingAuthorisation |

### GET /payment-agreement-consents/{ConsentId}

A TPP can retrieve a payment consent resource that they have created to check its status, before or after the the PSU Authorisation.

#### Status

Once the PSU authorises the payment-agreement-consent resource - the Status of the payment--agreement-consent resource will be set to &quot;Authorised&quot;.

If the PSU rejects the consent or the payment-agreement-consent has failed some other ASPSP validation, the Status will be set to &quot;Rejected&quot;.

Once a payment-agreement-consent has gone past valid time period specified by the PSU, the Status of the payment-agreement-consent will be set to &quot;Expired&quot;.

The available status codes for the payment-agreement-consent resource are:

| Status |
| ------ |
| AwaitingAuthorisation |
| Rejected |
| Authorised |
| Revoked |
| Expired |

### POST /payment-agreement-consents/{ConsentId}/funds-confirmation

This API endpoint allows the TPP to ask an ASPSP to confirm funds on a **payment-agreement-consent** resource, for the Debtor Accounts provided to the TPP by the ASPSP during the staging of the consent.

- An ASPSP can only respond to a funds confirmation request if the **payment-agreement-consent** resource has an Authorised status. If the status is not Authorised, an ASPSP must respond with a 400 (Bad Request) and a ```UK.OBIE.Resource.InvalidConsentStatus``` error code.
- Confirmation of funds requests do not affect the status of the **payment-agreement-consent** resource.
- In case of a Payment Agreements Consent with multiple Debtor Accounts, the TPP must always specify the Debtor Account(s), against which the Confirmation of funds is requested.

###  PATCH /payment-agreement-consents/{ConsentId}

This endpoint can be used by the TPP to modify the Payment Agreement Consent, partially, i.e. elements of the consent. 

- An ASPSP may request the TPP to get PSU's authorisation for such a change. In such a case:
  - ASPSP must update the payment-agreement-consent status to `AwaitingAuthorisation`, and
  - ASPSP must respond back with HTTP Status 302, indicating to the TPP that a PSU Authentication is required.

This endpoint can be used by the TPP, in case of PSU Revoking the Consent, via TPP's channel.
The TPP can sent the request to only update the Status to be Revoked.

### State Model

#### Payment Agreement Consent

The state model for the payment-agreement-consent resource follows the generic consent state model. However, does not use the Consumed status, as the consent for a payment-agreement is a long-lived consent. Instead, it has a new status - Expired.

!["Payment Agreement Consent Status"](./images/VRP-State-Diagram.png)

The definitions for the Status:

|  | Status |Status Description |
| ---| ------ |------------------ |
| 1 |AwaitingAuthorisation |The consent resource is awaiting PSU authorisation. |
| 2 |Rejected |The consent resource has been rejected. |
| 3 |Authorised |The consent resource has been successfully authorised. |
| 4 |Revoked |The consent resource has been revoked by the PSU, via ASPSP's online channel. |
| 5 |Expired |The consented duration of the Payment Agreement Consent is elapsed, and it cannot be further modified, or reauthenticated by the PSU. |

## Data Model

The data dictionary section gives the detail on the payload content for the Payment Agreement API flows.

### Payment Agreement Consent - Request

The OBWritePaymentAgreementConsent1 object will be used for the call to:

- POST /payment-agreement-consents
  
#### UML Diagram

![OBWritePaymentAgreementConsent1](./images/OBWritePaymentAgreementConsent1.gif)

#### Notes

The payment-agreement-consent **request** contains these objects:

- PaymentAgreement
  - One or more Debtor Accounts
  - Control Parameters
  - Creditor Details
- Risk

#### Data Dictionary

TBC

### Payment Agreement Consent - Response

The OBWritePaymentAgreementConsentResponse1 object will be used for a response to a call to:

- POST /payment-agreement-consents
- GET /payment-agreement-consents/{ConsentId}

#### UML Diagram

![OBWritePaymentAgreementConsentResponse1](./images/OBWritePaymentAgreementConsentResponse1.gif)

#### Notes

Them payment-agreement-consent **response** contains the full **original** payload from the payment-agreement-consent **request**, with the additional elements below:

- ConsentId
- CreationDateTime the payment-agreement-consent resource was created.
- Status and StatusUpdateDateTime of the payment-agreement-consent resource.
- PaymentAgreement played back to the TPP.

#### Data Dictionary

TBC

### Payment Agreement Consent Confirmation of Funds - Request

The OBWritePAFundsConfirmationRequest1 object must be used to request funds availability for a specific amount, across the Debtor Accounts included in the Payment Agreement Consent.
The TPP must specify at least 1 debtor account, and the specified debtor accounts must be from the set of debtor account(s), specified and later authorised by the PSU.

- POST /payment-agreement-consents/{ConsentId}/funds-confirmation

#### UML Diagram

![OBWritePAFundsConfirmationRequest1](./images/OBWritePAFundsConfirmationRequest1.gif)

#### Notes

TBC

#### Data Dictionary 

TBC

### Payment Agreement Consent Confirmation of Funds - Response

The OBWritePAFundsConfirmationResponse1 object will be used for a response to a call to:

- POST /payment-agreement-consents/{ConsentId}/funds-confirmation

#### UML Diagram

![OBWritePAFundsConfirmationResponse1](./images/OBWritePAFundsConfirmationResponse1.gif)

#### Notes

The confirmation of funds response contains the result of a funds availability check.

#### Data Dictionary

TBC

### Payment Agreement Consent Update - Request

The OBWritePAFundsConfirmationRequest1 object must be used to request funds availability for a specific amount, across the Debtor Accounts included in the Payment Agreement Consent.
The TPP must specify at least 1 debtor account, and the specified debtor accounts must be from the set of debtor account(s), specified and later authorised by the PSU.

- POST /payment-agreement-consents/{ConsentId}/funds-confirmation

#### UML Diagram

![OBWritePAFundsConfirmationRequest1](./images/OBWritePAFundsConfirmationRequest1.gif)

#### Notes

TBC

#### Data Dictionary 

TBC

### Payment Agreement Consent Update - Response

The response to the update request could be one of the following HTTP Status codes, no payload is required.

| Http Status Code| Description|
|-- | -- |
|204| No Content, updates applied successfully|
|302| Updates require PSU Authorisation|
|4xx| Validation Errors|

## Usage Examples - TBC

Note, further usage examples are available [here](../../references/usage-examples/README.md).

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
      "CreditorAccounts": {
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
      "CreditorAccounts": {
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
      "CreditorAccounts": {
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
