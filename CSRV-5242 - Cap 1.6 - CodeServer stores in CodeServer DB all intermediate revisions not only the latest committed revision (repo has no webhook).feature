Feature: CodeServer stores in CodeServer DB all intermediate revisions not only the latest committed revision (repo has no webhook)


  Background:
    Given the user has authenticated to CodeServer
    And the user has access to a repository added to CodeServer
    And that repository has no webhook configured to notify CodeServer
    And the user has access to VCS client that allows him to make commits to that repository
    And the user has access to CodeCache ActiveMQ web console
    And the message queue batch size has been configured
    #For testing purposes, batch size should be configured to 3
    #API for checking cache status: GET /api/v1.1/repositories/{repoId}/cache (CodeCache API)
    #API for checking all the revisions/commits: GET/commits (Entity API)
    #API for requesting cache update: (PUT /api/v1.1/repositories/{repoId}/cache)


  Scenario Outline: Cache status shows new head revision when the cache is updated and the number of new commits does not exceed the batch size
    Given the repository already has few committed revisions cached by CodeCache
    And the cache status of the repository shows a head revision
    And <numOfNewCommits> new commits have been made to the repository
    When the user requests to update the cache for the repository via API
    And the request returns a successful response
    And the user requests for the cache status of the repository
    Then the cache status shows a new head revision
    And the new head revision corresponds to the latest commit made to the repository

    Examples:
      | numOfNewCommits |
      | 1               |
      | 2               |
      | 3               |


  Scenario Outline: Cache status shows new head revision when cached is updated and the number of new commits exceeds the batch size
    Given the repository already has few committed revisions cached by CodeCache
    And the cache status of the repository shows a head revision
    And <numOfNewCommits> new commits have been made to the repository
    When the user requests to update the cache for the repository via API
    And the request returns a successful response
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
    And no new commits have been made to the repository locally
    When the user requests to update the cache for the repository via API
    And the request returns a successful response
    And the user requests for the cache status of the repository
    Then the cache status shows the old head revision


  Scenario Outline: All intermediate revisions are stored in CodeServer DB when the number of new commits does not exceed the batch size
    Given the repository already has few committed revisions cached by CodeCache
    And the cache status of the repository shows a head revision
    And <numOfNewCommits> new commits have been made to the repository locally
    When the user requests to update the cache for the repository via API
    And CacheUpdateNotification messages are sent to ActiveMQ
    And CodeServer completes importing the updates to the repository
    And the user checks the commits made to the repository via CodeServer API
    Then the user sees the list of commits made to the repository
    And the list of commits includes the old head revision
    And the list of commits includes the new head revision
    And the list of commits includes all intermediate revisions between the old and new head revisions

    Examples:
      | numOfNewCommits |
      | 1               |
      | 2               |
      | 3               |


  Scenario Outline: All intermediate revisions are stored in CodeServer DB when the number of new commits exceeds the batch size
    Given the repository already has few committed revisions cached by CodeCache
    And the cache status of the repository shows a head revision
    And <numOfNewCommits> new commits have been made to the repository locally
    When the user requests to update the cache for the repository via API
    And CacheUpdateNotification messages are sent to ActiveMQ
    And CodeServer completes importing the updates to the repository
    And the user checks the commits made to the repository via CodeServer API
    Then the user sees the list of commits made to the repository
    And the list of commits includes the old head revision
    And the list of commits includes the new head revision
    And the list of commits includes all intermediate revisions between the old and new head revisions

    Examples:
      | numOfNewCommits |
      | 4               |
      | 7               |


  Scenario Outline: Cache status shows new head revision when the number of new commits does not exceed the batch size
    Given the repository does not have committed revisions cached by CodeCache
    #Repository was added without any commits
    And the cache status of the repository does not show a head revision
    And <numOfNewCommits> new commits have been made to the repository locally
    When the user requests to update the cache for the repository via API
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
    When the user requests to update the cache for the repository via API
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
    When the user requests to update the cache for the repository via API
    And the user requests for the cache status of the repository
    Then the cache status shows the old head revision


  Scenario Outline: All revisions before head revision are stored in CodeServer DB when the number of new commits does not exceed the batch size
    Given the repository does not have committed revisions cached by CodeCache
    #Repository was added without any commits
    And the cache status of the repository does not show a head revision
    And <numOfNewCommits> new commits have been made to the repository locally
    When the user requests to update the cache for the repository via API
    And CacheUpdateNotification messages are sent to ActiveMQ
    And CodeServer completes importing the updates to the repository
    And the user checks the commits made to the repository via CodeServer API
    Then the user sees the list of commits made to the repository
    And the list of commits includes the new head revision
    And the list of commits includes all revisions before the head revision

    Examples:
      | numOfNewCommits |
      | 1               |
      | 2               |
      | 3               |


  Scenario Outline: All revisions before head revision are stored in CodeServer DB when the number of new commits exceeds the batch size
    Given the repository does not have committed revisions cached by CodeCache
    #Repository was added without any commits
    And the cache status of the repository does not show a head revision
    And <numOfNewCommits> new commits have been made to the repository locally
    When the user requests to update the cache for the repository via API
    And CacheUpdateNotification messages are sent to ActiveMQ
    And CodeServer completes importing the updates to the repository
    And the user checks the commits made to the repository via CodeServer API
    Then the user sees the list of commits made to the repository
    And the list of commits includes the old head revision
    And the list of commits includes the new head revision
    And the list of commits includes all revisions before the head revision

    Examples:
      | numOfNewCommits |
      | 4               |
      | 7               |
