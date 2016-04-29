Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'],
    scope: %w[
      user:email
      repo:status
      read:org
      read:repo_hook
      write:repo_hook
      admin:org_hook
  ].join(',')
end
