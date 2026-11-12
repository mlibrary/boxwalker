class UmOddMetadataFieldComponent < Blacklight::MetadataFieldComponent
  def heading
    @field.document["odd_heading_ssm"].first
  end
end
