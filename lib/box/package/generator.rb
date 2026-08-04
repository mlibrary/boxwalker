# frozen_string_literal: true

require "arclight"
require "benchmark"
require "json"
require "fileutils"
require "nokogiri"
require "deprecation"
require "uri"
require "net/http"
require "open3"

Deprecation.default_deprecation_behavior = :silence

module Box
  module Package
    # Generate HTML and PDF packages of finding aids
    class Generator # rubocop:disable Metrics/ClassLength
      COMPONENT_FIELDS = %w[
        id
        parent_ssi
        parent_ssim
        ref_ssi
        ref_ssm
        ead_ssi
        abstract_tesim
        scopecontent_tesim
        component_level_isim
        normalized_title_ssm
        level_ssm
        unitid_ssm
        odd_tesim
        bioghist_tesim
        physloc_tesim
        materialspec_tesim
        total_digital_object_count_isim
        digital_objects_ssm
        containers_ssim
        repository_ssm
      ].freeze

      attr_accessor :identifier, :doc, :fragment, :collection, :session

      def initialize(identifier:)
        @identifier = identifier
        @collection = nil
        @session = ActionDispatch::Integration::Session.new(Rails.application)
        @session.host = "findingaids.lib.umich.edu"
        @session.https!(true)
        @fonts = []
      end

      def build_html
        components = []
        elapsed_time = Benchmark.realtime do
          @collection = fetch_doc(identifier)
          components = fetch_components(@collection.eadid)
        end

        response = get("/catalog/#{@collection.id}")
        @doc = Nokogiri::HTML5(response.body)

        puts "UM-Arclight generate package : #{collection.id} : fetch components (in #{elapsed_time.round(3)} secs)."
        elapsed_time = Benchmark.realtime do
          @fragment = render_fragment(
            collection: collection,
            components: components
          )

          update_navigation_links
          update_package_html
        end
        puts "UM-Arclight generate package : #{collection.id} : build HTML (in #{elapsed_time.round(3)} secs)."
      end

      def generate_html
        build_html

        output_filename = generate_output_filename(".html")
        FileUtils.makedirs(File.dirname(output_filename)) unless Dir.exist?(File.dirname(output_filename))

        # serialize the viewable HTML
        File.open(output_filename, "w") do |f|
          f.puts doc.serialize
        end

        generate_pdf_html
      end

      def build_pdf_html
        # build the source in tmp
        FileUtils.mkdir_p(working_path_name)
        Dir.chdir(working_path_name) do
          FileUtils.mkdir_p("assets")

          elapsed_time = Benchmark.realtime do
            update_package_html_pdf
            update_package_styles_pdf
            update_package_scripts_pdf
            # set the media
            doc.root["data-media"] = "print"
          end
          puts "UM-Arclight generate package: #{collection.id} : update HTML for PDF (in #{elapsed_time.round(3)} secs)."
        end
      end

      def generate_pdf_html
        build_pdf_html
        local_html_filename = generate_local_html_filename # "#{collection.document_id}.local.html"
        File.open(local_html_filename, "w") do |f|
          f.puts doc.serialize
        end
      end

      def build_pdf_prereq
        @collection = fetch_doc(identifier)
        local_html_filename = generate_local_html_filename
        if File.exist?(local_html_filename)
          warn "-- using #{local_html_filename}"
        else
          generate_html
        end
      end

      def generate_pdf # rubocop:disable Metrics/MethodLength
        build_pdf_prereq

        local_html_filename = generate_local_html_filename
        output_filename = generate_output_filename(".pdf")
        FileUtils.mkdir_p(File.dirname(output_filename))

        Dir.chdir working_path_name do
          elapsed_time = Benchmark.realtime do
            cmd = [
              "wkhtmltopdf",
              "--page-size", "Letter",
              "--enable-internal-links",
              "--enable-local-file-access",
              "--margin-top", "20mm",
              "--margin-bottom", "20mm",
              "--margin-right", "20mm",
              "--margin-left", "20mm",
              local_html_filename,
              output_filename
            ]
            stdout_and_stderr, process_status = Open3.capture2e(*cmd)

            if process_status.success?
              puts stdout_and_stderr
            else
              raise Box::GenerateError, identifier, stdout_and_stderr.to_s
            end
          end

          puts "UM-Arclight generate package: #{collection.id} : PDF render (in #{elapsed_time.round(3)} secs)."
        end
      end

      private

      def generate_output_filename(ext)
        filename = File.join(finding_aid_data_path, "pdf", collection_repository_id, "#{collection.document_id}#{ext}")
        filename = File.join(Rails.root, filename) if filename.start_with?("./")
        filename
      end

      def working_path_name
        # File.join(Rails.root, "tmp", "pdf")
        File.writable?(File.join(finding_aid_data_path)) ?
          File.join(finding_aid_data_path, "pdf", "tmp", collection_repository_id) :
          File.join(Rails.root, "tmp", "pdf")
      end

      def finding_aid_data_path
        ENV.fetch("FINDING_AID_DATA", Rails.root.join("data").to_s)
      end
      # TODO: this is a hack to get the repository_id from the collection.
      def collection_repository_id
        return collection.repository_id if collection.respond_to?(:repository_id)

        Array(collection["repository_ssm"]).first.to_s.parameterize.presence || "repository"
      end

      def generate_local_html_filename
        File.join(working_path_name, "#{@collection.document_id}.local.html")
      end

      def get(url)
        if url.start_with?("/assets/") && File.exist?(File.join(Rails.root, "public", url))
          contents = File.read(File.join(Rails.root, "public", url))
          response = OpenStruct.new
          response.body = contents
          return response
        end
        session.get(url)
        session.response
      end

      def fetch_doc(id)
        params = {
          fl: "*", # COMPONENT_FIELDS.join(','),
          q: [ "id:#{id}" ],
          start: 0,
          rows: 1
        }
        response = index.search(params)
        response.documents.first
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def fetch_components(id)
        params = {
          fl: "*",
          q: [ "ead_ssi:#{id}" ],
          sort: "sort_ii asc, title_sort asc",
          start: 0,
          rows: 1000
        }
        components = []
        tmp = {}
        tmp_map = {}
        component_mapper = {}
        response = index.search(params)
        start = 0
        while response.documents.present?
          puts "UM-Arclight generate package : harvesting components : #{collection.id} : #{start} / #{response.total}"
          response.documents.each do |doc|
            if doc.component_level.nil?
              # ignore the collection doc
              next
            end

            tmp[doc.component_level] = [] if tmp[doc.component_level].nil?
            tmp[doc.component_level] << doc
            tmp_map[doc.reference] = doc
          end
          start += 1000
          params[:start] = start
          response = index.search(params)
        end

        return [] if tmp.keys.empty?

        # now attach child components
        tmp.keys.sort.each do |component_level|
          next if component_level == 1

          tmp[component_level].each do |doc|
            # find the parent_doc because nothing is easy
            parent_doc = nil
            doc.parent_ids_keyed.reverse.each do |parent_id|
              if tmp_map[parent_id]
                parent_doc = tmp_map[parent_id]
                break
              end
            end

            component_mapper[parent_doc.reference] = [] if component_mapper[parent_doc.reference].nil?
            component_mapper[parent_doc.reference].unshift doc
          end
        end

        # now flatten this into components?
        queue = [ tmp[1] ].flatten
        until queue.empty?
          doc = queue.shift
          components << doc
          component_mapper.fetch(doc.reference, []).each do |v|
            queue.unshift v
          end
        end

        components
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def render_fragment(variables)
        fragment_html = CatalogController.renderer.render(
          template: "arclight/fragments/fragment",
          assigns: variables,
          layout: false,
          formats: [ :html ]
        )
        Nokogiri::HTML5(fragment_html)
      end

      def update_navigation_links
        doc.css("#about-collection-nav a").each do |link|
          href = link["href"]
          link["href"] = "#" + href.split("#").last
        end
      end

      # rubocop:disable Metrics/AbcSize
      def update_package_html
        last_style_el = doc.xpath('/html/head/link[@rel="stylesheet"]').last
        last_style_el.add_next_sibling(fragment.css("#utility-styles").first)
        @chunks = doc.fragment
        asset_links = doc.xpath('/html/head/link[starts-with(@href, "/assets")]')
        # add the placeholder
        asset_links.first.add_previous_sibling '<style id="placeholder"></style>'

        asset_links.each do |el|
          # @chunks << el
          el.unlink
        end

        # @chunks << doc.xpath('/html/head/script[starts-with(@src, "/assets")]')
        doc.xpath('/html/head/script[starts-with(@src, "/assets")]').each do |el|
          el.unlink
        end

        doc.css('meta[name="csrf-param"]').first&.unlink
        doc.css('meta[name="csrf-token"]').first&.unlink

        doc.css("#summary dl").first << fragment.css("dl#ead_author_block dt,dl#ead_author_block dd")
        if (contents_el = doc.css("div.al-contents").first)
          contents_el.replace(fragment.css("div.al-contents-ish").first)
        end
        doc.css(".card-img").first.remove
        doc.css("#navigate-collection-toggle").first.remove
        if (tree_el = doc.css("#context-tree-nav .tab-pane.active").first)
          tree_el.inner_html = ""
          tree_el << fragment.css("#toc").first
        end
      end
      # rubocop:enable Metrics/AbcSize

      def update_package_html_pdf
        build_package_html_toc
        doc.css("m-website-header").first.replace(fragment.css("header").first)
        doc.css("footer").first.remove
        doc.css("div.x-printable").remove
        doc.css("body a[href]").each do |link|
          if link["href"].start_with?("/")
            link["href"] = File.join("https://findingaids.lib.umich.edu/", link["href"])
          end
          if link["href"].include?("%5B")
            # gambling
            link["href"] = CGI.unescape(link["href"])
          end
        end
        # ARC-114 Chinese characters were missing (Hack to include font as fallback font)
        doc.css("body").first << '<div style="font-family: UnifontExMono; visibility: hidden; font-size: 1px;">x</div>'
      end

      def build_package_html_toc
        # rearrange the various contents links
        doc.css(".access-preview-snippet").first.inner_html = '<div id="toc"><ul class="list-unbulleted"></ul></ul>'
        current_ul = doc.css("#toc ul").first
        contents_li = nil
        doc.css("#about-collection-nav li.nav-item").each do |li|
          current_ul << li
          contents_li = li if li.css("a").first["href"] == "#contents"
        end
        return unless contents_li

        if (contents_ul = doc.css("#sidebar #toc > ul").first)
          contents_ul["class"] = "list-unbulleted"
          contents_li << contents_ul
        end
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def update_package_styles_pdf
        # restore the stylesheet links for the PDF
        placeholder_el = doc.css("style#placeholder").first

        doc.css('link[rel="stylesheet"][href^="https://"]').each do |link|
          link.unlink
        end

        # add links for pdf
        placeholder_el.add_next_sibling '<link href="https://fonts.googleapis.com/css2?family=Mulish:ital,wght@0,400;0,500;0,600;0,700;0,800;1,400;1,500;1,600;1,700;1,800&display=swap" rel="stylesheet">'
        placeholder_el.add_next_sibling '<link href="https://fonts.googleapis.com/css?family=Crimson+Text|Muli:400,600,700" rel="stylesheet">'
        placeholder_el.add_next_sibling '<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">'
        # TODO: another hack to hide the AssetNotFound error
        begin
          placeholder_el.add_next_sibling CatalogController.helpers.stylesheet_link_tag("print")
        rescue Sprockets::Rails::Helper::AssetNotFound
          # print.css is optional in test and some packaging environments
        end

        # cache the assets locally
        doc.xpath("/html/head/link").each do |link|
          next unless link["rel"] == "stylesheet"
          # next unless link['href'].start_with?('/assets/', 'https://')
          filename = if link["href"].start_with?("/assets/")
            link["href"].split(/[\?#]/).first.gsub("/assets", "")
          else
            ("/" + link["href"].split("#").first.gsub(/[^\w\.]/, "-"))
          end
          filename += ".css" if link["rel"] == "stylesheet" && !filename.end_with?(".css")

          # only cache as needed
          download_and_cache(link, filename) unless File.exist?("./assets#{filename}")

          link["href"] = "./assets#{filename}"
          placeholder_el.add_next_sibling link
        end
        @fonts.each do |filename|
          placeholder_el.add_next_sibling "<link rel='stylesheet' href='./assets/#{filename}'>"
        end

        # ARC-114 Chinese characters were missing (Hack to include font as fallback font)
        placeholder_el.add_next_sibling <<~STYLE
          <style>
            @font-face {
              font-family: 'UnifontExMono';
              src: url('../../../fonts/UnifontExMono.woff') format('woff');
            }
          </style>
        STYLE

        placeholder_el.unlink
      end

      def download_and_cache(link, filename)
        if link["href"].start_with?("/assets/")
          response = get(link["href"])
        else
          uri = URI(link["href"])
          response = Net::HTTP.get_response(uri)
          # STDERR.puts "-- FETCHING #{link['href']} :: #{response.is_a?(Net::HTTPSuccess)}"
          return unless response.is_a?(Net::HTTPSuccess)
        end

        stylesheet = response.body
        buffer = download_and_update_urls(stylesheet)

        FileUtils.makedirs("./assets#{File.dirname(filename)}") unless Dir.exist?("./assets/#{File.dirname(filename)}")

        File.open("./assets/#{filename}", "wb") do |f|
          f.puts buffer
        end

        if filename.include?(".css") && filename.include?("font")
          @fonts << filename
        end
      end

      def download_and_update_urls(stylesheet)
        # now we have to look for url(/assets) here
        buffer = stylesheet.split(/\n/)
        buffer.each_with_index do |line, i|
          matches = line.scan(%r{url\("?([^\)]+)"?\)})
          next unless matches

          matches.each do |match|
            asset_path = match[0].delete('"')
            next unless asset_path.start_with?("/assets/", "https://")

            asset_filename = if asset_path.start_with?("/assets/")
              asset_path.split(/[\?#]/).first.gsub("/assets", "")
            else
              ("/" + asset_path.gsub(/[^\w\.]/, "-"))
            end

            unless File.exist?("./#{asset_filename}")
              resource = if asset_path.start_with?("/assets/")
                response = get(asset_path)
                response.body
              else
                uri = URI(asset_path)
                response = Net::HTTP.get_response(uri)
                # STDERR.puts "-- +++ FETCHING #{asset_path} :: #{response.code} :: #{response['content-type']}"
                next unless response.is_a?(Net::HTTPSuccess)
                asset_filename += ".css" if response["content-type"].include?("text/css") && !asset_filename.end_with?(".css")
                asset_filename += ".woff2" if response["content-type"].include?("font/woff2") && !asset_filename.end_with?(".woff2")
                if response["content-type"].include?("text/css")
                  download_and_update_urls(response.body)
                else
                  response.body
                end
              end

              FileUtils.makedirs("./assets#{File.dirname(asset_filename)}") unless Dir.exist?(File.dirname("./assets#{asset_filename}"))
              @fonts << asset_filename if asset_filename.include?("font") && asset_filename.include?(".css")

              File.open("./assets#{asset_filename}", "wb") do |f|
                f.puts resource
              end
            end

            line.gsub!(asset_path, ".#{asset_filename}")
          end
          buffer[i] = line
        end

        buffer.join("\n")
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def update_package_scripts_pdf
        # remove the script tags
        doc.xpath("/html/head/script").each do |script| # rubocop:disable Style/SymbolProc
          script.remove
        end
      end

      def index
        @index ||= Index.new
      end
    end

    # Queue packaging
    class Queue
      attr_accessor :index

      def initialize
        @index = Index.new
      end

      def setup(**kw)
        identifiers = if kw[:eadid]
          [ kw[:eadid] ]
        else
          fetch_collection_identifiers(kw[:repository_ssm])
        end

        identifiers.each do |identifier|
          puts "UM-Arclight queue package: #{identifier}"
          ::PackageFindingAidJob.perform_later(identifier, kw.fetch(:format, "html"))
        end
      end

      def fetch_collection_identifiers(repository_ssm)
        params = {
          fl: "id",
          q: [ "level_ssm:collection" ],
          start: 0,
          rows: 1000
        }
        params["fq"] = [ "repository_ssm:\"#{repository_ssm}\"" ] if repository_ssm
        identifiers = []
        response = index.search(params)
        start = 0
        while response.documents.present?
          response.documents.each do |doc|
            identifiers << doc.id
          end
          start += 1000
          params[:start] = start
          response = index.search(params)
        end
        identifiers
      end
    end

    # Shared helper to Blacklight.repository
    class Index
      attr_accessor :index
      def initialize
        @index = Blacklight.repository_class.new(CatalogController.new.helpers.blacklight_config)
      end

      def search(params)
        @index.search(params)
      end
    end
  end
end
