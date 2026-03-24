public with sharing class JiraTriggerHelper {

	public static void processProjectAfterInsert(List<Jira_Project__c> newProjects) {

		for (Jira_Project__c project : newProjects) {
			if (eligibleToCreateProject(project)) {
				enqueueProjectCallout(project);
			}
		}
	}

	public static void processIssueAfterInsert(List<Jira_Issue__c> newIssues) {
		
		for (Jira_Issue__c issue : newIssues) {
			if (eligibleToCreateIssue(issue)) {
				enqueueIssuecallout(issue);
			}
		}
	}

	public static Boolean eligibleToCreateIssue(Jira_Issue__c issue) {

		return 
			String.isBlank(issue.Issue_Key__c) && 
			String.isNotBlank(issue.Project_Key__c) && 
			String.isNotBlank(issue.Summary__c) && 
			String.isNotBlank(issue.Description__c);
	}

	public static Boolean eligibleToCreateProject(Jira_Project__c project) {

		return String.isBlank(project.Project_ID__c);
	}

	public static void enqueueIssueCallout(Jira_Issue__c issue) {

		JiraCalloutQueueable callout = new JiraCalloutQueueable(issue.Id, issue.Project_Key__c, issue.Summary__c, issue.Description__c, issue.Issue_Type__c);

		if (!Test.isRunningTest()) {
			System.enqueueJob(callout);
		}
	}

	public static void enqueueProjectCallout(Jira_Project__c project) {

		JiraCalloutQueueable callout = new JiraCalloutQueueable(project.Id, project.Project_Name__c, project.Project_Key__c, project.Description__c);

		if (!Test.isRunningTest()) {
			System.enqueueJob(callout);
		}
	}

	// Enforces project casing and adds an X at the front if the project doesn't start with a letter
	public static void formatProjectKey(List<Jira_Project__c> projects) {

		for (Jira_Project__c project : projects) {

			project.Project_Key__c = project.Project_Key__c.toUpperCase();
			project.Project_Key__c = project.Project_Key__c.trim();
			project.Project_Key__c = project.Project_Key__c.deleteWhitespace();
			String firstChar = project.Project_Key__c.left(1);
			if (!firstChar.isAlpha()) {
				project.Project_Key__c = 'X' + project.Project_Key__c;
			}
		}
	}
}