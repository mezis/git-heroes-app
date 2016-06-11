class JobStatsDecorator < SimpleDelegator

  def enqueued_at
    Time.at(super * 1e-9)
  end

  def completion
    left = descendants_left
    max  = descendants_max
    if max > 0
      "(%d/%d)" % [ (max-left), max ]
    else
      nil
    end
  end

  def title
    TITLES.fetch(job_class, 'Updating data')
  end

  private

  TITLES = {
    'EmailUserJob'                      => 'Sending emails',
    'IngestEventJob'                    => 'Processing new event',       
    'InitialSyncJob'                    => 'Initial sync with Github',
    'RewardJob'                         => 'Creating rewards',
    'ScoreUsersJob'                     => 'Updating scores',
    'UpdateOrganisationTeamsJob'        => 'Refreshing teams',
    'UpdateOrganisationUsersJob'        => 'Refreshing org members',
    'UpdatePullRequestJob'              => 'Refreshing pull request',
    'UpdateRepositoryPullRequestsJob'   => 'Refreshing pull requests',
    'UpdateTeamUsersJob'                => 'Refreshing team',
    'UpdateUserOrganisationsJob'        => 'Refreshing orgs',
    'UpdateUserRepositoriesJob'         => 'Refreshing repos',
    'UpdateWebhookJob'                  => 'Checking webhook',
    }
end
