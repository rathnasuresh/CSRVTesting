Feature: Cache status shows the correct head revision (repo has webhook)

  Background:
    Given the user has authenticated to CodeServer
    And the user has access to a repository that has already beed added to CodeServer
    And that repository has a webhook configured to notify CodeServer
    And the user has access to VCS client that allows him to make commits to that repository
    And the user has access to CodeCache ActiveMQ web console
    And the message queue batch size has been configured
    #For testing purposes, batch size should be configured to 3
    #API for checking cache status: GET /api/v1.1/repositories/{repoId}/cache (CodeCache API)
    #API for checking all the revisions/commits: GET/commits (Entity API)


  Scenario Outline: Cache status shows new head revision when the cache is updated and the number of new commits does not exceed the batch size
    Given the repository already has few committed revisions cached by CodeCache
    And the cache status of the repository shows a head revision
    And <numOfNewCommits> new commits have been made to the repository locally
    When those commits are pushed to origin
    And the webhook requests to update the cache for the repository
    And the user requests for the cache status of the repository
    Then the cache status shows a new head revision
    And the new head revision corresponds to the latest commit made to the repository

    Examples:
      | numOfNewCommits |
      | 1               |
      | 2               |
      | 3               |


  Scenario Outline: Cache status shows new head revision when the cache is updated and the number of new commits exceeds the batch size
    Given the repository already has few committed revisions cached by CodeCache
    And the cache status of the repository shows a head revision
    And <numOfNewCommits> new commits have been made to the repository locally
    When those commits are pushed to origin
    And the webhook requests to update the cache for the repository
    And the user requests for the cache status of the repository
    Then the cache status shows a new head revision
    And the new head revision corresponds to the latest commit made to the repository

    Examples:
      | numOfNewCommits |
      | 4               |
      | 7               |


  Scenario: Cache status shows old head revision when the cache is updated and no new commits are available
    Given the repository already has few committed revisions cached by CodeCache
    And the cache status of the repository shows a head revision
    And no new commits have been made to the repository
    When the webhook is manually triggered to update the cache for the repository
    And the user requests for the cache status of the repository
    Then the cache status shows the old head revision


  Scenario Outline: Cache status shows new head revision when the number of new commits does not exceed the batch size
    Given the repository does not have committed revisions cached by CodeCache
    #Repository was added without any commits
    And the cache status of the repository does not show a head revision
    And <numOfNewCommits> new commits have been made to the repository locally
    When those commits are pushed to origin
    And the webhook requests to update the cache for the repository
    And the user requests for the cache status of the repository
    Then the cache status shows a new head revision
    And the new head revision corresponds to the latest commit made to the repository

    Examples:
      | numOfNewCommits |
      | 1               |
      | 2               |
      | 3               |


  Scenario Outline: Cache status shows new head revision when the number of new commits exceeds the batch size
    Given the repository does not have committed revisions cached by CodeCache
    #Repository was added without any commits
    And the cache status of the repository does not show a head revision
    And <numOfNewCommits> new commits have been made to the repository locally
    When those commits are pushed to origin
    And the webhook requests to update the cache for the repository
    And the user requests for the cache status of the repository
    Then the cache status shows a new head revision
    And the new head revision corresponds to the latest commit made to the repository

    Examples:
      | numOfNewCommits |
      | 4               |
      | 7               |


  Scenario: Cache status does not show a head revision when the cache is updated and no new commits are available
    Given the repository does not have committed revisions cached by CodeCache
    #Repository was added without any commits
    And the cache status of the repository does not show a head revision
    And no new commits have been made to the repository
    When the webhook is manually triggered to update the cache for the repository
    And the user requests for the cache status of the repository
    Then the cache status shows the old head revision
