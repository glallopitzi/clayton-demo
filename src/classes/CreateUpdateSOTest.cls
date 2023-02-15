@isTest
private class CreateUpdateSOTest {

    @testSetup
    public static void testSetup(){
        
        Service_Offerings__c so1 = ECOB_AccountDataUtil.createDSSServiceOffering('pathIdso1',true,'Test SO EVDO Backup');            
        Service_Offerings__c so2 = ECOB_AccountDataUtil.createDSSServiceOffering('pathIdso2',true,'Test SO VSAT Primary');            
        Service_Offerings__c so3 = ECOB_AccountDataUtil.createDSSServiceOffering('pathIdso3',true,'Test SO BYOB Temp');            
        Service_Offerings__c so4 = ECOB_AccountDataUtil.createDSSServiceOffering('pathIdso4',true,'Test SO DSL Shared');            
        Service_Offerings__c so5 = ECOB_AccountDataUtil.createDSSServiceOffering('pathIdso5',true,'Test SO DSL Dedicated');            
        Service_Offerings__c so6 = ECOB_AccountDataUtil.createDSSServiceOffering('pathIdso6',true,'Test SO UVERSE');                    
        Service_Offerings__c so7 = ECOB_AccountDataUtil.createDSSServiceOffering('pathIdso7',true,'Test SO CABLE');   
        
        Plan__c plan=ECOB_AccountDataUtil.createPlans('Base','Test plan');
        Package__c pack=ECOB_AccountDataUtil.createPackage('package1','Deinstall','programName');
        Plans_in_Package__c PlanPack = ECOB_AccountDataUtil.createPlansInPackage(pack.Id,plan.Id);
        
        Service_Offerings_in_this_Plan__c sop1 = ECOB_AccountDataUtil.getSerOfferInthePlan(plan.Id,so1.Id);
        Service_Offerings_in_this_Plan__c sop2 = ECOB_AccountDataUtil.getSerOfferInthePlan(plan.Id,so2.Id);
        Service_Offerings_in_this_Plan__c sop3 = ECOB_AccountDataUtil.getSerOfferInthePlan(plan.Id,so3.Id);
        Service_Offerings_in_this_Plan__c sop4 = ECOB_AccountDataUtil.getSerOfferInthePlan(plan.Id,so4.Id);
        Service_Offerings_in_this_Plan__c sop5 = ECOB_AccountDataUtil.getSerOfferInthePlan(plan.Id,so5.Id);
        Service_Offerings_in_this_Plan__c sop6 = ECOB_AccountDataUtil.getSerOfferInthePlan(plan.Id,so6.Id);
        Service_Offerings_in_this_Plan__c sop7 = ECOB_AccountDataUtil.getSerOfferInthePlan(plan.Id,so7.Id);
        
    }    
    @IsTest static void CreateUpdateSOTest1() {
        
        List<Service_Offerings__c> sos = [ Select id,name,Path_ID__c,Is_Active__c from Service_Offerings__c ];
        List<Plan__c> planList = [ Select id,name,Plan_Type__c from Plan__c ];
        List<Package__c> packageList = [ Select id,name,Package_Type__c,Program_Name__c from Package__c ];
        List<Plans_in_Package__c> plansInPack = [ select id,Package__c,Plan__c from Plans_in_Package__c ];
        List<Service_Offerings_in_this_Plan__c> sop = [ Select id,Plan__c,Service_Offerings__c from Service_Offerings_in_this_Plan__c ];
        
        Test.startTest();
        
        CreateUpdateSO.updateSO(sop);
        
        system.assertEquals(7,sos.size());
        system.assertEquals(7,sop.size());
        
        Test.stopTest();    
    }
      
}