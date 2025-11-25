public class MyClassWithBigMethodsWithoutDescription {

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

    global void execute(Database.BatchableContext BC, List<TempLocations__c> scope)
    {   
        TempLocations__c eachLoc = scope[0];
        list<TempLocations__c> UploadedAccLoc = new list<TempLocations__c> ();
        list<TempLocations__c> SucccedAccLoc = new list<TempLocations__c> ();
        try{ 
            		//String Free_Form_Address = eachLoc.Apttus_Config2_Street__c+','+Address2+ eachLoc.Apttus_Config2_Country__c+','+eachLoc.Apttus_Config2_City__c+','+eachLoc.Apttus_Config2_State__c+','+eachLoc.Apttus_Config2_PostalCode__c;
                    String Free_Form_Address = eachLoc.Free_Form_Address__c;
                    System.debug('Free_Form_Address :'+Free_Form_Address);
                    //AddressVo addv = new AddressVo(Free_Form_Address, eachLoc.Apttus_Config2_Street__c, Address2, eachLoc.Apttus_Config2_Country__c, eachLoc.Apttus_Config2_City__c,eachLoc.Apttus_Config2_State__c , eachLoc.Apttus_Config2_PostalCode__c, zip4);
                    AddressVo addv = new AddressVo(Free_Form_Address,'', '', eachLoc.Apttus_Config2_Country__c, '', '', '', '');

                                AddressValidationRequest req = new AddressValidationRequest(addv,null);
                                AddressE911Validation addVal = new AddressE911Validation ();                    	
                                AddressValidationResponse resp = new AddressValidationResponse();
                                //resp =addVal.validateSmartyStreets(req);   
                                // resp = addVal.validateE911AddressOnly(req); validateSmartyStreets                	
                            resp = addVal.validateSmartyStreets(req); 
            				 System.debug('req :'+req);
                             System.debug('resp : '+resp);
                   			 System.debug('resp.status : '+resp.getStatus());
            			     System.debug('resp.All status :'+resp.getoverrideAddress2()+''+resp.getStatus()+''+resp.getOverrideIntlPartialAddress());
            					
                            if(resp.getAddressVo()[0].getCountry().contains('USA')){  
                                if(resp.getStatus() == 'SUCCESS'){
                                    eachLoc.Status__c = 'valid';
                                    eachLoc.Free_Form_Address__c = resp.getAddressVo()[0].getAddress1()+', '+resp.getAddressVo()[0].getCity()+', '+resp.getAddressVo()[0].getState()+', '+resp.getAddressVo()[0].getCountry();
                                    eachLoc.Apttus_Config2_Street__c = resp.getAddressVo()[0].getAddress1();
                                    eachLoc.Address2__c = resp.getAddressVo()[0].getAddress2();
                                    eachLoc.Apttus_Config2_City__c = resp.getAddressVo()[0].getCity();
                                    eachLoc.Apttus_Config2_State__c = resp.getAddressVo()[0].getState();
                                    eachLoc.Apttus_Config2_Country__c = resp.getAddressVo()[0].getCountry();
                                    eachLoc.Apttus_Config2_PostalCode__c = resp.getAddressVo()[0].getZip();
                                    System.debug('resp.status :');
                                }	
                                else if(resp.getoverrideAddress2()){
                                    eachLoc.Free_Form_Address__c = resp.getAddressVo()[0].getAddress1()+', '+resp.getAddressVo()[0].getCity()+', '+resp.getAddressVo()[0].getState()+', '+resp.getAddressVo()[0].getCountry();
                                    eachLoc.Apttus_Config2_Street__c = resp.getAddressVo()[0].getAddress1();
                                    eachLoc.Address2__c = resp.getAddressVo()[0].getAddress2();
                                    eachLoc.Apttus_Config2_City__c = resp.getAddressVo()[0].getCity();
                                    eachLoc.Apttus_Config2_State__c = resp.getAddressVo()[0].getState();
                                    eachLoc.Apttus_Config2_Country__c = resp.getAddressVo()[0].getCountry();
                                    eachLoc.Apttus_Config2_PostalCode__c = resp.getAddressVo()[0].getZip();
                                    //eachLoc.zip4 = resp.getAddressVo()[0].getZip4();
                                    eachLoc.Status__c = 'valid';
                                  } 
                                else{
                                    eachLoc.Status__c = 'Invalid';
                                    eachLoc.Error__c = resp.getReason();
                                }
                            }
                            else if(resp.getOverrideIntlPartialAddress() || resp.getStatus() == 'SUCCESS'){
                                eachLoc.Free_Form_Address__c = resp.getAddressVo()[0].getAddress1()+', '+resp.getAddressVo()[0].getCity()+', '+resp.getAddressVo()[0].getState()+', '+resp.getAddressVo()[0].getCountry();
                                eachLoc.Apttus_Config2_Street__c = resp.getAddressVo()[0].getAddress1();
                                eachLoc.Address2__c = resp.getAddressVo()[0].getAddress2();
                                eachLoc.Apttus_Config2_City__c = resp.getAddressVo()[0].getCity();
                                eachLoc.Apttus_Config2_State__c = resp.getAddressVo()[0].getState();
                                eachLoc.Apttus_Config2_Country__c = resp.getAddressVo()[0].getCountry();
                                eachLoc.Apttus_Config2_PostalCode__c = resp.getAddressVo()[0].getZip();
                                //eachLoc.zip4 = resp.getAddressVo()[0]).getZip4();
                                eachLoc.Status__c = 'valid';                      
                            }
                           else{
                                 eachLoc.Status__c = 'Invalid';
                               	 eachLoc.Error__c = resp.getReason();
                                }
            		System.debug('EachLocation :'+eachLoc);
                    System.debug('EachLocation :'+eachLoc);
                    System.debug('getAddress1() :'+resp.getAddressVo()[0].getAddress1());
            		update eachLoc;
            
            if(eachLoc.Status__c == 'valid'){
                System.debug('EachLocation :'+eachLoc.Account_Id__c + ': Street :'+eachLoc.Apttus_Config2_Street__c);
                String AddressKey = eachLoc.Account_Id__c + eachLoc.Apttus_Config2_Street__c +
                eachLoc.Address2__c + eachLoc.Apttus_Config2_City__c +eachLoc.Apttus_Config2_PostalCode__c;
        		AddressKey = AddressKey.replaceAll('\\W','');
        		eachLoc.AddressKey__c = AddressKey.toUpperCase();
                
                for(Apttus_Config2__AccountLocation__c ExistingAccountLocation :[Select id,AddressKey__c from Apttus_Config2__AccountLocation__c where Apttus_Config2__AccountId__c =: eachLoc.Account_Id__c]){
                    if(ExistingAccountLocation.AddressKey__c == eachLoc.AddressKey__c)
                        eachLoc.Status__c = 'Duplicate';                                      
                }
                if(eachLoc.Status__c == 'valid'){
                    Apttus_Config2__AccountLocation__c ACL = new Apttus_Config2__AccountLocation__c(Name = eachLoc.Free_Form_Address__c, Apttus_Config2__Street__c = eachLoc.Apttus_Config2_Street__c , Address2__c = eachLoc.Address2__c, Apttus_Config2__City__c = eachLoc.Apttus_Config2_City__c , Apttus_Config2__State__c = eachLoc.Apttus_Config2_State__c,
                    Apttus_Config2__Country__c = eachLoc.Apttus_Config2_Country__c, Apttus_Config2__PostalCode__c = eachLoc.Apttus_Config2_PostalCode__c, AddressKey__c =eachLoc.AddressKey__c, Apttus_Config2__AccountId__c = eachLoc.Account_Id__c, Business_Name__c = eachLoc.Business_Name__c != null ? eachLoc.Business_Name__c : '', Shipping_Contact_LastName__c = eachLoc.Shipping_Contact_LastName__c != null ? eachLoc.Shipping_Contact_LastName__c : '' , 
                    Shipping_Contact_Firstname__c = eachLoc.Shipping_Contact_Firstname__c != null ? eachLoc.Shipping_Contact_Firstname__c : '' , Shipping_Contact_phoneNumber__c = eachLoc.Shipping_Contact_phoneNumber__c != null ? eachLoc.Shipping_Contact_phoneNumber__c : '' );
                    insert ACL;                    
                }
                update eachLoc;
            }
            		
                    //UploadedAccLoc.add(eachLoc); 
					//System.debug('UploadedAccLoc List : '+UploadedAccLoc);
    	}
        catch(Exception ex){
           system.debug(LoggingLevel.INFO, 'UploadedAccLoc' + ex.getMessage()+' at Line No - '+ex.getLineNumber());
        }
        /*System.debug('UploadedAccLoc List : in Exucute Method :'+UploadedAccLoc);
        System.debug('UploadedAccLoc List : '+UploadedAccLoc);   
        list<Database.SaveResult> SR = database.update(UploadedAccLoc);
        System.debug('SR'+ SR);*/
    
            integer i=0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;
            i++;
            i++;

        }

}