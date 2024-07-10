class SendEmailHandler {

    public void aMethod() {
        for (Integer i=0; i<10; i++) {
			EmailTemplate et=[Select id from EmailTemplate where name = 'EmailTemplatename' limit 1];
            Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            mail.setTargetObjectIds(lstIds);
            mail.setSenderDisplayName('System Admin');
            mail.setTemplateId(et.id);
            Messaging.MassEmailMessage[] messages = new Messaging.MassEmailMessage[] { mail };
            Messaging.sendEmail(messages, true);
		}
    }
}