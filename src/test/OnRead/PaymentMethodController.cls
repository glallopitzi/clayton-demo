public with sharing class PaymentMethodController {

    @AuraEnabled
    public static PaymentMethod__c createPaymentMethod(Id paymentId) {
        PaymentMethod__c currentContact = [SELECT * FROM PaymentMethod__c where Id = :paymentId];
        return currentContact;
    }
}