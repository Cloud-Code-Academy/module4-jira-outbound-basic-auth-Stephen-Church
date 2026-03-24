@isTest
private class JiraIntegrationTest {

	private static final String TEST_PROJECT_NAME = 'Test Project';
	private static final String TEST_PROJECT_KEY = 'TP1';
	private static final String TEST_DESCRIPTION = 'Test Description';
	private static final String TEST_ISSUE_SUMMARY = 'Test Issue Summary';
	private static final String TEST_ISSUE_TYPE = 'Task';

	@TestSetup
	static void setupTestData() {

		Jira_Project__c project = new Jira_Project__c(
			Project_Name__c = TEST_PROJECT_NAME,
			Project_Key__c = TEST_PROJECT_KEY,
			Description__c = TEST_DESCRIPTION
		);
		insert project;

		Jira_Issue__c issue = new Jira_Issue__c(
			Project_Key__c = TEST_PROJECT_KEY,
			Summary__c = TEST_ISSUE_SUMMARY,
			Description__c = TEST_DESCRIPTION,
			Issue_Type__c = TEST_ISSUE_TYPE
		);
		insert issue;
	}

	@isTest
	static void testCreateProjectSuccess() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Project Success'));

		Test.startTest();

		JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper(
			TEST_PROJECT_NAME,
			TEST_PROJECT_KEY,
			TEST_DESCRIPTION
		);

		Map<String, String> response = JiraAPIService.createProject(projectWrapper);

		Test.stopTest();

