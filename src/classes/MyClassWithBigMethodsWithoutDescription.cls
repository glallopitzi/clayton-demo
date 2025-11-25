public class MyClassWithBigMethodsWithoutDescription {

    /* Update Address Validation Status */
    public Address__c updateAddressValidationStatus(Address__c addressRec, AddressResponseWrapper parsedResponse) {
		String summarizedRes = null;
		String summarizedResData = null;
		String streetnumber = null;
		if (parsedResponse != null && parsedResponse.result != null && parsedResponse.result.summaryData != null && parsedResponse.result.summaryData.summarizedresult != null) {
        	summarizedRes = parsedResponse.result.summaryData.summarizedresult;
		}else if(parsedResponse != null && parsedResponse.error != null){
			addressRec.Validation_Status__c = AddressConstant.ADDRESS_STATUS_ERROR;
			addressRec.Validated_Date__c = System.now();
			addressRec.Validated_By__c = UserInfo.getUserId();
			addressRec.Address_Validator_Response__c = parsedResponse.error.message;
		}
        if (summarizedRes != null) {
			if (!summarizedRes.contains('UNCONFIRMED') ) {
                //AddressResponse parsedResponse = (AddressResponse) JSON.deserialize(result, AddressResponse.class);
                if (parsedResponse == null || parsedResponse.result == null || (parsedResponse.result.uspsData == null  && parsedResponse.result.address == null)) {
                    addressRec.Validation_Status__c = AddressConstant.ADDRESS_STATUS_INVALID;
                }
                else{
					AddressResponseWrapper.StandardizedAddress standardized = new AddressResponseWrapper.StandardizedAddress();
					if(parsedResponse.result.uspsData != null && parsedResponse.result.uspsData.standardizedAddress != null){
						standardized = parsedResponse.result.uspsData.standardizedAddress;
					}else if(parsedResponse.result.address != null && parsedResponse.result.address.postalAddress != null){
						//standardized = parsedResponse.result.address.postalAddress;
						if(parsedResponse.result.address.postalAddress.locality != null){
							standardized.City = parsedResponse.result.address.postalAddress.locality;
						}
						if(parsedResponse.result.address.postalAddress.administrativeArea != null){
							standardized.State = parsedResponse.result.address.postalAddress.administrativeArea;
						}
						if(parsedResponse.result.address.postalAddress.postalCode != null){
							standardized.ZipCode = parsedResponse.result.address.postalAddress.postalCode;
						}
						if(parsedResponse.result.address.postalAddress.addressLines != null){
							standardized.firstAddressLine = parsedResponse.result.address.postalAddress.addressLines[0];
						}
					}
					if (parsedResponse != null && parsedResponse.result != null && parsedResponse.result.summaryData != null && parsedResponse.result.summaryData.summarizedresultdata != null) {
        				summarizedResData = parsedResponse.result.summaryData.summarizedresultdata;
						Map<String, Object> summarizedMap = (Map<String, Object>) JSON.deserializeUntyped(summarizedResData);
						if (summarizedMap.containsKey('addressSummary')) {
							Map<String, Object> addressSummary = (Map<String, Object>) summarizedMap.get('addressSummary');
							if (addressSummary.containsKey('street_number') && addressSummary.containsKey('route')) {
								// Combine street_number and route if both exist
								streetnumber = (String) addressSummary.get('street_number') + ' ' + (String) addressSummary.get('route');
							} else if (addressSummary.containsKey('street_number')) {
								// Use only street_number if route is not present
								streetnumber = (String) addressSummary.get('street_number');
							} else if (addressSummary.containsKey('route')) {
								// Use only route if street_number is not present
								streetnumber = (String) addressSummary.get('route');
							}
						}
					}
				
                    String summarizedresult = '';
					if (addressRec.Street__c != null && standardized.firstAddressLine!=null && !standardized.firstAddressLine.trim().equalsIgnoreCase(addressRec.Street__c.trim()) && (streetnumber == null  || ( streetnumber != null && !streetnumber.equalsIgnoreCase(addressRec.Street__c.trim()) ))){
                        summarizedresult += 'Street mismatch: Standardized "' + standardized.firstAddressLine + '", Record "' + addressRec.Street__c + '". ';
                    }
                    if (((addressRec.City__c != null && standardized.city != null) || 
                        (addressRec.City__c == null && standardized.city != null) || 
                        (addressRec.City__c != null && standardized.city == null)) && 
                        (standardized.city == null || addressRec.City__c == null || !standardized.city.equalsIgnoreCase(addressRec.City__c))) {
                        summarizedresult += 'City mismatch: Standardized "' + (standardized.city != null ? standardized.city : '') + '", Record "' + (addressRec.City__c != null ? addressRec.City__c : '') + '". ';
                    }
					if ((addressRec.State__c != null && standardized.state == null) ||
                        (addressRec.State__c == null && standardized.state != null) || (addressRec.State__c != null && standardized.state != null  && !standardized.state.equalsIgnoreCase(getStateCode(addressRec.State__c)) && !standardized.state.equalsIgnoreCase(addressRec.State__c))) {
                        summarizedresult += 'State mismatch: Standardized "' + standardized.state + '", Record "' + getStateCode(addressRec.State__c) + '". ';
                    }
					if ((addressRec.Zip_Postal_Code__c != null && standardized.zipCode != null) && !standardized.zipCode.equalsIgnoreCase(addressRec.Zip_Postal_Code__c)
													&& (standardized.extendedZipCode == null || (standardized.extendedZipCode != null && !(standardized.zipCode+'-'+standardized.extendedZipCode).equalsIgnoreCase(addressRec.Zip_Postal_Code__c)))) {
                        summarizedresult += 'Zip Code mismatch: Standardized "' + standardized.zipCode + '", Extended "' + standardized.extendedZipCode + '", Record "' + addressRec.Zip_Postal_Code__c + '". ';
                    }
                    if(summarizedresult != null && summarizedresult != ''){
                        addressRec.Validation_Status__c = AddressConstant.ADDRESS_STATUS_INVALID;
                    }else if(summarizedresult == null || summarizedresult == ''){
                        addressRec.Validation_Status__c = AddressConstant.ADDRESS_STATUS_VALID;
                    }
                    addressRec.Address_Validator_Response__c = summarizedresult != null && summarizedresult != '' ? summarizedresult : summarizedRes;
                    addressRec.Validated_Date__c = System.now();
                    addressRec.Validated_By__c = UserInfo.getUserId();
                }
            } else {
                addressRec.Validation_Status__c = AddressConstant.ADDRESS_STATUS_INVALID;
                addressRec.Validated_Date__c = System.now();
            	addressRec.Validated_By__c = UserInfo.getUserId();
                addressRec.Address_Validator_Response__c = summarizedRes;
            }
        }
		return addressRec;
	}

}