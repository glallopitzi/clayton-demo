@isTest

public class Attachment_Controller_Test{
    
    @testsetup
    static void testData(){
        
        List<Offers__c> offerList = new List<Offers__c>();
        List<Account> accountList = new List<Account>();
        Id partnerAccRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'Consumer'].Id;
        
        Offers__c offer = new Offers__c();
        offer.Offer_Display_Name__c = 'ttt';
        offer.Name = 'ttt';
        offer.Offer_Type__c = 'New';
        offer.Display_Sequence__c = Null;
        offer.Add_On_Upfront_Fee__c = true;
        offer.Ready_for_Use__c = true;
        offerList.add(offer);
        
        
        Offers__c offer1 = new Offers__c();
        offer1.Offer_Display_Name__c = 'sasas';
        offer1.Name = 'sasas';
        offer1.Offer_Type__c = 'New';
        offer1.Display_Sequence__c = Null;
        offer1.Add_On_Upfront_Fee__c = true;
        offer1.Ready_for_Use__c = true;
        offerList.add(offer1);
        
        Offers__c offer2 = new Offers__c();
        offer2.Offer_Display_Name__c = 'offerdel';
        offer2.Name = 'offerdel';
        offer2.Offer_Type__c = 'New';
        offer2.Display_Sequence__c = Null;
        offer2.Add_On_Upfront_Fee__c = true;
        offer2.Ready_for_Use__c = true;
        offerList.add(offer2);
        
        Offers__c offer3 = new Offers__c();
        offer3.Offer_Display_Name__c = 'offerFAP1';
        offer3.Name = 'offerFAP1';
        offer3.Offer_Type__c = 'FAP';
        offer3.Display_Sequence__c = Null;
        offer3.Add_On_Upfront_Fee__c = true;
        offerList.add(offer3);
        
        insert offerList;
        
        Account acc = new Account();
        acc.Name= 'account1';
        acc.Partner_Type__c = 'Hughes Sales Agent (HSA)';
        acc.PartnerId__c = '380';
        acc.SAN_Prefix__c =null;
        acc.RecordTypeId = partnerAccRecordTypeId;
        accountList.add(acc);
        
        Account acc1 = new Account();
        acc1.Name = 'account3';
        acc.PartnerId__c = '15';
        acc1.SAN_Prefix__c = null;
        acc1.Partner_Type__c = 'Hughes Sales Agent (HSA)';
        acc1.RecordTypeId = partnerAccRecordTypeId;
        accountList.add(acc1);
        System.assertEquals(acc1.RecordTypeId,partnerAccRecordTypeId);
        Account acc2 = new Account();
        acc2.Name = 'account2';
        acc2.PartnerId__c = '890';
        acc2.SAN_Prefix__c ='test';
        acc2.Partner_Type__c = 'Hughes Sales Agent (HSA)';
        acc2.RecordTypeId = partnerAccRecordTypeId;
        accountList.add(acc2);
        
        insert accountList;
        
        Offer_Partner__c op = new Offer_Partner__c();
        op.Offer__c = offer.id;
        op.Consumer__c = acc1.id;
        op.Is_Unique__c = offer.id+'-'+acc1.id;
        insert op;
        
        Offer_Partner__c op1 = new Offer_Partner__c();
        op1.Offer__c = offer1.id;
        op1.Consumer__c = acc.id;
        op1.Is_Unique__c = offer1.id+'-'+acc.id;
        insert op1;
        
        Offer_Partner__c op2 = new Offer_Partner__c();
        op2.Offer__c = offer2.id;
        op2.Consumer__c = acc2.id;
        op2.Is_Unique__c = offer2.id+'-'+acc2.id;
        insert op2;
        set<string>strList=new set<string>();
        Offer_Partner__c op3 = new Offer_Partner__c();
        op3.Offer__c = offer3.id;
        op3.Consumer__c = acc2.id;
        op3.Is_Unique__c = offer3.id+'-'+acc2.id;
        insert op3;
        strList.add(offer3.id+'-'+acc2.id);
        boolean b=Attachment_Controller.checkExistingDuplicateRecord(op3,strList);
        OfferMgmt_Partner_Type__c Offerpartner = new OfferMgmt_Partner_Type__c();
        Offerpartner.Name='Service Provider';
        Offerpartner.Yahs_Partner_Type__c = true;
        Offerpartner.FAP__c = false;
        insert Offerpartner;
        
