class Repository < ApplicationModel
  belongs_to :owner, polymorphic: true, counter_cache: :owned_repositories_count
  has_many :user_repositories, dependent: :destroy
  has_many :users, through: :user_repositories, inverse_of: :member_repositories
  has_many :pull_requests, dependent: :destroy, inverse_of: :repository

  validates_presence_of :owner, :name, :github_id

  scope :enabled, -> { where(enabled:true) }

  def to_param
    name
  end

  def full_name
    "#{owner.login}/#{name}"
  end

  scope :visible_by, ->(user) do
    repo_t = Repository.arel_table
    org_t = Organisation.arel_table
    org_user_t = OrganisationUser.arel_table
    user_repo_t = UserRepository.arel_table

    join_user_repo =
        repo_t.
          join(user_repo_t, Arel::Nodes::OuterJoin).
          on(
            repo_t[:id].eq(user_repo_t[:repository_id]).
            and(
              user_repo_t[:user_id].eq(user.id)
            )
          ).
          join_sources
    join_org_user =
        repo_t.
          join(org_t, Arel::Nodes::OuterJoin).
          on(
            repo_t[:owner_id].eq(org_t[:id]).
            and(
              repo_t[:owner_type].eq('Organisation')
            )
          ).
          join(org_user_t, Arel::Nodes::OuterJoin).
          on(
            org_t[:id].eq(org_user_t[:organisation_id]).
            and(
              org_user_t[:user_id].eq(user.id)
            )
          ).
          join_sources
    is_repo_public = 
      repo_t[:public].eq(true)
    is_user_repo_member = 
      user_repo_t[:id].not_eq(nil)
    is_user_repo_org_member =
      org_user_t[:id].not_eq(nil)
    is_user_repo_owner =
      repo_t[:owner_id].eq(user.id).
      and(
        repo_t[:owner_type].eq('User')
      )

    Repository.
      joins(join_user_repo).
      joins(join_org_user).
      where(
        is_user_repo_owner.
        or(is_user_repo_org_member).
        or(is_user_repo_member).
        or(is_repo_public)
      )
  end
end
