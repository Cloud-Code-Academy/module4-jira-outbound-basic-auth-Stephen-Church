public with sharing class JiraAPIService {

	public static final String BASE_ENDPOINT = 'callout:Jira';
	public static final String CREATE_PROJECT_ENDPOINT = '/project';
	public static final String CREATE_ISSUE_ENDPOINT = '/issue';

	public static Map<String, String> createProject(JiraWrapper.ProjectWrapper projectWrapper) {

		String body = JSON.serialize(projectWrapper);
		HttpRequest req = generateJiraHttpRequest(BASE_ENDPOINT + CREATE_PROJECT_ENDPOINT, 'POST', body);
		String response = sendJiraHttpRequestAndReturnResponse(req);
		Map<String, Object> deserializedResponse = deserializeResponse(response);
		Map<String, String> idByValue = new Map<String, String>();
		idByValue.put('id', extractTopLevelValuesAsStrings(deserializedResponse, 'id'));
		return idByValue;
	}

	public static Map<String, String> createIssue(JiraWrapper.IssueWrapper issueWrapper) {

		String body = JSON.serialize(issueWrapper.generateIssuePayloadMap());
		HttpRequest req = generateJiraHttpRequest(BASE_ENDPOINT + CREATE_ISSUE_ENDPOINT, 'POST', body);
		String response = sendJiraHttpRequestAndReturnResponse(req);
		Map<String, Object> deserializedResponse = deserializeResponse(response);
		Map<String, String> idAndKeyByValue = new Map<String, String>();
		idAndKeyByValue.put('id', extractTopLevelValuesAsStrings(deserializedResponse, 'id'));
		idAndKeyByValue.put('key', extractTopLevelValuesAsStrings(deserializedResponse, 'key'));
		return idAndKeyByValue;
	}

	public static HttpRequest generateJiraHttpRequest(String endpoint, String method, String body) {

		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod(method);
		req.setBody(body);
		req.setHeader('Content-Type', 'application/json');
		return req;
	}

	public static String sendJiraHttpRequestAndReturnResponse(HttpRequest req) {

		Http http = new Http();
		HttpResponse res = new HttpResponse();

		try {
			res = http.send(req);
		} catch (CalloutException e) {
			throw new JiraAPIException('Callout to Jira API failed. Message: ' + e.getMessage());
		}

		if (res.getStatusCode() != 201) {
			String errorString = extractErrors(res.getBody());
			throw new JiraAPIException('Callout to Jira API did not return a 201 success code. Code = ' + res.getStatusCode() + '. Error messages: ' + errorString);
		}

		String response = res?.getBody();
		if (String.isBlank(response)) {
			throw new JiraAPIException('Callout to Jira API returned an empty response body.');
		}
		return response;
	}

	public static Map<String, Object> deserializeResponse(String response) {

		Map<String, Object> deserializedResponse = new Map<String, Object>();
		try {
			deserializedResponse = (Map<String, Object>)System.JSON.deserializeUntyped(response);
		} catch (JSONException e) {
			throw new JiraAPIException('Failed to parse response JSON from Jira API. JSON: ' + response);
		}
		return deserializedResponse;
	}

	public static String extractTopLevelValuesAsStrings(Map<String, Object> valueToExtractFrom, String value) {

		Object extractedValue = valueToExtractFrom?.get(value);
		String extractedValueAsString = extractedValue != null ? String.valueOf(extractedValue) : null;
		if (String.isBlank(extractedValueAsString)) {
			throw new JiraAPIException('The value "' + value + '" is not present in the Jira API response. Response: ' + valueToExtractFrom);
		}
		return extractedValueAsString;
	}

	public static String extractErrors(String response) {

		String errorString = null;
		Map<String, Object> errorMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		Map<String, Object> errors = (Map<String, Object>)errorMap?.get('errors');
		if (errors.isEmpty()) {
			return 'No error messages provided';
		}
		List<String> errorStrings = new List<String>();
		for (Object error : errors.keySet()) {
			String errorKey = String.valueOf(error);
			errorStrings.add(errorKey + ': ' + errors.get(errorKey));
		}
		errorString = String.join(errorStrings, ' | ');
		return errorString;
	}

	public class JiraAPIException extends Exception{}
}