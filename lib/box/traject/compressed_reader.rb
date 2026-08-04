# frozen_string_literal: true

module Box
  def self.finding_aid_data
    Rails.root.join("data").to_s
  end

  module Traject
    # Provides a Traject Reader for XML Documents which removes the namespaces
    # and squishes/compresses/normalizes consecutive spaces or newline characters.
    # DUL CUSTOM modified version of:
    # https://github.com/projectblacklight/arclight/blob/master/lib/arclight/traject/nokogiri_namespaceless_reader.rb
    class CompressedReader < ::Traject::NokogiriReader
      # Overrides the #each method (which is used for iterating through each Document)
      # @param args
      # @see ::Traject::NokogiriReader#each
      # @see Enumerable#each
      def each(*args)
        return to_enum(:each, *args) unless block_given?

        super do |doc|
          new_doc = doc.dup
          new_doc.remove_namespaces!
          compressed_doc = new_doc.xpath("/ead").to_s.strip.gsub!(/[[:space:]]+/, " ")
          yield Nokogiri::XML(compressed_doc)
        end
      end
    end
  end
end
