@isTest
public with sharing class JiraTriggerHelperTest {

    @isTest
    static void eligibleToCreateIssue_yes() {

        Jira_Issue__c ji = new Jira_Issue__c();
        ji.Project_Key__c = 'ED';
        ji.Summary__c = 'Test Summary';
        ji.Description__c = 'Test Description';

        Test.startTest();
        Boolean result = JiraTriggerHelper.eligibleToCreateIssue(ji);
        Test.stopTest();

        Assert.isTrue(result, 'The Jira Issue should be eligible to have an issue created');
    }

    @isTest
    static void eligibleToCreateIssue_no_hasIssueKey() {

        Jira_Issue__c ji = new Jira_Issue__c();
        ji.Project_Key__c = 'ED';
        ji.Issue_Key__c = 'ED-100';
        ji.Summary__c = 'Test Summary';
        ji.Description__c = 'Test Description';

        Test.startTest();
        Boolean result = JiraTriggerHelper.eligibleToCreateIssue(ji);
        Test.stopTest();

        Assert.isFalse(result, 'The Jira Issue should not be eligible to have an issue created because it already has an issue key');
    }

    @isTest
    static void eligibleToCreateIssue_no_noProjectKey() {

        Jira_Issue__c ji = new Jira_Issue__c();
        ji.Issue_Key__c = 'ED-100';
        ji.Summary__c = 'Test Summary';
        ji.Description__c = 'Test Description';

        Test.startTest();
        Boolean result = JiraTriggerHelper.eligibleToCreateIssue(ji);
        Test.stopTest();

        Assert.isFalse(result, 'The Jira Issue should not be eligible to have an issue created because it does not have a project key');
    }

    @isTest
    static void eligibleToCreateIssue_no_noSummary() {

        Jira_Issue__c ji = new Jira_Issue__c();
        ji.Project_Key__c = 'ED';
        ji.Description__c = 'Test Description';

        Test.startTest();
        Boolean result = JiraTriggerHelper.eligibleToCreateIssue(ji);
        Test.stopTest();

        Assert.isFalse(result, 'The Jira Issue should not be eligible to have an issue created because it has no summary');
    }

    @isTest
    static void eligibleToCreateIssue_no_noDescription() {

        Jira_Issue__c ji = new Jira_Issue__c();
        ji.Project_Key__c = 'ED';
        ji.Summary__c = 'Test Summary';

        Test.startTest();
        Boolean result = JiraTriggerHelper.eligibleToCreateIssue(ji);
        Test.stopTest();

        Assert.isFalse(result, 'The Jira Issue should not be eligible to have an issue created because it has no description');
    }

    @isTest
    static void eligibleToCreateProject_yes() {

        Jira_Project__c jp = new Jira_Project__c();

        Test.startTest();
        Boolean result = JiraTriggerHelper.eligibleToCreateProject(jp);
        Test.stopTest();

        Assert.isTrue(result, 'The Jira Project should be eligible to have a Project created');
    }

    @isTest
    static void eligibleToCreateProject_no() {

        Jira_Project__c jp = new Jira_Project__c();
        jp.Project_ID__c = '1000';

        Test.startTest();
        Boolean result = JiraTriggerHelper.eligibleToCreateProject(jp);
        Test.stopTest();

        Assert.isFalse(result, 'The Jira Project should not be eligible to have a Project created since it already has a project id');
    }

    @isTest
    static void formatProjectKey_unchanged() {

        String insertedProjectKey = 'TESTPRO';

        Jira_Project__c jp = new Jira_Project__c();
        jp.Project_Key__c = insertedProjectKey;
        jp.Name = 'Test Name';
        jp.Project_Name__c = 'Test Name';

        Test.startTest();
        insert jp;
        Test.stopTest();

        Jira_Project__c jpInserted = [SELECT Id, Project_Key__c FROM Jira_Project__c WHERE Id = :jp.Id];
        Assert.areEqual(insertedProjectKey, jpInserted.Project_Key__c);
    }

    @isTest
    static void formatProjectKey_changed() {

        Jira_Project__c jp = new Jira_Project__c();
        jp.Project_Key__c = ' 1 test pro ';
        jp.Name = 'Test Name';
        jp.Project_Name__c = 'Test Name';

        Test.startTest();
        insert jp;
        Test.stopTest();

        Jira_Project__c jpInserted = [SELECT Id, Project_Key__c FROM Jira_Project__c WHERE Id = :jp.Id];
        Assert.areEqual('X1TESTPRO', jpInserted.Project_Key__c);
    }
}