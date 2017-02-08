# encoding: utf-8

class VersionFileCarrierWaveUploadHandler < CarrierWave::Uploader::Base
  include CarrierWave::Compatibility::Paperclip
  storage :fog
end