        OfferMgmt_Partner_Type__c Offerpartner1 = new OfferMgmt_Partner_Type__c();
        Offerpartner1.Name ='HSA';
        Offerpartner1.Yahs_Partner_Type__c = false;
        Offerpartner1.FAP__c = true;
        insert Offerpartner1; 
        
        if(OfferMgmtMainController.getRestrictedOfferVisibilty().Restricted_Visibility__c == true  && Schema.getGlobalDescribe().get('Account_User__c')!= null){
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SobjectType oType = gd.get('Account_User__c'); 
            SObject sobj = oType.newSObject();
            Schema.SObjectField field = oType.getDescribe().fields.getMap().get('Account__c');
            sobj.put(field,acc.id);
            sobj.put('User__c',UserInfo.getUserId());
            insert sobj;
            
            sobj = oType.newSObject();
            sobj.put(field,acc1.id);
            sobj.put('User__c',UserInfo.getUserId());
            insert sobj;
            
            sobj = oType.newSObject();
            sobj.put(field,acc2.id);
            sobj.put('User__c',UserInfo.getUserId());
            insert sobj;
        }
    }
    
    @isTest
    public static void SaveCSV_TestMethod1(){
        test.startTest();
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{headers,'abc,,true'};
            case1.add(',abc,true');
        case1.add('xyz,abc,');
        case1.add('offer1,efg,false');
        case1.add('tttt,15,true');
        case1.add('dczc,380,false');
        case1.add('offer1,23,true');
        case1.add('offerFAP1,380,false');
        case1.add('ttt,380,false');
        case1.add('offerFAP1,890,false');
        case1.add('offerdel,890,false');
        case1.add('offerdel,15,true');
        case1.add('666,15,true');
        case1.add('offerdel,15,true');
        List<String> SaveCSV = Attachment_Controller.SaveCSV(case1, 'Import');
        System.assertEquals(SaveCSV[0],System.Label.OfferMgmt_FileUploadSuccessMsg);
        test.stopTest();
    }
    
    @isTest
    public static void SaveCSV_TestMethod2(){
        test.startTest();
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{headers,'Test1FAP,HNSDWAYISP,true'};
            case1.add(',Test1FAP,true');
        List<String> SaveCSV = Attachment_Controller.SaveCSV(case1, 'Import');
        System.assertEquals(SaveCSV[0],System.Label.OfferMgmt_FileUploadSuccessMsg);
        test.stopTest();
    }    
    
    @isTest
    public static void SaveCSV_TestMethod3(){
        test.startTest();
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{headers,'ttt,15,true'};
            case1.add('offerdel,890,false');
        List<String> SaveCSV = Attachment_Controller.SaveCSV(case1, 'Import'); 
        System.assertEquals(SaveCSV[0],System.Label.OfferMgmt_FileUploadSuccessMsg);
        test.stopTest();
    }    
    
    @isTest
    public static void SaveCSV_TestMethod4(){
        test.startTest();
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{headers,'abc,,uiiui'};
            case1.add(',abc,dsfdsf');
        case1.add(',abc,fsdfsd');
        case1.add(',abc,fsdfsd');
        case1.add(',efg,sdfsdf');
        case1.add(',15,dsfdsf');
        case1.add(',380,sdfsdf');
        case1.add(',23,dsfsdf');
        List<String> SaveCSV = Attachment_Controller.SaveCSV(case1, 'Import'); 
        System.assertEquals(SaveCSV[0],System.Label.OfferMgmt_FileUploadSuccessMsg);
        test.stopTest();
    }
    
    @isTest
    public static void SaveCSV_TestMethod5(){
        test.startTest();
        List<String> case4 = new List<String>{'OfferNamePartner IDisActive','offer1efgfalse','offer1,efg,false'};
            List<String> SaveCSV = Attachment_Controller.SaveCSV(case4,'Import'); 
        System.assertEquals(SaveCSV[0],'Corrupted CSV');
        test.stopTest();
    }
    
    @isTest
    public static void SaveCSV_TestMethod6(){
        test.startTest();
        List<String> case4 = new List<String>{'',''};
            List<String> SaveCSV = Attachment_Controller.SaveCSV(case4,'Import');  
        System.assertEquals(SaveCSV[0],'Invalid CSV format');
        test.stopTest();
    }
    
    @isTest
    public static void SaveCSV_TestMethod7(){
        test.startTest();
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
        List<String> case4 = new List<String>{headers,''};
            List<String> SaveCSV = Attachment_Controller.SaveCSV(case4, 'Import');  
        System.assertEquals(SaveCSV[0],'Empty CSV');
        test.stopTest();
    }
    @isTest
    public static void SaveCSV_TestMethod8(){
        test.startTest();
        List<String> case4 = new List<String>{};
            List<String> SaveCSV = Attachment_Controller.SaveCSV(case4,'Import'); 
        System.assertEquals(SaveCSV.size(),1);
        test.stopTest();
    }
    @isTest
    public static void SaveCSV_TestMethod9(){
        test.startTest();
        List<String> case4 = new List<String>{', ,','null,123,'};
            List<String> SaveCSV = Attachment_Controller.SaveCSV(case4,'Import'); 
        System.assertEquals(SaveCSV[0],'Invalid CSV format');
        test.stopTest();
    }
    @isTest
    public static void SaveCSV_TestMethod10(){
        test.startTest();
        List<String> case4 = new List<String>{', ,','null,123,'};
            List<String> SaveCSV = Attachment_Controller.SaveCSV(case4,'Import'); 
        System.assertEquals(SaveCSV[0],'Invalid CSV format');
        test.stopTest();
    }
    @isTest
    public static void SaveCSV_TestMethod11(){
        if(Schema.getGlobalDescribe().get('Account_User__c')!= null){
            test.startTest();
            String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
            List<String> case1 = new List<String>{headers,'ttt,15,true'};
                case1.add('offerFAP1,380,false');
            processTraverseCSVBatch batch = new processTraverseCSVBatch(case1,true,'Import');
            Database.executeBatch(batch);
            System.assert(case1.size()>0);
            test.stopTest();
        }        
    }    
    @isTest
    public static void SaveCSV_TestMethod12(){
        test.startTest();
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{headers,'ttt,15,true'};
            case1.add('offerFAP1,380,true');
        processTraverseCSVBatch batch = new processTraverseCSVBatch(case1,false,'Import');
        Database.executeBatch(batch);
        System.assert(case1.size()>0);
        test.stopTest();
        
    }
    @isTest
    public static void SaveCSV_TestMethod13(){
        test.startTest();
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{headers,'ttt--,15,true'};
            case1.add('offerFAP1--,380,true');
        processTraverseCSVBatch batch = new processTraverseCSVBatch(case1,false,'Import');
        Database.executeBatch(batch);
        System.assert(case1.size()>0);
        test.stopTest();
        
    }
    @isTest
    public static void SaveCSV_TestMethod14(){
        test.startTest();
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{headers,'sasas,HNSDWAYISP,true'};
            case1.add('ttt,Test1FAP,true');
        List<String> SaveCSV = Attachment_Controller.SaveCSV(case1, 'Import');
        System.assertEquals(SaveCSV[0],System.Label.OfferMgmt_FileUploadSuccessMsg);
        test.stopTest();
    } 
    
    @isTest
    public static void SaveCSV_TestMethod15(){
        test.startTest();
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_Add+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{headers,'sasas,HNSDWAYISP,true'};
            case1.add('ttt,Test1FAP,true');
        List<String> SaveCSV = Attachment_Controller.SaveCSV(case1, 'Import'); 
        System.assertEquals(SaveCSV[0],'Invalid CSV format');
        test.stopTest();
    }   
    @isTest
    public static void SaveCSV_TestMethod16(){
        test.startTest();
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_Add+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{headers,'sasas,HNSDWAYISP,true'};
            case1.add('ttt,Test1FAP,true');
        Attachment_Controller.errorMsg.add('Invalid Data');
        List<String> SaveCSV = Attachment_Controller.SaveCSV(case1, 'Import'); 
        System.assertEquals(SaveCSV[0],'Invalid Data');
        test.stopTest();
    }   
    @isTest
    public static void SaveCSV_TestMethod17(){
        test.startTest();
        
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{null};
            processTraverseCSVBatch batch = new processTraverseCSVBatch(null,false,null);
        batch.execute(null,null);
        System.assert(case1.size()>0);
        test.stopTest();
    } 
    @isTest
    public static void SaveCSV_TestMethod18(){
        test.startTest();
        
        String headers = System.Label.OfferMgmt_OfferName+','+System.Label.OfferMgmt_PartnerID+','+System.Label.OfferMgmt_isActive;
        List<String> case1 = new List<String>{null};
            processSaveCSVBatch batch = new processSaveCSVBatch(null,null,null,false,'1',1,1,'Import',null,null,null,null,null,null);
        batch.execute(null,null);
        System.assert(case1.size()>0);
        test.stopTest();
    } 
    
}