class String
  def encode_utf8
    self.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end
end