class StatusService
  def self.service_status(service, environment_slugs: ServiceEnvironment.all_keys)
    environment_slugs.map do |env_slug|
      last_status(service: service, environment_slug: env_slug) || \
        empty_check(service: service, environment_slug: env_slug)
    end
  end

  # TODO: implement properly when we have services running
  def self.last_status(service:, environment_slug:)
    ServiceStatusCheck.where( service_id: service.id,
                              environment_slug: environment_slug)
                      .order('timestamp desc')
                      .first
  end

  def self.check(service:, environment_slug:, timeout: 5)
    ServiceStatusCheck.execute!(
      environment_slug: environment_slug,
      service: service,
      timeout: timeout
    )
  end

  def self.check_in_parallel( service:,
                              environment_slugs: ServiceEnvironment.all_keys,
                              timeout: 5)
    ServiceStatusCheck.execute_many!(
      service: service,
      environment_slugs: environments,
      timeout: timeout
    )

  end

  private

  def self.empty_check(service:, environment_slug:)
    check = ServiceStatusCheck.new(
      service: service,
      environment_slug: env_slug
    )
    check.url = check.url_from_env_and_service
    check
  end
end
