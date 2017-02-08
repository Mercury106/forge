require 'net/http'
class WebhookTrigger < ActiveRecord::Base
  validates :user_id, :site_id, :event, :url, :http_method, presence: true
  validates :event, :url, :http_method, length: { maximum: 255 }
  validate :external_url

  belongs_to :user
  belongs_to :site

  attr_accessor :arguments

  def send_hook(repeat, args = {})
    self.arguments = args
    repeat += 1
    begin
      uri = URI.parse(full_url)
      case http_method
      when 'GET'
        uri.query = URI.encode_www_form(params) if params.present?
        resp, data = Net::HTTP.get(uri)
      when 'POST'
        resp, data = Net::HTTP.post_form(uri, params)
      end
      # TODO do some actions with response
    rescue Exception => e
      if repeat <= 5
        WebhookTriggerWorker.perform_async(event, site_id, repeat)
      end
      Rails.logger.error(e.message)
    end
  end

  def params
    return {} if parameters.blank?
    insert_variables(parameters)
      .gsub("\r", '') # remove windows-like newlines
      .split("\n")    # split text into lines
      .map { |x| x.split('=') } # split every element on arrays: [key, value]
      .to_h 
  end

  def full_url
    url =~ /\Ahttps?:\/\// ? url.strip : "http://#{url.strip}"
  end

  def insert_variables(parameters)
    parsed_parameters = parameters.dup
    parameters.scan(/\{\{[\w_]+\}\}/).each do |key|
      parsed_parameters.gsub!(key, variables(key.gsub(/[\{\}]/, '').strip))
    end
    parsed_parameters
  end

  def variables(variable_key)
    @source1 ||= YAML.load_file('config/webhooks.yml')['variables']
    return eval(@source1[variable_key]).to_s if @source1.keys.include?(variable_key)

    if arguments['form_datum_id'].present?
      @source2 ||= FormDatum.find(arguments['form_datum_id']).data || {}
      (@source2[variable_key] || '').gsub(/[=\n\r]/, ' ')# remove forbidden symbols
    else
      "-"
    end
  end

  def external_url
    if full_url.strip =~ /\Ahttps?:\/\/getforge.com/
      errors.add(:base, 'You cannot use this url for webhook.')
    end
  end

  def files_list(modification_type)
    modification_type = modification_type.to_sym
    diff = site.current_version.truncated_diff || {}
    if diff.keys.include?(modification_type)
      diff[modification_type].join(', ')
    else
      "no files."
    end
  end
end
