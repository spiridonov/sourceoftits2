# encoding: utf-8

class PreviewUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  #include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/tits_preview/#{model.id}"
  end

  # Process files as they are uploaded:
  process :resize_to_fit => [150, 150]

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  #def extension_white_list
  #   %w(jpg jpeg gif png)
  #end

end
