# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Package::Generator do
  subject(:generator) { described_class.new(identifier: identifier) }

  let(:identifier) { 'umich-test-9999' }

  before do
    allow(generator).to receive(:fetch_doc) do |_identifier| # rubocop:disable RSpec/SubjectStub
      SolrDocument.new(
        'id': 'umich-test-9999',
        'normalized_title_ssm': [ 'Finding Aid' ],
        'authors_creators_tesim': [ 'Finding Aid written by E. A. Document' ],
        'repository_ssm': [ 'University of Michigan Bentley Historical Library' ]
      )
    end

    allow(generator).to receive(:fetch_components) do |_identifier| # rubocop:disable RSpec/SubjectStub
      [
        SolrDocument.new(
          'id': 'umich-test-9999-01',
          'normalized_title_ssm': [ 'Component 1.0' ],
          "component_level_isim": [ 1 ],
          'total_digital_object_count_isim': [ 1 ],
          "parent_ssim": [ 'umich-test-9999' ],
          'digital_objects_ssm': [
            {
              'label': 'Digital Object',
              'href': 'https://quod.lib.umich.edu/x/xyzzy/x-9999-01/01',
              'role': 'image-service',
              'xpointer': nil
            }.to_json
          ],
          'repository_ssm': [ 'University of Michigan Bentley Historical Library' ]
        )
      ]
    end

    allow(generator).to receive(:get) do |url| # rubocop:disable RSpec/SubjectStub
      response = double('response') # rubocop:disable RSpec/VerifiedDoubles
      output = mock_get(url)
      allow(response).to receive(:body) do
        output
      end
      response
    end
    allow(generator).to receive(:download_and_cache) # rubocop:disable RSpec/SubjectStub
  end

  it 'generate HTML for an identifier' do
    generator.build_html
    doc = generator.doc

    # expect(doc.xpath('//div[@id="summary"]//dl/dd[contains(., "Finding Aid written by E. A. Document")]').first).to be_truthy
    # expect(doc.css(".access-preview-snippet #toc").first).to be_truthy
    expect(doc.css('style#utility-styles').first).to be_truthy

    # count that the components are in the doc
    expect(doc.css('.al-contents-ish article')).not_to be_empty
  end

  it 'modify HTML for to generate PDF' do
    generator.build_html
    generator.build_pdf_html
    doc = generator.doc

    expect(doc.css('m-website-header')).to be_empty
    expect(doc.css('header').first).to be_truthy
    expect(doc.css('#toc li a[data-context-href]')).not_to be_empty
    doc.css('#toc li a[data-context-href]').each do |link|
      expect(link["href"]).to start_with("#")
    end
    expect(doc.css('#toc .al-toggle-view-children')).to be_empty
  end
end

