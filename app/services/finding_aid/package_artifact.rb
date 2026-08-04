# frozen_string_literal: true

module FindingAid
  class PackageArtifact
    FORMATS = %w[html pdf].freeze

    def self.call(identifier, format)
      unless FORMATS.include?(format)
        raise ::Box::GenerateError, identifier, "Unsupported format requested: #{format}"
      end

      convert(identifier, format)
    end

    def self.convert(identifier, format)
      artifact = ::Box::Package::Generator.new identifier: identifier
      format == "html" ? artifact.generate_html : artifact.generate_pdf
    rescue => error
      raise ::Box::GenerateError, identifier, error.to_s
    end

    private_class_method :convert
  end
end
