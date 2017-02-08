require 'rails_helper'
include WebMock::API

describe WebhookTrigger, type: :model do
  
  it 'should have valid factory' do
    expect(build(:webhook_trigger)).to be_valid
  end

  context 'when prepares request' do
    before do
      @wt = build(:webhook_trigger)
    end

    it 'should correctly parse webhook params' do
      @wt.parameters = "one=two\nthird param=bird"
      expect(@wt.params).to eq('one' => 'two', 'third param' => 'bird')
    end
  
    it 'should insert variables for form submission webhook' do
      @form_data = create(:form_datum)
      @wt.arguments = { 'form_datum_id' => @form_data.id }
      @wt.parameters = 'text=user {{name}} with {{email}}'
      expect(@wt.params).to eq(
        'text' => "user #{@form_data.data['name']} with #{@form_data.data['email']}"
      )
    end
  
    it 'should not allow to use getforge.com as webhook url' do
      @wt.url = 'getforge.com'
      expect(@wt).to be_invalid
    end

    it 'should add "http://" to webhook url' do
      @wt.url = 'google.com'
      expect(@wt.full_url).to eq('http://google.com')
    end

    it 'should not add "http://" to webhook url' do
      @wt.url = 'https://google.com'
      expect(@wt.full_url).to eq('https://google.com')
    end
  end

  context 'when sends request' do
    before do
      @wt = build(
        :webhook_trigger,
        url: 'examplehook.com/samplerequest',
        http_method: 'POST',
        parameters: 'key=forge'
      )
    end

    it 'should send webhook' do
      stub_request(:post, 'http://examplehook.com/samplerequest')
        .with(body: {'key'=>'forge'},
              headers: {'Accept'=>'*/*'})
        .to_return(status: 200, body: 'samplerequest', headers: {})

      response, data = @wt.send_hook(0)
      expect(response.body).to eq('samplerequest')
    end

    # Actually, not very useful. Should be replaced and pay attention to response codes, not exceptions
    context 'when request failed' do
      before do
        stub_request(:post, 'http://examplehook.com/failedrequest')
          .with(body: {'key'=>'forge'},
                headers: {'Accept'=>'*/*'})
          .to_raise(StandardError)
      end
    
      it 'should enqueue a job for repeat webhook if request was failed' do  
        @wt.url = 'examplehook.com/failedrequest'
        @wt.send_hook(0)
        expect(WebhookTriggerWorker).to have_enqueued_job(@wt.event, @wt.site_id, 1)
      end
    
      it 'should repeat request webhook no more 5 times' do
        @wt.url = 'examplehook.com/failedrequest'
        @wt.send_hook(5)
        expect(WebhookTriggerWorker).not_to have_enqueued_job(@wt.event, @wt.site_id, 6)
      end
    end
  end
end
