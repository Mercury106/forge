require 'rails_helper'

describe FormDatum, type: :model do
  before do
    @form_datum = build(:form_datum)
  end

  it 'has a valid factory' do
    expect(@form_datum).to be_valid
  end

  it 'should keep keep hash data inside' do
    some_data = { email: 'some@mail.com', name: 'Mike' }
    @form_datum.data = some_data
    @form_datum.save
    expect(FormDatum.find(@form_datum.id).data).to eq(some_data)
  end
end
