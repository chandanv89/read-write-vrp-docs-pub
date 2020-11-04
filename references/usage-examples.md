# Usage Examples

## VRP with Debtor Account specified by PISP

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
      "Reference": "my-first-vrp",
      "VRPType": "UK.OBIE.VRPType.Sweeping",
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "MaximumIndividualAmount": {
        "Amount": "100.00",
        "Currency": "GBP"
      },
      "MaximumMonthlyAmount": {
        "Amount": "1000.00",
        "Currency": "GBP"
      },
    },
    "Initiation": {
      "DebtorAccount": {
        "SchemeName": "UK.OBIE.IBAN",
        "Identification": "GB76LOYD30949301273801",
        "Name": "Marcus Sweepimus"
      },
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweepimus"
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
      "Reference": "my-first-vrp",
      "VRPType": "UK.OBIE.VRPType.Sweeping",
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "MaximumIndividualAmount": {
        "Amount": "100.00",
        "Currency": "GBP"
      },
      "MaximumMonthlyAmount": {
        "Amount": "1000.00",
        "Currency": "GBP"
      },
    },
    "Initiation": {
      "DebtorAccount": {
        "SchemeName": "UK.OBIE.IBAN",
        "Identification": "GB76LOYD30949301273801",
        "Name": "Marcus Sweepimus"
      },
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweepimus"
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
    "Status": "Authorised",
    "StatusUpdateDateTime": "2017-06-05T15:15:25+00:00",
    "ControlParameters": {
      "Reference": "my-first-vrp",
      "VRPType": "UK.OBIE.VRPType.Sweeping",
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "MaximumIndividualAmount": {
        "Amount": "100.00",
        "Currency": "GBP"
      },
      "MaximumMonthlyAmount": {
        "Amount": "1000.00",
        "Currency": "GBP"
      },
    },
      "DebtorAccount": {
        "SchemeName": "UK.OBIE.IBAN",
        "Identification": "GB76LOYD30949301273801",
        "Name": "Marcus Sweepimus"
      },
      "Initiation": {
      "DebtorAccount": {
        "SchemeName": "UK.OBIE.IBAN",
        "Identification": "GB76LOYD30949301273801",
        "Name": "Marcus Sweepimus"
      },
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweepimus"
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
        "Name": "Marcus Sweepimus"
      },
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweepimus"
      }
    },
    "Instruction": {
      "EndToEndIdentification": "Circusmaximus",
      "InstructionIdentification": "Overdraftreductus",
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweepimus"
      },
      "InstructedAmount": {
        "Amount": "10.00",
        "Currency": "GBP"
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
    "DomesticVRPId": "96100554-8029-47c8-85b1-7df980ef9ef4",
    "Status": "AwaitingAuthorisation",
    "StatusUpdateDateTime": "2017-06-05T15:15:15+00:00",

    "DebtorAccount": {
      "SchemeName": "UK.OBIE.IBAN",
      "Identification": "GB76LOYD30949301273801",
      "Name": "Marcus Sweepimus"
    },

    "Initiation": {
      "DebtorAccount": {
        "SchemeName": "UK.OBIE.IBAN",
        "Identification": "GB76LOYD30949301273801",
        "Name": "Marcus Sweepimus"
      },
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweepimus"
      }
    },

    "Instruction": {
      "EndToEndIdentification": "Circusmaximus",
      "InstructionIdentification": "Overdraftreductus",
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweepimus"
      },
      "InstructedAmount": {
        "Amount": "10.00",
        "Currency": "GBP"
      }
    },

    "Refund": {
      "SchemeName": "UK.OBIE.IBAN",
      "Identification": "GB76LOYD30949301273801",
      "Name": "Marcus Sweepimus"
    }
  },
  "Risk": {
    "PaymentContextCode": "PartyToParty"
  }
}
```

## VRP with Debtor Account specified during consent authorisation and CreditorAccount specified during payment initiation

In this scenario, the PISP creates a `domestic-vrp-consent` where the debtor account and creditor account are not specified.

The PSU selects the debtor account during consent authorisation.

The PISP specifies the creditor account during payment initiation.

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
      "Reference": "my-first-vrp",
      "VRPType": "UK.OBIE.VRPType.Sweeping",
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "MaximumIndividualAmount": {
        "Amount": "100.00",
        "Currency": "GBP"
      },
      "MaximumMonthlyAmount": {
        "Amount": "1000.00",
        "Currency": "GBP"
      },
    },
    "Initiation": {
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
      "Reference": "my-first-vrp",
      "VRPType": "UK.OBIE.VRPType.Sweeping",
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "MaximumIndividualAmount": {
        "Amount": "100.00",
        "Currency": "GBP"
      },
      "MaximumMonthlyAmount": {
        "Amount": "1000.00",
        "Currency": "GBP"
      },
    },
    "Initiation": {
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

Once the consent has been authorised, the PSU would have selected the debtor account to use for the VRP.
This is returned as part of the GET response.

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
    "Status": "Authorised",
    "StatusUpdateDateTime": "2017-06-05T15:15:25+00:00",

    "ControlParameters": {
      "Reference": "my-first-vrp",
      "VRPType": "UK.OBIE.VRPType.Sweeping",
      "ValidFromDateTime": "2017-06-05T15:15:13+00:00",
      "ValidToDateTime": "2020-06-05T15:15:13+00:00",
      "MaximumIndividualAmount": {
        "Amount": "100.00",
        "Currency": "GBP"
      },
      "MaximumMonthlyAmount": {
        "Amount": "1000.00",
        "Currency": "GBP"
      },
    },

    "DebtorAccount": {
      "SchemeName": "UK.OBIE.IBAN",
      "Identification": "GB76LOYD30949301273801",
      "Name": "Marcus Sweepimus"
    },

    "Initiation": {
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

### POST /domestic-vrps

Finally, when the PISP initiates the payment, it specifies the CreditorAccount to be used.

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
    },

    "Instruction": {
      "EndToEndIdentification": "Circusmaximus",
      "InstructionIdentification": "Overdraftreductus",
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweepimus"
      },
      "InstructedAmount": {
        "Amount": "10.00",
        "Currency": "GBP"
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
    "DomesticVRPId": "96100554-8029-47c8-85b1-7df980ef9ef4",
    "Status": "AwaitingAuthorisation",
    "StatusUpdateDateTime": "2017-06-05T15:15:15+00:00",

    "DebtorAccount": {
      "SchemeName": "UK.OBIE.IBAN",
      "Identification": "GB76LOYD30949301273801",
      "Name": "Marcus Sweepimus"
    },

    "Initiation": {
    },

    "Instruction": {
      "EndToEndIdentification": "Circusmaximus",
      "InstructionIdentification": "Overdraftreductus",
      "CreditorAccount": {
        "SchemeName": "SortCodeAccountNumber",
        "Identification": "30949330000010",
        "SecondaryIdentification": "Roll 90210",
        "Name": "Marcus Sweepimus"
      },
      "InstructedAmount": {
        "Amount": "10.00",
        "Currency": "GBP"
      }
    },

    "Refund": {
      "SchemeName": "UK.OBIE.IBAN",
      "Identification": "GB76LOYD30949301273801",
      "Name": "Marcus Sweepimus"
    }
  },
  "Risk": {
    "PaymentContextCode": "PartyToParty"
  }
}
```
