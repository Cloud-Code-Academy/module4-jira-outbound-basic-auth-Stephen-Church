trigger JiraProjectTrigger on Jira_Project__c(before insert, after insert) {
	
	if (Trigger.isBefore && Trigger.isInsert) {
		JiraTriggerHelper.formatProjectKey(Trigger.new);
	}
	
	if (Trigger.isAfter && Trigger.isInsert) {
		JiraTriggerHelper.processProjectAfterInsert(Trigger.new);
	}
}
