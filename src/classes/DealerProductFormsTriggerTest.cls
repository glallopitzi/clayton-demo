@isTest
private class DealerProductFormsTriggerTest {

    @testSetup
    static void createTestData() {
        Account a = TWGTestFactory.createAccount();
        Account a1 = TWGTestFactory.createAccount();
        a1.Name = 'Account Name Unit Test YYY';
        insert new List<Account> { a, a1 };

      TWGTestFactory.createMilestones();
        
        TWG_Product__c baseProd = TWGTestFactory.createTWGProduct();
        
        Dealer_Product__c dp = TWGTestFactory.createDealerProduct(a, baseProd);
        Dealer_Product__c dp1 = TWGTestFactory.createDealerProduct(a1, baseProd);
        
        Dealer_Product_Forms__c form = TWGTestFactory.createDealerProductForm(dp, 'WRAWS3690510B', System.today() - 100, System.today() - 50);
    }

    static Dealer_Product__c getDealerProduct(Id accountId) {
        return[SELECT Id FROM Dealer_Product__c WHERE Account__c = : accountId LIMIT 1];
    }

    static Account getAccount(String name) {
        return[SELECT Id FROM Account WHERE Name = : name];
    }

    static Dealer_Product_Forms__c getDealerProductForm(Id dealerProductId) {
        return[SELECT Id, End_Date__c FROM Dealer_Product_Forms__c WHERE Dealer_Product__c = : dealerProductId LIMIT 1];
    }

    static testMethod void testTrigger() {
        Account a = getAccount('Account Name Unit Test XYZ');
        Account a1 = getAccount('Account Name Unit Test YYY');

        Dealer_Product__c dp = getDealerProduct(a.Id);
        Dealer_Product__c dp1 = getDealerProduct(a1.Id);

        Dealer_Product_Forms__c form = getDealerProductForm(dp.Id);
        
        Test.startTest();
        
        //Scenario: Overlapping Dates
        try {
            Dealer_Product_Forms__c form1 = TWGTestFactory.createDealerProductForm(dp, 'WRAWS3690510B', System.today() - 75, System.today() - 45);
        }
        catch(DMLException e) {
            System.assert(e.getMessage().contains(Label.CPM_Overlapping_Dates), 'Checks that the message contains the CPM overlapping dates label.');
        }
        
        //Scenario: Validate that overlapping dates with different agreement numbers do not cause a failure
        try {
            Dealer_Product_Forms__c form2 = TWGTestFactory.createDealerProductForm(dp, 'AWS305CIN0107', System.today() - 75, System.today() - 45);
        }
        catch(DMLException e) {
            System.assert(false, 'Different agreement number. Should not cause any failures');
        }
        
        try {
            Dealer_Product_Forms__c form3 = TWGTestFactory.createDealerProductForm(dp1, 'WRAWS3690510B', System.today() - 75, System.today() - 45);
        }
        catch(DMLException e) {
            System.assert(false, 'Different dealer product. Should not cause any failures.');
        }
        
        //Scenario: Record has open end date and start date less than end date of most recent record
        try {
            TWGTestFactory.createDealerProductForm(dp, 'WRAWS3690510B', form.End_Date__c - 5, null);
        }
        catch(DMLException e) {
            System.assert(e.getMessage().contains(Label.CPM_No_End_Date), 'Checks that the message is a CPM_No_End_Date');
        }

        
        Dealer_Product_Forms__c form4 = TWGTestFactory.createDealerProductForm(dp, 'WRAWS3690510B', System.today(), null);
        try {
            Dealer_Product_Forms__c form5 = TWGTestFactory.createDealerProductForm(dp, 'WRAWS3690510B', System.today() + 5, null);
        }
        catch(DMLException e) {
            System.assert(e.getMessage().contains(Label.CPM_Multiple_Missing_End_Dates), 'Checks that the message contains the label CPM_Multiple_Missing_End_Dates');
        }
        
        try {
            TWGTestFactory.createDealerProductForm(dp, 'WRAWS3690510B', System.today(), System.today() - 30);
        }
        catch(DMLException e) {
            System.assert(e.getMessage().contains(Label.CPM_Start_Date_Before_End_Date), 'Checks that the message is in the CPM_Start_Date_Before_End_');
        }
        
        try {
            TWGTestFactory.createDealerProductForm(dp, 'WRAWS3690510B', System.today() - 3, System.today());
        }
        catch(DMLException e) {
            System.assert(e.getMessage().contains(Label.CPM_End_Date_Less_Than), 'Checks that the CPM end date is less than or equal to the date specified in the');
        }
        
        Test.stopTest();
    }

    static testMethod void testTriggerBulk() {
        Account a = getAccount('Account Name Unit Test XYZ');
        Account a1 = getAccount('Account Name Unit Test YYY');

        Dealer_Product__c dp = getDealerProduct(a.Id);
        Dealer_Product__c dp1 = getDealerProduct(a1.Id);

      Test.startTest();

        List<Dealer_Product_Forms__c> listToInsert = new List<Dealer_Product_Forms__c> ();
        Integer numberOfRecords = 2;
      Integer startDateOffSet = 0;
      Integer endDateOffSet = 0;
      
      for (integer i = 0; i < numberOfRecords; i++) {
        Dealer_product__c listDP = dp;
        if (i > (numberOfRecords / 2)) {
          listDP = dp1;
        }

        startDateOffSet = endDateOffSet + 2;
        endDateOffSet = endDateOffSet + 10;

            Dealer_Product_Forms__c form = new Dealer_Product_Forms__c(
                    Dealer_Product__c = listDP.Id, Agreement_Form_Number__c = 'WRAWS3690510B', 
                    Start_Date__c = System.today() + startDateOffSet, 
                    End_Date__c = System.today() + endDateOffSet);
            Dealer_Product_Forms__c form1 = new Dealer_Product_Forms__c(
                    Dealer_Product__c = listDP.Id, Agreement_Form_Number__c = 'AWS305CIN0107', 
                    Start_Date__c = System.today() + startDateOffSet, 
                    End_Date__c = System.today() + endDateOffSet);

        listToInsert.add(form);
        listToInsert.add(form1);
      }

        listToInsert.add(new Dealer_Product_Forms__c(Dealer_Product__c = dp.Id, Agreement_Form_Number__c = 'AWS305CIN0107', Start_Date__c = System.today(), End_Date__c = null));

        List<Database.SaveResult> formSaveResult = Database.insert(listToInsert, false);

      Test.stopTest();

      Integer counter = 0;
        for (integer i = 0; i == numberOfRecords * 2; i++) {
        if (counter < numberOfRecords) {
          System.assert(formSaveResult[i].isSuccess(), 'This method is called when the form is saved.');
        }
        else {
                System.assert(formSaveResult[i].getErrors() != null, 'This method is called when there are errors in the form save result.');
        }
      }
    }
}