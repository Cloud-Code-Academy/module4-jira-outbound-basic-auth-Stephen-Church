/**
 * Wrapper classes for Jira entities (Project and Issue)
 */
public class JiraWrapper {
	private static final String LEAD_ACCOUNT_ID = '712020:263bf36f-288d-4ae0-be0e-7710ac81cda4';
	private static final String PROJECT_TEMPLATE_KEY = 'com.pyxis.greenhopper.jira:gh-scrum-template';
	private static final String PROJECT_TYPE_KEY = 'software';

	public class ProjectWrapper {
		public String name;
		public String key;
		public String description;
		public String leadAccountId;
		public String projectTemplateKey;
		public String projectTypeKey;

		public ProjectWrapper(String name, String key, String description) {
			this.name = name;
			this.key = key;
			this.description = description;
			this.leadAccountId = LEAD_ACCOUNT_ID;
			this.projectTemplateKey = PROJECT_TEMPLATE_KEY;
			this.projectTypeKey = PROJECT_TYPE_KEY;
		}
	}

	public class IssueWrapper {
		public String name;
		public String key;
		public String description;
		public String projectKey;
		public String summary;
		public String issueType;

		public IssueWrapper(String projectKey, String summary, String description, String issueType) {
			this.projectKey = projectKey;
			this.summary = summary;
			this.description = description;
			this.issueType = (String.isNotBlank(issueType)) ? issueType : 'Task';
		}

		public Map<String, Object> generateIssuePayloadMap() {

			Map<String, Object> formattedDescription = formatDescription(description);

			Map<String, Object> issueTypeDetails = new Map<String, Object>();
			issueTypeDetails.put('name', issueType);

			Map<String, Object> projectDetails = new Map<String, Object>();
			projectDetails.put('key', projectKey);

			Map<String, Object> fields = new Map<String, Object>();
			fields.put('project', projectDetails);
			fields.put('issuetype', issueTypeDetails);
			fields.put('summary', summary);
			fields.put('description', formattedDescription);

			Map<String, Object> payload = new Map<String, Object>();
			payload.put('fields', fields);

			return payload;
		}

		private Map<String, Object> formatDescription(String descText) {

			Map<String, Object> contentDetails = new Map<String, Object>();
			contentDetails.put('type', 'text');
			contentDetails.put('text', descText);

			List<Object> paragraphContent = new List<Object>{contentDetails };

			Map<String, Object> contentItem = new Map<String, Object>();
			contentItem.put('type', 'paragraph');
			contentItem.put('content', paragraphContent);

			List<Object> allContent = new List<Object>();
			allContent.add(contentItem);

			Map<String, Object> description = new Map<String, Object>();
			description.put('type', 'doc');
			description.put('version', 1);
			description.put('content', allContent);

			return description;
		}
	}
}
