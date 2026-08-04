# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Box::Package::Generator do
  subject(:generator) { described_class.new(identifier: identifier) }

  let(:identifier) { 'umich-test-9999' }

  before do
    allow(generator).to receive(:fetch_doc) do |_identifier| # rubocop:disable RSpec/SubjectStub
      SolrDocument.new(
        'id': 'umich-test-9999',
        'normalized_title_ssm': [ 'Finding Aid' ],
        'ead_author_ssm': [ 'Finding Aid written by E. A. Document' ],
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
  end

  it 'generate HTML for an identifier' do
    generator.build_html
    doc = generator.doc

    expect(doc.xpath('//div[@id="summary"]//dl/dd[contains(., "Finding Aid written by E. A. Document")]').first).to be_truthy
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
  end
end

def mock_get(url) # rubocop:disable Metrics/MethodLength
  if url.start_with?('/catalog')
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
          <nav class="about-collection-nav">
            <a href="/catalog/umich-9999-test#about">About</a>
            <a href="/catalog/umich-9999-test#restrictions">Restrictions</a>
          </nav>
          <div id="context-tree-nav">
            <div class="tab-panes">
              <div class="tab-pane active">
                <!-- this will be removed -->
              </div>
            </div>
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
          <div class="al-contents">
            <p>This will be replaced.</p>
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
  end
end
