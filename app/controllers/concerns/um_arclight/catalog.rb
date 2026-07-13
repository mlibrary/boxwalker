# frozen_string_literal: true

require "download_utility"

module UmArclight
  module Catalog
    extend ActiveSupport::Concern
    include Arclight::Catalog

    included do
      if respond_to?(:before_action)
        before_action :setup_download_utility, only: [ :ead_download, :html_download, :pdf_download ]
      end

      if respond_to?(:helper_method)
        helper_method :pdf_available?
        helper_method :ead_available?
      end

      if respond_to?(:after_action)
        after_action :add_noindex_headers
      end
    end

    def ead_download
      xml_filename = download_utility.ead_file_path
      unless xml_filename && File.exist?(xml_filename)
        render plain: "404 Not Found", status: :not_found
        return
      end

      send_file(
        xml_filename,
        filename: "#{@document.id}.xml",
        disposition: "inline",
        type: "text/xml"
      )
    end

    def html_download
      html_filename = download_utility.html_file_path
      unless html_filename && File.exist?(html_filename)
        render plain: "404 Not Found", status: :not_found
        return
      end

      headers["Content-Type"] = "text/html"
      headers["X-Accel-Buffering"] = "no" # Stop NGINX from buffering
      headers.delete("Content-Length")
      headers.delete("ETag")

      # replace m-arclight-placeholder with current asset styles/scripts
      self.response_body = Enumerator.new do |output|
        File.foreach(html_filename) do |line|
          if line.index('<style id="placeholder"></style>')
            output << helpers.stylesheet_link_tag("application", media: "all")
            output << helpers.javascript_include_tag("application")
            output << helpers.csrf_meta_tags
            next
          end
          output << line
        end
      end
    end

    def pdf_download
      pdf_filename = download_utility.pdf_file_path
      unless pdf_filename && File.exist?(pdf_filename)
        render plain: "404 Not Found", status: :not_found
        return
      end

      send_file(
        pdf_filename,
        filename: "#{@document.id}.pdf",
        disposition: "attachment",
        type: "application/pdf"
      )
    end

    def pdf_available?
      setup_download_utility
      download_utility.pdf_available?
    end

    def ead_available?
      setup_download_utility
      download_utility.ead_available?
    end

    def add_noindex_headers
      unless params[:id]
        response.headers["X-Robots-Tag"] = "noindex"
      end
    end

    private

    def setup_download_utility
      @document = search_service.fetch(params[:id])
      @download_utility = DownloadUtility.new(@document)
    end

    def download_utility
      @download_utility
    end
  end
end
