public inherited sharing class MyController {
    @AuraEnabled
    public static Contact getContact(Id contactId) {
        Contact currentContact = [SELECT Name, Salary__c, NextAvailableDate__c FROM Contact where Id = :contactId];
        return currentContact;
    }
    
}