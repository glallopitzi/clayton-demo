@isTest
public class PropertyControllerTest {
    
    @IsTest static void testgetPropertyList() {
        Boolean success = true;
        try {
            Property__c p = new Property__c(Location__Latitude__s=-71.110448,Location__Longitude__s=42.360642);
            insert p;
	        PropertyController.getPropertyList('', 0, 1000000, 0, 0, '');
        } catch (Exception e) {
            success = false;
        } finally {
	        System.assert(success, 'Assert that the test was successful.');
        }
    }

    

    @IsTest static void testgetPropertyListPage() {
        Boolean success = true;
        try {
            Property__c p = new Property__c(Location__Latitude__s=-71.110448,Location__Longitude__s=42.360642);
            insert p;
	        PropertyListPage page = PropertyController.getPropertyListPage('', 0, 1000000, 0, 0, '', 8, 1);
        } catch (Exception e) {
            success = false;
        } finally {
	        System.assert(success, 'Assert that the test was successful.');
        }
    }

    @IsTest static void testFindById() {
        Boolean success = true;
        try {
            Property__c p = new Property__c(Location__Latitude__s=-71.110448,Location__Longitude__s=42.360642);
            insert p;
	        Property__c property = PropertyController.findById(p.Id);
        } catch (Exception e) {
            success = false;
        } finally {
	        System.assert(success, 'Assert that the test was successful.');
        }
    }

    @IsTest static void getAvailableProperties() {
        Boolean success = true;
        try {
            Property__c p = new Property__c(Location__Latitude__s=-71.110448,Location__Longitude__s=42.360642);
            insert p;
	        Property__c[] r = PropertyController.getAvailableProperties();
        } catch (Exception e) {
            success = false;
        } finally {
	        System.assert(success, 'Assert that the test was successful.');
        }
    }

    @IsTest static void getSimilarProperties() {
        Boolean success = true;
        try {
            Property__c p = new Property__c(Location__Latitude__s=-71.110448,Location__Longitude__s=42.360642);
            insert p;
	        Property__c[] r = PropertyController.getSimilarProperties(p.Id, 3, 500000, 'Bedrooms');
        } catch (Exception e) {
            success = false;
        } finally {
	        System.assert(success, 'Assert that the test was successful.');
        }
    }

}