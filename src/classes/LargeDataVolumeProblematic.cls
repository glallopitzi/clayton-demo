public with sharing class LargeDataVolumeProblematic {

	public void customObjectWithComposedParameterFilter(String aParam, String anotherParam) {
        System.debug([SELECT Address_Type__c
        FROM Address__c
        WHERE Default_Address__c = :aParam OR Default_Address__c = :anotherParam]);
    }
}