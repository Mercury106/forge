require 'rails_helper'

describe Form, type: :model do
  before do
    @form = build(:form)
  end

  it 'has a valid factory' do
    expect(@form).to be_valid
  end

  it 'should always have a human name' do
    @form.human_name = ""
    expect(@form).to be_invalid
  end

  it 'should automatically generate name from human_name' do
    @form.name = ""
    @form.save
    expect(@form.name).to eq(@form.human_name.parameterize.underscore)
  end
end
