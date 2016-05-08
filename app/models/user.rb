class User < ActiveRecord::Base
  has_many :organisation_users, dependent: :destroy
  has_many :organisations, through: :organisation_users
  has_many :user_repositories, dependent: :destroy
  has_many :member_repositories, class_name: 'Repository', through: :user_repositories, source: :repository, inverse_of: :users
  has_many :owner_repositories, class_name: 'Repository', as: :owner, dependent: :destroy
  has_many :created_pull_requests, class_name: 'PullRequest', foreign_key: :created_by_id, dependent: :destroy
  has_many :merged_pull_requests, class_name: 'PullRequest', foreign_key: :merged_by_id, dependent: :destroy
  has_many :comments, dependent: :destroy, inverse_of: :user
  has_many :team_users, dependent: :destroy
  has_many :teams, through: :team_users
  has_many :scores, class_name: 'OrganisationUserScore', dependent: :destroy

  validates_presence_of :github_id, :login

  def to_param
    login
  end

  # roles, to be extracted

  def role_at?(record)
    case record
    when Organisation
      organisation_users.to_a.find { |ou| ou.organisation_id == record.id }&.role
    when Team
      team_users.to_a.find { |tu| tu.team_id == record.id }&.role
    else
      raise NotImplementedError
    end
  end
end
