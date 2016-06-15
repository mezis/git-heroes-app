class BaseJob < ActiveJob::Base
  queue_as :default

  # loner

  around_enqueue do |job, block|
    job_stats.lock do |j|
      if j.duplicate?
        logger.info "Not enqueuing duplicate #{self.class}"
      else
        j.update_attributes! status: 'queued'
        block.call
      end
    end
  end

  around_perform do |job, block|
  job_stats.attempts += 1
    job_stats.update_attributes! status: 'running'
    block.call
    job_stats.complete!
  end


  rescue_from(StandardError) do |e|
    logger.warn "Failure in #{self.class}: #{e.class} (#{e.message}}"
    logger.debug e.backtrace.take(5).map(&:indent).join("\n")
    Appsignal.add_exception(e)

    if job_stats.attempts > max_attempts
      logger.info "(final failure)"
      job_stats.complete!
    else
      logger.info "Retrying #{job_stats.job_class} (#{job_stats.attempts} attempts so far)"

      job_stats.update_attributes! status: 'retrying'
      retry_job wait: (2**job_stats.attempts * 10).seconds
    end
  end

  rescue_from(GithubClient::Throttled) do |e|
    logger.warn "Throttled in #{self.class}, retrying later (#{e.class})"

    job_stats.update_attributes! status: 'throttled'
    retry_job wait_until: (e.retry_at + 5.minutes)
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
