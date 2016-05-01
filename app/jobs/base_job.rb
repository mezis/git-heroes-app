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
    ensure
      Rails.logger.info "clearing stats for #{self.class}"
      job_stats.destroy
    end
  end

  rescue_from(StandardError) do |e|
    Rails.logger.warn "failure in #{self.class}: #{e.class} (#{e.message}}"
    Rails.logger.debug e.backtrace.take(5).join("\n")
    if job_stats.attempts > max_attempts
      Rails.logger.info "final failure"
      raise e
    end
    Rails.logger.info "retrying #{job_stats.job_class} (#{job_stats.attempts} attempts)"
    retry_job wait: 5.seconds
    job_stats.status = 'retrying'
    job_stats.save!
  end

  protected

  def max_attempts
    5
  end


  private

  def job_stats
    @job_stats ||= JobStats.find_or_initialize_by(job: self)
  end

end
