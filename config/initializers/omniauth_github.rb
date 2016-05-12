Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'],
    scope: %w[
      user:email
      repo
      read:org
      admin:org_hook
  ].join(',')
end
