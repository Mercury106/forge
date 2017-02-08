require 'rails_helper'

describe DeploymentParser::FormParser, type: :model do
  before do
    @user = create(:user)
    @site = create(:site, user: @user)
    @version = create(:version, site: @site)

    @workdir = "#{Rails.root}/tmp/test-#{rand(10_000)}"
    FileUtils.mkdir_p(@workdir) unless File.directory?(@workdir)
    File.open("#{@workdir}/index.html", 'w+') do |f|
      html = <<EOF
        <!DOCTYPE html>
        <html>
          <head></head>
          <body>
            <form data-forge-name="Sign Up" action="http://external.com">
              <input data-forge-name="name" name="foo" type="text">
              <input data-forge-name="email" name="foo" type="email">
            </form>
            <form data-forge-name="Subscribe" action="/someurl" method="DELETE">
              <input forge-name="email" name="foo" type="text">
              <input type="submit" value="Submit">
              <input type="email">
            </form>
            <form data-forge-name="With Textarea">
              <div class="styled">
                <input forge-name="name" type="text">
                <textarea forge-name="description" name="bar"></textarea>
              </div>
            </form>
            <form class="untouched" action="http://external.com" method="GET">
              <input name="foo" type="text">
              <input type="submit" value="Submit">
              <input type="email">
            </form>
          </body>
        </html>
EOF
      f.write(html)
    end

    @parser = DeploymentParser::FormParser.new(@workdir, @version)
  end

  after do
    FileUtils.rm_rf(@workdir)
  end

  context 'when processes files' do
    before do |variable|
      @parser.parse
      result_html = File.open("#{@workdir}/index.html").read
      @result_doc = Nokogiri::HTML::Document.parse(result_html)
    end

    it 'should add actions to each forge custom form' do
      @result_doc.css('form').each do |form|
        if forge_name(form).present?
          expect(form['action']).to eq('http://localhost:3000/api/form-data')
          expect(form['method']).to eq('POST')
        end
      end
    end
  
    it 'should not touch not forge custom form' do
      @result_doc.css('form').each do |form|
        unless forge_name(form).present?
          expect(form['action']).to eq('http://external.com')
          expect(form['method']).to eq('GET')
        end
      end
    end
  
    it 'should add proper names to forge custom inputs' do
      @result_doc.css('input,textarea').each do |input|
        next if forge_name(input).blank?
        form_scope = forge_name(find_parent_form(input)).parameterize.underscore
        input_name = forge_name(input).parameterize.underscore
        field_name = "#{form_scope}[#{input_name}]"
        expect(input['name']).to eq(field_name)
      end
    end
  
    it 'should add hidden input with form name inside forge forms' do
      @result_doc.css('form').each do |form|
        if forge_name(form).present?
          input = form.children.at_css("input[name='forge_form_name'][type='hidden']")
          expect(input).to be_present
        end
      end
    end
  
    it 'should add custom class to each forge form' do
      @result_doc.css('form').each do |form|
        if forge_name(form).present?
          expect(form['class'] || '').to include('forge-custom-form')
        end
      end
    end
  
    it 'should add javascript code on page with form' do
      expect(@result_doc.at_css('script')).to be_present
    end
  end

  context 'when works with database' do
  
    it 'should create new forms' do
      expect do
        @parser.parse
      end.to change(Form, :count).by(3)
    end

    it 'should correctly generate new names' do
      @parser.parse
      expect(Form.all.map(&:name).sort).to eq(
        ['sign_up', 'subscribe', 'with_textarea']
      )
    end

    it 'should not duplicate existing forms' do
      expect do
        @parser.parse
        @parser.parse
      end.to change(Form, :count).by(3)
    end

    it 'should allow to create forms with same names but different users' do
      expect do
        @parser.parse
        # second user, parser
        user = create(:user)
        site = create(:site, user: user)
        version = create(:version, site: site)
        parser2 = DeploymentParser::FormParser.new(@workdir, version)
        parser2.parse
      end.to change(Form, :count).by(6)
    end
  end

  def forge_name(element)
    element['forge-name'] || element['data-forge-name']
  end

  def find_parent_form(input)
    return input if input.name.downcase == 'form'
    find_parent_form(input.parent)
  end
end