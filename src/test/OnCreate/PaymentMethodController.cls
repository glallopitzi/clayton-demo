public with sharing class PaymentMethodController {

    @AuraEnabled
    public static Id createPaymentMethod(PaymentMethod__c paymentMethod) {
        Savepoint sp;
        try {
            sp = Database.setSavepoint();
            fflib_SecurityUtils.checkObjectIsInsertable(PaymentMethod__c.SObjectType);

            for(String fieldName : paymentMethod.getPopulatedFieldsAsMap().keySet()) {
                fflib_SecurityUtils.checkFieldIsInsertable(PaymentMethod__c.SObjectType, fieldName);
            }

            insert paymentMethod;

            return paymentMethod.Id;
        }
        catch(Exception e) {
            if(sp != null) {
                Database.rollback(sp);
            }
            throw ErrorHandling.getAuraException('Unable to save payment method');
        }
    }
}