def mock_get(url) # rubocop:disable Metrics/MethodLength
  if url.start_with?('/catalog') and not url.index('/hierarchy')
    <<-HTML
    <html>
      <head>
        <title>Finding Aid</title>
        <link rel="stylesheet" href="/assets/styles.css" />
        <meta name="csrf-param">
        <meta name="csrf-token">
        <script>console.log('NOP');</script>
      </head>
      <body>
        <m-universal-header></m-universal-header>
        <m-website-header name="Finding Aids"></m-website-header>
        <aside>
        <nav class="al-sidebar-navigation-context sidebar-section" aria-labelledby="collection-nav">
          <ul class="nav">
            <li class="nav-item">
              <a href="/catalog/umich-test-9999#about">About</a>
            </li>
            <li class="nav-item">
              <a href="/catalog/umich-test-9999#restrictions">Restrictions</a>
            </li>
            <li class="nav-item">
              <a href="/catalog/umich-test-9999#contents">Contents</a>
            </li>
          </ul>
          </nav>
          <div id="collection-context" class="sidebar-section">
            <h2>
              <i class="bi bi-geo-alt-fill"></i>
              Navigate The Collection
            </h2>
            <turbo-frame loading="lazy" id="al-hierarchy-umich-test-9999" src="/catalog/umich-test-9999/hierarchy?hierarchy=true"></turbo-frame>
          </div>
        </aside>
        <main>
          <div class="card">
            <div class="card-img">
              <!-- this will be removed -->
            </div>
            <div class="card-body">Finding Aid Repository</div>
          </div>
          <div id="navigate-collection-toggle"></div>
          <div class="access-preview-snippet">
            <!-- this will be removed -->
          </div>
          <div id="summary">
            <dl>
              <dt>Scope</dt>
              <dd>Blah blah blah</dd>
            </dl>
          </div>
          <div id="background">
          </div>
          <div id="contents">
            <turbo-frame>
              <p>This will be replaced.</p>
            </turbo-frame>
          </div>
        </main>
        <footer>
          <!-- ahoy, a footer -->
        </footer>
      </body>
    </html>
    HTML
  elsif url.start_with?('/assets/')
    'main { border: 1px solid #666; }'
  elsif url.index('/hierarchy')
    <<-HTML
    <html>
      <body>
          <main
            id="main-container"
            class="viewport-container"
            role="main"
            aria-label="Main content"
          >
            <div class="row">
                <section class="col-md-12">
                  <p>umich-test-9999</p>
                  <turbo-frame id="al-hierarchy-umich-test-9999">
                      <ul class="documents">
                        <li
                            id="umich-test-9999_aspace_9a4ecf9b68de30c050428e9d80ecba76-hierarchy-item"
                            data-document-id="umich-test-9999_aspace_9a4ecf9b68de30c050428e9d80ecba76"
                            itemscope="itemscope"
                            itemtype="http://schema.org/Thing"
                            class="blacklight-series document al-collection-context"
                        >
                            <div
                              class="documentHeader"
                              data-document-id="umich-test-9999_aspace_9a4ecf9b68de30c050428e9d80ecba76"
                            >
                              <a
                                  class="al-toggle-view-children collapsed"
                                  aria-label="View"
                                  data-bs-toggle="collapse"
                                  data-toggle="collapse"
                                  href="#collapsible-hierarchy-umich-test-9999_aspace_9a4ecf9b68de30c050428e9d80ecba76"
                              >
                                  <span
                                    class="al-toggle-icon"
                                    aria-hidden="true"
                                  ></span>
                              </a>
                              <div
                                  class="index_title document-title-heading"
                                  data-turbo="false"
                              >
                                  <a
                                    data-context-href="/catalog/umich-test-9999_aspace_9a4ecf9b68de30c050428e9d80ecba76/track?document_id=umich-test-9999_aspace_9a4ecf9b68de30c050428e9d80ecba76"
                                    data-context-method="post"
                                    data-turbo-prefetch="false"
                                    href="/catalog/umich-test-9999_aspace_9a4ecf9b68de30c050428e9d80ecba76"
                                    >Pre-Congressional Career, 1938-1985</a
                                  >
                                  <span
                                    class="badge badge-pill bg-secondary badge-secondary al-number-of-children-badge"
                                    >9
                                    <span class="sr-only visually-hidden"
                                        >components</span
                                    ></span
                                  >
                              </div>
                            </div>

                            <div
                              id="collapsible-hierarchy-umich-test-9999_aspace_9a4ecf9b68de30c050428e9d80ecba76"
                              class="collapse al-collection-context-collapsible al-hierarchy-level-1"
                            >
                              <turbo-frame
                                  loading="lazy"
                                  id="al-hierarchy-umich-test-9999_aspace_9a4ecf9b68de30c050428e9d80ecba76-sidebar"
                                  src="/catalog/umich-test-9999_aspace_9a4ecf9b68de30c050428e9d80ecba76/hierarchy?hierarchy=true&amp;key=-sidebar"
                              ></turbo-frame>
                            </div>
                        </li>
                      </ul>
                  </turbo-frame>
                </section>
            </div>
          </main>
      </body>
    </html>
    HTML
  end
end
