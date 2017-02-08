class DeploymentParser::FormParser < DeploymentParser
  def parse
    # log '[form parser] procesing forms'
    html_files.each do |filename|
      @doc = Nokogiri::HTML::Document.parse(read(filename))
      process_forms
      if @forge_form_exists
        insert_javascript
        write(filename, @doc.to_html)
      end
    end
  end

  private

  def html_files
    files.select do |filename|
      filename.end_with?('.html') || filename.end_with?('.htm')
    end
  end

  def process_forms
    @doc.css('form').each do |form|
      next unless forge_name(form).present?
      @forge_form_exists = true
      fields = []
      map_inputs(form).each do |element|
        fields << process_single_input!(element, forge_name(form))
      end
      process_single_form!(form)
      create_form_record!(form, fields.compact)
    end
  end

  def process_single_input!(element, form_name)
    name = forge_name(element)
    return if name.blank?
    form_scope = form_name.parameterize.underscore
    element['name'] = "#{form_scope}[#{name.parameterize.underscore}]"
    name.parameterize.underscore
  end

  def process_single_form!(form)
    form['action'] = if Rails.env.production?
                       "#{ENV['PRODUCTION_DOMAIN']}/api/form-data"
                     else
                       'http://localhost:3000/api/form-data'
                     end
    form['method'] = 'POST'
    form['class'] = ['forge-custom-form', form['class']].compact.join(' ')
    hidden_input = @doc.create_element('input',
                                       type: 'hidden',
                                       name: 'forge_form_name',
                                       value: forge_name(form))
    form.add_child(hidden_input)
    if form.at_css('input[type=submit]').blank?
      sub = @doc.create_element('input', type: 'submit', style: 'display:none')
      form.add_child(sub)
    end
  end

  def create_form_record!(html_form, fields)
    # log "[form parser] creating record for «#{forge_name(html_form)}»"
    return if @version.nil? # need for rspec tests
    form_scope = forge_name(html_form).parameterize.underscore
    form = Form.find_by(name: form_scope, site_id: @version.site_id)
    if form.present?
      form.update_attribute('fields', fields)
    else
      Form.create(
        user_id: @version.site.user_id,
        site_id: @version.site_id,
        name: form_scope,
        human_name: forge_name(html_form),
        fields: fields
      )
    end
  end

  def forge_name(element)
    element['data-forge-name'] || element['forge-name']
  end

  def map_inputs(form)
    inputs = []
    form.children.each do |child|
      if child.children.count > 0 && child.name.downcase != 'select'
        inputs.concat(map_inputs(child))
      else
        inputs << child if child.name.downcase =~ /input|select|textarea/
      end
    end
    inputs
  end

  def insert_javascript
    # log '[form parser] inserting form handlers'
    javascript = <<JS
  var forms = document.getElementsByClassName('forge-custom-form');
  for (var i = 0; i < forms.length; i++) {
    var form = (forms[i]);
    form.addEventListener('submit', function(e){
      e.preventDefault();
      forgeFormXmlhttpRequest(form.action, new FormData(form), function(response){
        if (response.action == 'message'){
          alert(response.text);
        }
        else if (response.action == 'redirect'){
          document.location.href = response.url;
        }
      });
      return false;
    });
  }
  function forgeFormXmlhttpRequest(url, data, callback)
  {
    if (window.XMLHttpRequest) { var xhReq = new XMLHttpRequest(); }
    else { var xhReq = new ActiveXObject("Microsoft.XMLHTTP"); }
    xhReq.open('POST', url, true);
    xhReq.setRequestHeader("X-Requested-With", "XMLHttpRequest");
    xhReq.send(data);
    xhReq.onreadystatechange = function() {
      if (xhReq.readyState == 4) {
        callback(JSON.parse(xhReq.responseText))
      }
    };
  }
JS
    script = @doc.create_element('script', javascript)
    position = @doc.at_css('body') || @doc.at_css('form')
    position << script if position
  end
end
