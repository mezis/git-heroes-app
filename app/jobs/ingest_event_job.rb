class IngestEventJob < BaseJob
  def perform(options = {})
    @data = Hashie::Mash.new options.fetch(:data)

    event = options.fetch(:event)
    Rails.logger.info "received event '#{event}'"
    send :"_process_#{event}"
  end

  private

  def _process_issue_comment
    # not using FindOrCreatePullRequest because we get an
    # issue hash, not a pull request hash — lacks a few fields.
    repo = FindOrCreateRepository.call(data: @data.repository).record
    pr = repo.pull_requests.find_by!(github_number: @data.issue.number)
    comment = FindOrCreateComment.call(pull_request: pr, data: @data.comment).record
    case @data.action
    when 'created', 'edited'
      nil
    when 'deleted'
      comment.destroy!
    else
      raise NotImplementedError 
    end
  end

  def _process_member
    raise NotImplementedError unless @data.action == 'added'
    
    member = FindOrCreateUser.call(data: @data.member).record
    repo = FindOrCreateRepository.call(data: @data.repository).record
    member.member_repositories << repo
  end

  def _process_membership
    raise NotImplementedError unless @data.scope == 'team'

    member = FindOrCreateUser.call(data: @data.member).record
    org = FindOrCreateOrganisation.call(data: @data.organization).record
    team = FindOrCreateTeam.call(organisation: org, data: @data.team).record

    case @data.action
    when 'added'
      return if team.users.exists?(id: member.id)
      team.users << member
    when 'removed'
      team.users.delete(member)
    else raise NotImplementedError
    end
  end

  def _process_pull_request
    # @data.action is ignored, as we alway s want to update e.g. timestamps
    repo = FindOrCreateRepository.call(data: @data.repository).record
    pr = FindOrCreatePullRequest.call(repository: repo, data: @data.pull_request).record
  end

  def _process_pull_request_review_comment
    repo = FindOrCreateRepository.call(data: @data.repository).record
    pr = FindOrCreatePullRequest.call(repository: repo, data: @data.pull_request).record
    comment = FindOrCreateComment.call(pull_request: pr, data: @data.comment).record

    case @data.action
    when 'created', 'edited'
      nil
    when 'deleted'
      comment.destroy!
    else
      raise NotImplementedError 
    end
  end

  def _process_repository
    # we ignore the action as we never want to lose repo information.
    # TODO: add a 'deleted' status for repositories.
    repo = FindOrCreateRepository.call(data: @data.repository).record
    org = FindOrCreateOrganisation.call(data: @data.organization).record
  end

  def _process_ping
    # ignore those events
  end

end
