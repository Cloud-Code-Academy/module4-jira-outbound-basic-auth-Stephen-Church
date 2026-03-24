trigger JiraIssueTrigger on Jira_Issue__c(after insert) {

	if (Trigger.isAfter && Trigger.isInsert) {
		JiraTriggerHelper.processIssueAfterInsert(Trigger.new);
	}
}
