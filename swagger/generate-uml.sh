#!/usr/bin/env bash

# generates all the specified diagrams, and moves them to the resources-and-data-models/images directory
# missing objects are logged
#
# requires the generateob tool to be installed:
# git clone git@bitbucket.org:openbankingteam/uml-generator.git
# cd uml-generator/class/cmd/generateob
# go install

./generate.sh ./vrp-swagger.yaml \
	components.schemas.OBCashAccountDebtorWithName \
	components.schemas.OBCashAccountCreditor3 \
	components.schemas.OBBranchAndFinancialInstitutionIdentification6 \
	components.schemas.OBDomesticVRPInitiation \
	components.schemas.OBDomesticVRPControlParameters \
	components.schemas.OBRisk1 \
	components.schemas.OBDomesticVRPConsentRequest \
	components.schemas.OBDomesticVRPConsentResponse \
	components.schemas.OBDomesticVRPInstruction \
	components.schemas.OBDomesticVRPRequest \
	components.schemas.OBDomesticVRPResponse \
	components.schemas.OBDomesticVRPDetails \
	components.schemas.OBVRPFundsConfirmationRequest \
	components.schemas.OBVRPFundsConfirmationResponse

mv *.svg ../resources-and-data-models/images