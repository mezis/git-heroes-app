# Wraps methods, setting the time zone and business time zone.
# Override time_zone in recipients,
module WithZoneConcern
  extend ActiveSupport::Concern

  protected

  def with_time_zone(zone)
    Time.use_zone(zone) do
      WorkingHours::Config.with_config(time_zone: zone) do
        yield
      end
    end
  end
end
