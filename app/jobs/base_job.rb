class BaseJob < ActiveJob::Base
  queue_as :default

  # loner

  around_enqueue do |job, block|
    job_stats.lock do |j|
      if j.duplicate?
        Rails.logger.info "not enqueuing duplicate #{self.class}"
      else
        block.call
        j.status = 'queued'
        j.save!
      end
    end
  end

  around_perform do |job, block|
    begin
      job_stats.attempts += 1
      job_stats.status = 'running'
      job_stats.save!
      block.call
    rescue StandardError => e
      Rails.logger.warn "failure in #{self.class}: #{e.class} (#{e.message}}"
      Rails.logger.warn "(final failure)" if job_stats.attempts > max_attempts
      Rails.logger.debug e.backtrace.take(5).map(&:indent).join("\n")
      raise
    ensure
      Rails.logger.info "clearing stats for #{self.class}"
      job_stats.destroy
    end
  end

  rescue_from(GithubClient::Throttled) do |e|
    Rails.logger.warn "throttled in #{self.class}, retrying later"
    retry_job wait_until: e.message
    job_stats.status = 'throttled'
    job_stats.save!
  end

  rescue_from(StandardError) do |e|
    Rails.logger.warn "failure in #{self.class}: #{e.class} (#{e.message}}"
    if job_stats.attempts > max_attempts
      Rails.logger.info "final failure"
      raise e
    else
      Rails.logger.debug e.backtrace.take(5).join("\n")
    end
    Rails.logger.info "retrying #{job_stats.job_class} (#{job_stats.attempts} attempts so far)"
    retry_job wait: (2**job_stats.attempts * 10).seconds
    job_stats.status = 'retrying'
    job_stats.save!
  end

  protected

  def max_attempts
    10
  end


  private

  def job_stats
    @job_stats ||= JobStats.find_or_initialize_by(job: self)
  end

end
