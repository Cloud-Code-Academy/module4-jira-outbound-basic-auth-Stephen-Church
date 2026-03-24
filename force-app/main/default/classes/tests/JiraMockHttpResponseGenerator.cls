@isTest
public class JiraMockHttpResponseGenerator implements HttpCalloutMock {

	private String testResponse;

	public JiraMockHttpResponseGenerator(String testResponse) {
		this.testResponse = testResponse;
	}

	public HttpResponse respond(HttpRequest req) {
		
		if (testResponse == 'Callout Exception') {
			throw new CalloutException('Callout Failure Message');
		}

		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');

		switch on testResponse {

			when 'Issue Success' {
				res.setStatusCode(201);
				res.setBody('{"id": 10000 , "key": "ED-10000", "self": "https://your-domain.atlassian.net/rest/api/3/issue/10000", ' + '"transition": {"status": 200, "errorCollection": {"errorMessages": [], "errors": {}}}}');
			}
			when 'Issue Success - No Id' {
				res.setStatusCode(201);
				res.setBody('{"key": "ED-10000", "self": "https://your-domain.atlassian.net/rest/api/3/issue/10000", "transition": {"status": 200, "errorCollection": {"errorMessages": [], "errors": {}}}}');
			}
			when 'Issue Success - No Key' {
				res.setStatusCode(201);
				res.setBody('{"id": 10000, "self": "https://your-domain.atlassian.net/rest/api/3/issue/10000", ' + '"transition": {"status": 200, "errorCollection": {"errorMessages": [], "errors": {}}}}');
			}
			when 'Project Success' {
				res.setStatusCode(201);
				res.setBody('{"self": "https://cloud-code.atlassian.net/rest/api/3/project/10011", "id": 20000, "key": "ED"}');
			}
			when 'Project Success - No Id' {
				res.setStatusCode(201);
				res.setBody('{"self": "https://cloud-code.atlassian.net/rest/api/3/project/10011", "key": "ED"}');
			}
			when 'Failure' {
				res.setStatusCode(400);
				res.setBody('{"errorMessages":[],"errors":{"Error key": "Error creating the entity"}}');
			}
			when 'Failure - Empty Errors' {
				res.setStatusCode(400);
				res.setBody('{"errorMessages":[],"errors":{}}');				
			}
			when 'Empty Response' {
				res.setStatusCode(201);
				res.setBody('');
			}
			when 'JSON Exception' {
				res.setStatusCode(201);
				res.setBody('{invalid json}');
			}
		}
		return res;
	}
}
