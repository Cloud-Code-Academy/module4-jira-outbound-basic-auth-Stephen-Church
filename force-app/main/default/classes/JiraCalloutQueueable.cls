public class JiraCalloutQueueable implements Queueable, Database.AllowsCallouts {
	
	public static final String TYPE_PROJECT = 'PROJECT';
	public static final String TYPE_ISSUE = 'ISSUE';

	private String calloutType;
	private Id recordId;
	private JiraWrapper.ProjectWrapper projectWrapper;
	private JiraWrapper.IssueWrapper issueWrapper;

	public JiraCalloutQueueable(Id recordId, String projectName, String projectKey, String description) {
		this.calloutType = TYPE_PROJECT;
		this.recordId = recordId;
		this.projectWrapper = new JiraWrapper.ProjectWrapper(projectName, projectKey, description);
	}
	
	public JiraCalloutQueueable(Id recordId, String projectKey, String summary, String description, String issueType) {
		this.calloutType = TYPE_ISSUE;
		this.recordId = recordId;
		this.issueWrapper = new JiraWrapper.IssueWrapper(projectKey, summary, description, issueType
		);
	}

	public void execute(QueueableContext context) {

		Map<String, String> keyAndIdByValue = new Map<String, String>();

		if (calloutType == TYPE_PROJECT) {

			try {
				keyAndIdByValue = JiraAPIService.createProject(projectWrapper);
				updateJiraProject(keyAndIdByValue.get('id'));
			} catch (JiraAPIService.JiraAPIException je) {
				logProjectException(je);
				return;
			}

		} else if (calloutType == TYPE_ISSUE) {

			try {
				keyAndIdByValue = JiraAPIService.createIssue(issueWrapper);
				updateJiraIssue(keyAndIdByValue.get('id'), keyAndIdByValue.get('key'));
			} catch (JiraAPIService.JiraAPIException je) {
				logIssueException(je);
				return;
			}
		}
	}

	// When a user creates a Project, they specify the key they want. Therefore, we only need to update the Project with the Id
	private void updateJiraProject(String jiraProjectId) {

		Jira_Project__c jp = new Jira_Project__c();
		jp.Id = recordId;
		jp.Project_ID__c = jiraProjectId;
		
		update jp;
	}

	// When a user creates an Issue, they don't specify the key or id, as both are auto-generated. Therefore, we need to update the Issue with both
	private void updateJiraIssue(String jiraIssueId, String jiraIssueKey) {
		
		Jira_Issue__c ji = new Jira_Issue__c();
		ji.Id = recordId;
		ji.Issue_Id__c = jiraIssueId;
		ji.Issue_Key__c = jiraIssueKey;
		ji.Last_Updated__c = DateTime.now();
		
		update ji;
	}

	private void logIssueException(JiraAPIService.JiraAPIException je) {

		String errorMessage = 'Exception message: ' + je.getMessage() + '. Additional data points: ';
		errorMessage += 'recordId = ' + recordId + '. ';
		errorMessage += 'calloutType = ' + calloutType + '. ';
		errorMessage += 'issueWrapper.projectKey = ' + issueWrapper?.projectKey + '. ';
		errorMessage += 'issueWrapper.summary = ' + issueWrapper?.summary + '. ';
		errorMessage += 'issueWrapper.description = ' + issueWrapper?.description + '. ';
		errorMessage += 'issueWrapper.issueType = ' + issueWrapper?.issueType + '. ';

		Logger.info(errorMessage);
		Logger.saveLog();
	}

	private void logProjectException(JiraAPIService.JiraAPIException je) {

		String errorMessage = 'Exception message: ' + je.getMessage() + '. Additional data points: ';
		errorMessage += 'recordId = ' + recordId + '. ';
		errorMessage += 'calloutType = ' + calloutType + '. ';
		errorMessage += 'projectWrapper.projectName = ' + projectWrapper?.name + '. ';
		errorMessage += 'projectWrapper.projectKey = ' + projectWrapper?.key + '. ';
		errorMessage += 'projectWrapper.description = ' + projectWrapper?.description + '. ';

		Logger.info(errorMessage);
		Logger.saveLog();
	}
}