		Assert.areEqual('20000', response.get('id'), 'Project ID should match the mock response');
		Assert.isTrue(!response.containsKey('key'), 'The Project Key is not returned');
	}

	@isTest
	static void testCreateProjectFailure() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Failure'));

		String exceptionMessage = null;

		Test.startTest();

		JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper(
			TEST_PROJECT_NAME,
			TEST_PROJECT_KEY,
			TEST_DESCRIPTION
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createProject(projectWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the Project Id should be empty since the creation failed');
		Assert.areEqual(exceptionMessage, 'Callout to Jira API did not return a 201 success code. Code = 400. Error messages: Error key: Error creating the entity');
	}

	@isTest
	static void testCreateProjectFailure_calloutException() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Callout Exception'));

		String exceptionMessage = null;

		Test.startTest();

		JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper(
			TEST_PROJECT_NAME,
			TEST_PROJECT_KEY,
			TEST_DESCRIPTION
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createProject(projectWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the Project Id should be empty since the project creation failed');
		Assert.areEqual(exceptionMessage, 'Callout to Jira API failed. Message: Callout Failure Message');
	}

	@isTest
	static void testCreateProjectFailure_jsonException() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('JSON Exception'));

		String exceptionMessage = null;

		Test.startTest();

		JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper(
			TEST_PROJECT_NAME,
			TEST_PROJECT_KEY,
			TEST_DESCRIPTION
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createProject(projectWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the Project Id should be empty since the project creation failed');
		Assert.isTrue(exceptionMessage.startsWith('Failed to parse response JSON from Jira API. JSON:'), 'A JSON exception was not thrown as expected');
	}

	@isTest
	static void testCreateProjectFailure_missingId() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Project Success - No Id'));

		String exceptionMessage = null;

		Test.startTest();

		JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper(
			TEST_PROJECT_NAME,
			TEST_PROJECT_KEY,
			TEST_DESCRIPTION
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createProject(projectWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the Project Id should be empty since the project creation failed');
		Assert.isTrue(exceptionMessage.startsWith('The value "id" is not present in the Jira API response. Response: '));
	}

	@isTest
	static void testCreateProjectFailure_emptyErrors() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Failure - Empty Errors'));

		String exceptionMessage = null;

		Test.startTest();


		JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper(
			TEST_PROJECT_NAME,
			TEST_PROJECT_KEY,
			TEST_DESCRIPTION
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createProject(projectWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the Project Id should be empty since the project creation failed');
		Assert.areEqual('Callout to Jira API did not return a 201 success code. Code = 400. Error messages: No error messages provided', exceptionMessage, 'The exception message should indicate no errors were returned');
	}

	@isTest
	static void testCreateProjectFailure_emptyResponse() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Empty Response'));

		String exceptionMessage = null;

		Test.startTest();

		JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper(
			TEST_PROJECT_NAME,
			TEST_PROJECT_KEY,
			TEST_DESCRIPTION
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createProject(projectWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the project id should be empty since the project creation failed');
		Assert.areEqual(exceptionMessage, 'Callout to Jira API returned an empty response body.');
	}

	@isTest
	static void testCreateIssueSuccess() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Issue Success'));

		Test.startTest();

		JiraWrapper.IssueWrapper issueWrapper = new JiraWrapper.IssueWrapper(
			TEST_PROJECT_KEY,
			TEST_ISSUE_SUMMARY,
			TEST_DESCRIPTION,
			TEST_ISSUE_TYPE
		);

		Map<String, String> response = JiraAPIService.createIssue(issueWrapper);

		Test.stopTest();

		Assert.areEqual('10000', response.get('id'), 'Issue id should match the mock response');
		Assert.areEqual('ED-10000', response.get('key'), 'Issue key should match the mock response');
	}

	@isTest
	static void testCreateIssueFailure() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Failure'));

		String exceptionMessage = null;
		String issueKey = null;

		Test.startTest();

		JiraWrapper.IssueWrapper issueWrapper = new JiraWrapper.IssueWrapper(
			TEST_PROJECT_KEY,
			TEST_ISSUE_SUMMARY,
			TEST_DESCRIPTION,
			TEST_ISSUE_TYPE
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createIssue(issueWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the issue key and id should be empty since the issue creation failed');
		Assert.areEqual(exceptionMessage, 'Callout to Jira API did not return a 201 success code. Code = 400. Error messages: Error key: Error creating the entity');
	}

	@isTest
	static void testCreateIssueFailure_emptyResponse() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Empty Response'));

		String exceptionMessage = null;
		String issueKey = null;

		Test.startTest();

		JiraWrapper.IssueWrapper issueWrapper = new JiraWrapper.IssueWrapper(
			TEST_PROJECT_KEY,
			TEST_ISSUE_SUMMARY,
			TEST_DESCRIPTION,
			TEST_ISSUE_TYPE
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createIssue(issueWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the issue key and id should be empty since the issue creation failed');
		Assert.areEqual(exceptionMessage, 'Callout to Jira API returned an empty response body.');
	}

	@isTest
	static void testCreateIssueFailure_calloutException() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Callout Exception'));

		String exceptionMessage = null;
		String issueKey = null;

		Test.startTest();

		JiraWrapper.IssueWrapper issueWrapper = new JiraWrapper.IssueWrapper(
			TEST_PROJECT_KEY,
			TEST_ISSUE_SUMMARY,
			TEST_DESCRIPTION,
			TEST_ISSUE_TYPE
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createIssue(issueWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the issue key and id should be empty since the issue creation failed');
		Assert.areEqual(exceptionMessage, 'Callout to Jira API failed. Message: Callout Failure Message');
	}

	@isTest
	static void testCreateIssueFailure_jsonException() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('JSON Exception'));

		String exceptionMessage = null;

		Test.startTest();

		JiraWrapper.IssueWrapper issueWrapper = new JiraWrapper.IssueWrapper(
			TEST_PROJECT_KEY,
			TEST_ISSUE_SUMMARY,
			TEST_DESCRIPTION,
			TEST_ISSUE_TYPE
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createIssue(issueWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the Issue Id and Key should be empty since the issue creation failed');
		Assert.isTrue(exceptionMessage.startsWith('Failed to parse response JSON from Jira API. JSON:'), 'A JSON exception was not thrown as expected');
	}

	@isTest
	static void testCreateIssueFailure_missingId() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Issue Success - No Id'));

		String exceptionMessage = null;

		Test.startTest();

		JiraWrapper.IssueWrapper issueWrapper = new JiraWrapper.IssueWrapper(
			TEST_PROJECT_KEY,
			TEST_ISSUE_SUMMARY,
			TEST_DESCRIPTION,
			TEST_ISSUE_TYPE
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createIssue(issueWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(!response.containsKey('id'), 'An Id should not be in the map as it was not present in the response');
		Assert.isTrue(exceptionMessage.startsWith('The value "id" is not present in the Jira API response. Response: '));
	}

	@isTest
	static void testCreateIssueFailure_missingKey() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Issue Success - No Key'));

		String exceptionMessage = null;

		Test.startTest();

		JiraWrapper.IssueWrapper issueWrapper = new JiraWrapper.IssueWrapper(
			TEST_PROJECT_KEY,
			TEST_ISSUE_SUMMARY,
			TEST_DESCRIPTION,
			TEST_ISSUE_TYPE
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createIssue(issueWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(!response.containsKey('key'), 'A key should not be in the map as it was not present in the response');
		Assert.isTrue(exceptionMessage.startsWith('The value "key" is not present in the Jira API response. Response: '));
	}

	@isTest
	static void testCreateIssueFailure_emptyErrors() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Failure - Empty Errors'));

		String exceptionMessage = null;

		Test.startTest();

		JiraWrapper.IssueWrapper issueWrapper = new JiraWrapper.IssueWrapper(
			TEST_PROJECT_KEY,
			TEST_ISSUE_SUMMARY,
			TEST_DESCRIPTION,
			TEST_ISSUE_TYPE
		);

		Map<String, String> response = new Map<String, String>();
		try {
			response = JiraAPIService.createIssue(issueWrapper);
		} catch (JiraAPIService.JiraAPIException e) {
			exceptionMessage = e.getMessage();
		}

		Test.stopTest();

		Assert.isTrue(response.isEmpty(), 'The map with the Issue Id and Key should be empty since the project creation failed');
		Assert.areEqual('Callout to Jira API did not return a 201 success code. Code = 400. Error messages: No error messages provided', exceptionMessage, 'The exception message should indicate no errors were returned');
	}

	@isTest
	static void testProjectCalloutQueueable() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Project Success'));

		Jira_Project__c project = [SELECT Id FROM Jira_Project__c LIMIT 1];

		Test.startTest();

		JiraCalloutQueueable queueable = new JiraCalloutQueueable(
			project.Id,
			TEST_PROJECT_NAME,
			TEST_PROJECT_KEY,
			TEST_DESCRIPTION
		);

		System.enqueueJob(queueable);

		Test.stopTest();

		Jira_Project__c updatedProject = [
			SELECT Id, Project_ID__c
			FROM Jira_Project__c
			WHERE Id = :project.Id
		];
		Assert.areEqual('20000', updatedProject.Project_ID__c, 'The project should be updated with the Jira project ID');
	}

	@isTest
	static void testProjectCalloutQueueable_failure() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Failure'));

		Jira_Project__c project = [SELECT Id FROM Jira_Project__c LIMIT 1];

		Test.startTest();

		JiraCalloutQueueable queueable = new JiraCalloutQueueable(
			project.Id,
			TEST_PROJECT_NAME,
			TEST_PROJECT_KEY,
			TEST_DESCRIPTION
		);

		System.enqueueJob(queueable);

		Test.stopTest();

		Jira_Project__c updatedProject = [
			SELECT Id, Project_ID__c
			FROM Jira_Project__c
			WHERE Id = :project.Id
		];
		Assert.isNull(updatedProject.Project_ID__c, 'The Project Id should be null since the callout failed');

		// After my log is created, Nebula auto creates another Log Entry to track how many times Logger.saveLog() has been called. Order by created date so I get my log.
		List<LogEntry__c> logEntry = [
			SELECT Id, Message__c
			FROM LogEntry__c
			ORDER BY CreatedDate DESC
			LIMIT 1
		];

		String logEntryMessage = logEntry.get(0).Message__c;
		Assert.isTrue(logEntryMessage.startsWith('Exception message: Callout to Jira API did not return a 201 success code. Code = 400'));
		Assert.isTrue(logEntryMessage.contains('Additional data points: recordId = ' + updatedProject.Id));
		Assert.isTrue(logEntryMessage.contains('calloutType = PROJECT'));
		Assert.isTrue(logEntryMessage.contains('projectWrapper.projectName = ' + TEST_PROJECT_NAME));
		Assert.isTrue(logEntryMessage.contains('projectWrapper.projectKey = ' + TEST_PROJECT_KEY));
		Assert.isTrue(logEntryMessage.contains('projectWrapper.description = ' + TEST_DESCRIPTION));
	}

	@isTest
	static void testIssueCalloutQueueable() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Issue Success'));

		Jira_Issue__c issue = [SELECT Id FROM Jira_Issue__c LIMIT 1];

		Test.startTest();

		JiraCalloutQueueable queueable = new JiraCalloutQueueable(
			issue.Id,
			TEST_PROJECT_KEY,
			TEST_ISSUE_SUMMARY,
			TEST_DESCRIPTION,
			TEST_ISSUE_TYPE
		);

		System.enqueueJob(queueable);

		Test.stopTest();

		Jira_Issue__c updatedIssue = [
			SELECT Id, Issue_Key__c, Issue_Id__c
			FROM Jira_Issue__c
			WHERE Id = :issue.Id
		];
		Assert.areEqual('ED-10000', updatedIssue.Issue_Key__c, 'The issue should be updated with the Jira issue key');
		Assert.areEqual('10000', updatedIssue.Issue_Id__c, 'The issue should be updated with the Jira issue id');
	}

	@isTest
	static void testIssueCalloutQueueable_failure() {

		Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator('Failure'));

		Jira_Issue__c issue = [SELECT Id FROM Jira_Issue__c LIMIT 1];

		Test.startTest();

		JiraCalloutQueueable queueable = new JiraCalloutQueueable(
			issue.Id,
			TEST_PROJECT_KEY,
			TEST_ISSUE_SUMMARY,
			TEST_DESCRIPTION,
			TEST_ISSUE_TYPE
		);

		System.enqueueJob(queueable);

		Test.stopTest();

		Jira_Issue__c updatedIssue = [
			SELECT Id, Issue_Key__c, Issue_Id__c
			FROM Jira_Issue__c
			WHERE Id = :issue.Id
		];
		Assert.isNull(updatedIssue.Issue_Key__c, 'The Issue Key should be null since the callout failed');
		Assert.isNull(updatedIssue.Issue_Id__c, 'The Issue Id should be null since the callout failed');

		// After my log is created, Nebula auto creates another Log Entry to track how many times Logger.saveLog() has been called. Order by created date so I get my log.
		List<LogEntry__c> logEntry = [
			SELECT Id, Message__c
			FROM LogEntry__c
			ORDER BY CreatedDate DESC
			LIMIT 1
		];

		String logEntryMessage = logEntry.get(0).Message__c;
		Assert.isTrue(logEntryMessage.startsWith('Exception message: Callout to Jira API did not return a 201 success code. Code = 400'));
		Assert.isTrue(logEntryMessage.contains('Additional data points: recordId = ' + updatedIssue.Id));
		Assert.isTrue(logEntryMessage.contains('calloutType = ISSUE'));
		Assert.isTrue(logEntryMessage.contains('issueWrapper.projectKey = ' + TEST_PROJECT_KEY));
		Assert.isTrue(logEntryMessage.contains('issueWrapper.summary = ' + TEST_ISSUE_SUMMARY));
		Assert.isTrue(logEntryMessage.contains('issueWrapper.description = ' + TEST_DESCRIPTION));
		Assert.isTrue(logEntryMessage.contains('issueWrapper.issueType = ' + TEST_ISSUE_TYPE));
	}
}
