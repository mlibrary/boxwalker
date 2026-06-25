# frozen_string_literal: true

require "traject"
require "traject/nokogiri_reader"
require "traject_plus"
require "traject_plus/macros"
require "arclight"

# Load the arclight gem's default EAD2 traject configuration first.
# All additions and modifications below are kept separate from the upstream defaults.
load_config_file Arclight::Engine.root.join("lib/arclight/traject/ead2_config.rb").to_s

# ==========================================
# Boxrunner-specific additions / overrides
# ==========================================

to_field 'access_subjects_ssim', extract_xpath('/ead/archdesc/controlaccess', to_text: false) do |_record, accumulator|
  accumulator.map! do |element|
    # DUL CUSTOMIZATION: pull out genreform into its own field
    %w[subject function occupation].map do |selector|
      element.xpath(".//#{selector}").map(&:text)
    end
  end.flatten!
end

to_field 'formats_ssim', extract_xpath('/ead/archdesc/controlaccess/genreform|/ead/archdesc/controlaccess/controlaccess/genreform')
to_field 'formats_ssm' do |_record, accumulator, context|
  accumulator.concat Array.wrap(context.output_hash['formats_ssim'])
end
