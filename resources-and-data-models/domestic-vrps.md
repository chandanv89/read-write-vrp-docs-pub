# Domestic VRPS - v1.0.0-draft1 <!-- omit in toc -->

<!-- start-toc -->
- [Overview](#overview)
- [Endpoints](#endpoints)
  - [POST /domestic-vrps](#post-domestic-vrps)
    - [Status](#status)
  - [GET /domestic-vrps/{DomesticVRPId}](#get-domestic-vrpsdomesticvrpid)
  - [GET /domestic-vrps/{DomesticVRPId}/payment-details](#get-domestic-vrpsdomesticvrpidpayment-details)
- [State Model](#state-model)
  - [Payment Order](#payment-order)
- [Data Model](#data-model)
  - [OBDomesticVRPInstruction](#obdomesticvrpinstruction)
    - [Data Dictionary](#data-dictionary)
  - [OBDomesticVRPRequest](#obdomesticvrprequest)
    - [Data Dictionary](#data-dictionary-1)
  - [OBDomesticVRPResponse](#obdomesticvrpresponse)
  - [OBDomesticVRPDetails](#obdomesticvrpdetails)
    - [UML Diagram](#uml-diagram)
- [Usage Examples](#usage-examples)
  - [POST /domestic-vrps](#post-domestic-vrps-1)
    - [Request](#request)
    - [Response](#response)
<!-- end-toc -->

## Overview

The Domestic VRPs resource is used by a TPP to initiate a domestic payment, under an authorised VRP Consent.

This resource description should be read in conjunction with a compatible Payment Initiation API Profile.

## Endpoints

| Resource |HTTP Operation |Endpoint |Mandatory |Scope |Grant Type |Message Signing |Idempotency Key |Request Object |Response Object |
| -------- |-------------- |-------- |----------- |----- |---------- |--------------- |--------------- |-------------- |--------------- |
| domestic-vrps |POST |POST /domestic-vrps | Conditional |vrp-consents:sweeping, vrp-consents:other |Authorization Code |Signed Request Signed Response |Yes | OBDomesticVRPRequest |OBDomesticVRPResponse |
| domestic-vrps |GET |GET /domestic-vrps/{DomesticVRPId} | Conditional |vrp-consents:sweeping, vrp-consents:other |Client Credentials |Signed Response |No |NA |OBDomesticVRPResponse |
| domestic-vrps |GET |GET /domestic-vrps/{DomesticVRPId}/payment-details | Optional |vrp-consents:sweeping, vrp-consents:other |Client Credentials |Signed Response |No |NA |OBDomesticVRPRequestDetailResponse |

### POST /domestic-vrps

Once a `domestic-vrp-consents` has been authorised by the PSU, the TPP can proceed to submitting a `domestic-vrps` for processing.

This is done by making a POST request to the `domestic-vrps` endpoint.

This request is an instruction to the ASPSP to begin the domestic single immediate payment journey. The domestic payment must be executed immediately, however, there are some scenarios where the domestic payment may not be executed immediately (e.g., busy periods at the ASPSP).

The TPP **must** ensure that the `Initiation` and `Risk` section matches the values specified in the consent.

If the `CreditorAccount` was not specified in the the consent, the `CreditorAccount` must be specified in the instruction.

The TPP **must** ensure that the end-point is called with the same scope as the one used for the corresponding consent.

#### Status

A `domestic-vrps` can only be created if its corresponding `domestic-vrp-consents` resource has the status of `Authorised`.

The `domestic-vrps` resource that is created successfully must have one of the following `PaymentStatusCode` values

- Pending
- Rejected
- AcceptedSettlementInProcess
- AcceptedSettlementCompleted
- AcceptedWithoutPosting
- AcceptedCreditSettlementCompleted

### GET /domestic-vrps/{DomesticVRPId}

Once the domestic vrp is created, a TPP can retrieve the `domestic-vrps` to check its status by using this endpoint.

The domestic-vrp resource must have one of the following PaymentStatusCode code-set enumerations:

- Pending
- Rejected
- AcceptedSettlementInProcess
- AcceptedSettlementCompleted
- AcceptedWithoutPosting
- AcceptedCreditSettlementCompleted

### GET /domestic-vrps/{DomesticVRPId}/payment-details

A TPP can retrieve the details of the underlying payment transaction via this endpoint. This resource allows ASPSPs to return a richer list of Payment Statuses, and if available payment scheme related statuses.

The API must return one of the following status codes:

- Accepted
- AcceptedCancellationRequest
- AcceptedTechnicalValidation
- AcceptedCustomerProfile
- AcceptedFundsChecked
- AcceptedWithChange
- Pending
- Rejected
- AcceptedSettlementInProcess
- AcceptedSettlementCompleted
- AcceptedWithoutPosting
- AcceptedCreditSettlementCompleted
- Cancelled
- NoCancellationProcess
- PartiallyAcceptedCancellationRequest
- PartiallyAcceptedTechnicalCorrect
- PaymentCancelled
- PendingCancellationRequest
- Received
- RejectedCancellationRequest

## State Model

### Payment Order

The state model for the `domestic-vrps` resource follows the behaviour and definitions for the ISO 20022 PaymentStatusCode code-set.

![Domestic VRP Status](./images/PaymentStatusLifeCycle.png)

The definitions for the status:
|  |Status |Payment Status Description |
|--|------ |-------------------------- |
| 1 |Pending |Payment initiation or individual transaction included in the payment initiation is pending. Further checks and status update will be performed. |
| 2 |Rejected |Payment initiation or individual transaction included in the payment initiation has been rejected. |
| 3 |AcceptedSettlementInProcess |All preceding checks such as technical validation and customer profile were successful and therefore the payment initiation has been accepted for execution. |
| 4 |AcceptedSettlementCompleted |Settlement on the debtor's account has been completed. |
| 5 |AcceptedWithoutPosting |Payment instruction included in the credit transfer is accepted without being posted to the creditor customer’s account. |
| 6 |AcceptedCreditSettlementCompleted |Settlement on the creditor's account has been completed.|

## Data Model

### OBDomesticVRPInstruction

![OBDomesticVRPInstruction](./images/OBDomesticVRPInstruction.gif)

#### Data Dictionary

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __InstructionIdentification__ (1..1) | `Initiation. InstructionIdentification` |Unique identification as assigned by an instructing party for an instructed party to unambiguously identify the instruction. Usage: the instruction identification is a point to point reference that can be used between the instructing party and the instructed party to refer to the individual instruction. It can be included in several messages related to the instruction. |Max35Text
| __EndToEndIdentification__ (1..1) | `EndToEndIdentification` |Unique identification assigned by the initiating party to unambiguously identify the transaction. This identification is passed on, unchanged, throughout the entire end-to-end chain. Usage: The end-to-end identification can be used for reconciliation or to link tasks relating to the transaction. It can be included in several messages related to the transaction. OB: The Faster Payments Scheme can only access 31 characters for the EndToEndIdentification field. |Max35Text
| __LocalInstrument__ (0..1) | `LocalInstrument` |User community specific instrument. Usage: This element is used to specify a local instrument, local clearing option and/or further qualify the service or service level. |OBExternalLocalInstrument1Code
| __InstructedAmount__ (1..1) | `InstructedAmount` |Amount of money to be moved between the debtor and creditor, before deduction of charges, expressed in the currency as ordered by the initiating party. Usage: This amount has to be transported unchanged through the transaction chain. | OBActiveOrHistoricCurrencyAndAmount
| __Amount__ (1..1) |`InstructedAmount. Amount` |A number of monetary units specified in an active currency where the unit of currency is explicit and compliant with ISO 4217. |OBActiveCurrencyAndAmount_SimpleType | `^\d{1,13}$\|^\d{1,13}\.\d{1,5}$`
| __Currency__ (1..1) | `InstructedAmount. Currency` |A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds". |ActiveOrHistoricCurrencyCode | `^[A-Z]{3,3}$`
| __CreditorAgent__ (0..1) | `CreditorAgent` | Financial institution servicing an account for the creditor.     | OBBranchAndFinancialInstitutionIdentification6
| __CreditorAccount__ (0..1) | `CreditorAccount`   |Unambiguous identification of the account of the creditor to which a credit entry will be posted as a result of the payment transaction.       |OBCashAccountCreditor3

### OBDomesticVRPRequest

![OBDomesticVRPRequest](./images/OBDomesticVRPRequest.gif)

#### Data Dictionary

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __Data__ (1..1) | `Data`
| __ConsentId__ (1..1) | `Data. ConsentId` | Identifier for the Domestic VRP Consent that this payment is made under | Max128Text|
| __Initiation__ (1..1) | `Data. Initiation` | The parameters of the VRP consent that should remain unchanged for each payment under this VRP. | OBDomesticVRPInitiation
| __Instruction__ (1..1) | `Data. Instruction` | Specific instructions for this particular payment within the VRP consent | [OBDomesticVRPInstruction](#OBDomesticVRPInstruction)
| __Risk__ (1..1) | `Risk` | The risk block for this payment. This must match the risk block for the corresponding Domestic VRP consent. | OBRisk1

### OBDomesticVRPResponse

![OBWriteDomesticResponse5](./images/OBWriteDomesticResponse5.gif)

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __Data__ (1..1) | `Data`
| __DomesticVRPId__ (1..1) | `Data. DomesticVRPId` |OB: Unique identification as assigned by the ASPSP to uniquely identify the domestic payment resource. |Max40Text
| __ConsentId__ (1..1) | `Data. ConsentId` | Identifier for the Domestic VRP Consent that this payment is made under | Max128Text
| __CreationDateTime__ (1..1) | `Data. CreationDateTime` |Date and time at which the message was created. |ISODateTime
| __Status__ (1..1) | `Data. Status` |Specifies the status of the payment information group. | AcceptedCreditSettlementCompleted AcceptedWithoutPosting AcceptedSettlementCompleted AcceptedSettlementInProcess Pending Rejected
| __StatusUpdateDateTime__ (1..1) | `Data. StatusUpdateDateTime` |Date and time at which the resource status was updated. |ISODateTime
| __ExpectedExecutionDateTime__ (0..1) | `Data. ExpectedExecutionDateTime` |Expected execution date and time for the payment resource. |ISODateTime
| __ExpectedSettlementDateTime__ (0..1) | `Data. ExpectedSettlementDateTime` |Expected settlement date and time for the payment resource. |ISODateTime
| __Refund__ (1..1) | `Data. Refund` | Unambiguous identification of the refund account to which a refund will be made as a result of the transaction. | OBDomesticRefundAccount1
| __Charges__ (0..n) | `Data. Charges` |Set of elements used to provide details of a charge for the payment initiation. | OBCharge2
| __Initiation__ (1..1) | `Data. Initiation` | The parameters of the VRP consent that should remain unchanged for each payment under this VRP. | OBDomesticVRPInitiation
| __Instruction__ (1..1) | `Data. Instruction` | Specific instructions for this particular payment within the VRP consent | OBDomesticVRPInstruction
| __MultiAuthorisation__ (0..1) | `Data. MultiAuthorisation` |The multiple authorisation flow response from the ASPSP. |OBMultiAuthorisation1|
| __DebtorAccount__ (1..1) | `Data.DebtorAccount` | The approved DebtorAccount that the payment was made from. | OBCashAccountDebtorWithName

### OBDomesticVRPDetails

#### UML Diagram

![OBDomesticVRPDetails](./images/OBWritePaymentDetailsResponse1.png)

| Name |Path |Definition | Type |
| ---- |-----|---------- |------|
| __Data__ (1..1) | `Data`
| __PaymentStatus__ (0..*) | `Data. PaymentStatus`
| __PaymentTransactionId__ (1..1) | `Data. PaymentStatus. PaymentTransactionId` |Unique identifier for the transaction within an servicing institution. This identifier is both unique and immutable. |Max210Text|
| __Status__ (1..1) | `Data. PaymentStatus. Status` |Status of a transfer, as assigned by the transaction administrator. |Accepted AcceptedCancellationRequest AcceptedCreditSettlementCompleted AcceptedCustomerProfile AcceptedFundsChecked AcceptedSettlementCompleted AcceptedSettlementInProcess AcceptedTechnicalValidation AcceptedWithChange AcceptedWithoutPosting Cancelled NoCancellationProcess PartiallyAcceptedCancellationRequest PartiallyAcceptedTechnicalCorrect PaymentCancelled Pending PendingCancellationRequest Received Rejected RejectedCancellationRequest
| __StatusUpdateDateTime__ (1..1) | `Data. PaymentStatus. StatusUpdateDateTime` |Date and time at which the status was assigned to the transfer. |ISODateTime
| __StatusDetail__ (0..1) | `Data. PaymentStatus. StatusDetail` |Payment status details as per underlying Payment Rail.
| __LocalInstrument__ (0..1) | `Data. PaymentStatus. StatusDetail. LocalInstrument` |User community specific instrument.  Usage: This element is used to specify a local instrument, local clearing option and/or further qualify the service or service level. |OBExternalLocalInstrument1Code|
| __Status__ (1..1) | `Data. PaymentStatus. StatusDetail. Status` |Status of a transfer, as assigned by the transaction administrator. |Max128Text|
| __StatusReason__ (0..1) | `Data. PaymentStatus. StatusDetail. StatusReason` |Reason Code provided for the status of a transfer. |Cancelled PendingFailingSettlement PendingSettlement Proprietary ProprietaryRejection Suspended Unmatched|
| __StatusReasonDescription__ (0..1) | `Data. PaymentStatus. StatusDetail. StatusReasonDescription` |Reason provided for the status of a transfer. |Max256Text

## Usage Examples

A valid Domestic VRP Consent in Authorised state is required to create a Domestic VRP.

### POST /domestic-vrps

#### Request

```json
POST /domestic-vrps HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIhTyU5cCI6IkpXVCJ9
x-idempotency-key: FRESNO.1317.GFX.22
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
    "ConsentId": "fe615446-e53a-45ed-954c-ae5d1f97a93b",
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
    "Instruction": {
      "InstructionIdentification": "ACME412",
      "EndToEndIdentification": "FRESCO.21302.GFX.20",
      "InstructedAmount": {
        "Amount": "100.88",
        "Currency": "GBP"
      },
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
    "DomesticVRPId": "b7b60064-1440-11eb-adc1-0242ac120002",
    "ConsentId": "fe615446-e53a-45ed-954c-ae5d1f97a93b",
    "Status":"AcceptedSettlementInProcess",
    "CreationDateTime":"2017-06-05T15:15:22+00:00",
    "StatusUpdateDateTime":"2017-06-05T15:15:22+00:00",
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
    "Instruction": {
      "InstructionIdentification": "ACME412",
      "EndToEndIdentification": "FRESCO.21302.GFX.20",
      "InstructedAmount": {
        "Amount": "100.88",
        "Currency": "GBP"
      },
    },
    "DebtorAccount": {
      "SchemeName": "UK.OBIE.IBAN",
      "Identification": "GB76LOYD30949301273801",
      "Name": "Marcus Sweeptum"
    },
    "Refund": {
      "SchemeName": "UK.OBIE.IBAN",
      "Identification": "GB76LOYD30949301273801",
      "Name": "Marcus Sweeptum"
    }
  },
  "Risk": {
    "PaymentContextCode": "PartyToParty"
  },
  "Links": {
    "Self": "https://api.alphabank.com/open-banking/v1.0/vrp/domestic-vrps/58923-001"
  },
  "Meta": {}
}
```
