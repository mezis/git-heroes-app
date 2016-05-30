module PermanentCookieConcern

  def permanent_cookies
    cookies.permanent.encrypted
  end

  def set_permanent_cookie
    return unless @write_permanent_cookie
    Rails.logger.info 'writing cookie'
    Rails.logger.info @permanent_cookie_data.to_json
    permanent_cookies['_ghdata'] = @permanent_cookie_data.to_json
  end

  def permanent_cookie
    @permanent_cookie_data ||= begin
      @write_permanent_cookie = true
      Rails.logger.info 'reading cookie'
      Rails.logger.info cookies.permanent.encrypted['_ghdata']
      Hashie::Mash.new(JSON.parse(permanent_cookies['_ghdata']))
    rescue TypeError, JSON::ParserError
      Hashie::Mash.new
    end
  end

end
