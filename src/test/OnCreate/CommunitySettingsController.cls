public with sharing class CommunitySettingsController {

    @AuraEnabled
    public static void createSettings() {
        CommunitySettings__c prefs = CommunitySettings__c.getInstance();
        prefs.DefaultTripStartLocation__c = 'Test';
        upsert prefs;
    }
}