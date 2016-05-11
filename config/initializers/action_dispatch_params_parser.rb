# Skip parameter parsing for webhooks.
# http://www.jkfill.com/2015/02/21/skip-automatic-params-parsing/

module AddSkipParamsParsingOption
  SKIPPED_PATHS = %w[
    /_events
  ]

  private

  def parse_formatted_parameters(env)
    request = ActionDispatch::Request.new(env)
    if SKIPPED_PATHS.include?(request.path)
      ::Rails.logger.info "Skipping params parsing for path #{request.path}"
      nil
    else
      super(env)
    end
  end
end

ActionDispatch::ParamsParser.send :prepend, AddSkipParamsParsingOption
