module ConsoleLogger
  extend self

  attr_accessor :version_id, :status_text

  def ok(message)
    send_log(message, 'ok')
  end

  def fail(message)
    send_log(message, 'fail')
  end

  def redeploy
    send_log('', 'redeploy')
  end

  def status(message, new_version_id = nil)
    self.status_text = message
    self.version_id = new_version_id if new_version_id.present?
    send_log(message, 'status')
  end

  def success(message)
    send_log(message, 'success')
  end

  def status_sent?
    status_text.present?
  end

  def send_log(message, status = 'ok', foo = 'bar')
    return if Rails.env.test?
    fail 'Set version_id first!' if version_id.blank?
    @version = Version.find(version_id) if @version.try(:id) != version_id
    return if @version.blank?

    # check if prevoius worker completed his work

    SiteLogWorker.perform_async(
      @version.site_id,
      JSON.generate(
        {
          version_id: @version.id,
          message: message,
          status: status,
          time: "[#{Time.now.strftime("%H:%M:%S")}]"
        }
      )
    )
  end
end
