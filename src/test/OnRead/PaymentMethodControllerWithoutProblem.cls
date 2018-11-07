public with sharing class PaymentMethodController {

    @AuraEnabled
    public static PaymentMethod__c createPaymentMethod(Id paymentId) {

        fflib_SecurityUtils.checkObjectIsReadable(PaymentMethod__c.SObjectType);

        PaymentMethod__c currentContact = [SELECT PaymentMethod__c FROM PaymentMethod__c where Id = :paymentId];
        return currentContact;
    }
}