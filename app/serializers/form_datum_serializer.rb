class FormDatumSerializer < ApplicationSerializer

  attributes :id, :user_id, :form_id, :data_array, :timestamp

  def data_array
   object.data.to_a
  end

  def timestamp
    object.created_at.strftime("%m/%d/%Y  %I:%M%p")

  end

end