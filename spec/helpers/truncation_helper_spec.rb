# frozen_string_literal: true

require 'rails_helper'

require_relative "../../app/helpers/truncation_helper"

RSpec.describe TruncationHelper, type: :helper do
  describe "#truncate_html" do
    it "truncates an html string to an expected portion" do
      html_string = "This is a <strong>test</strong>"
      truncated_string = helper.truncate_html(html_string: html_string, length: 10)
      expect(truncated_string).to eq("This is...")
    end

    it "does not break up HTML tags" do
      html_string = "This is <strong>another test</strong>"
      truncated_string = helper.truncate_html(html_string: html_string, length: 15)
      expect(truncated_string).to eq("This is...")
    end
  end
end

