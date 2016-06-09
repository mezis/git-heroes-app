class BaseJob < ActiveJob::Base
  queue_as :default

  # loner

  around_enqueue do |job, block|
    job_stats.lock do |j|
      if j.duplicate?
        logger.info "Not enqueuing duplicate #{self.class}"
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
    ensure
      logger.info "Clearing stats for #{self.class}"
      job_stats.complete!
    end
  end


  rescue_from(StandardError) do |e|
    logger.warn "Failure in #{self.class}: #{e.class} (#{e.message}}"
    logger.debug e.backtrace.take(5).map(&:indent).join("\n")
    Appsignal.add_exception(e)
    if job_stats.attempts > max_attempts
      logger.info "(final failure)"
    else
      logger.info "Retrying #{job_stats.job_class} (#{job_stats.attempts} attempts so far)"
      retry_job wait: (2**job_stats.attempts * 10).seconds
      job_stats.status = 'retrying'
      job_stats.save!
    end
  end

  rescue_from(GithubClient::Throttled) do |e|
    logger.warn "Throttled in #{self.class}, retrying later (#{e.class})"
    retry_job wait_until: (e.retry_at + 5.minutes)
    job_stats.status = 'throttled'
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
