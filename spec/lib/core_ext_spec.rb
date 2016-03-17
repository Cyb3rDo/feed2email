require 'spec_helper'
require 'feed2email/core_ext'

describe String do
  describe '#escape_html' do
    it 'escapes &' do
      expect('&'.escape_html).to eq '&amp;'
    end

    it 'escapes "' do
      expect('"'.escape_html).to eq '&quot;'
    end

    it 'escapes <' do
      expect('<'.escape_html).to eq '&lt;'
    end

    it 'escapes >' do
      expect('>'.escape_html).to eq '&gt;'
    end
  end

  describe '#pluralize' do
    subject { singular.pluralize(count) }

    let(:singular) { 'apple' }

    context 'count is 1' do
      let(:count) { 1 }

      it { is_expected.to eq '1 apple' }
    end

    context 'count is greater than 1' do
      let(:count) { 2 }

      it { is_expected.to eq '2 apples' }

      context 'plural is present' do
        subject { singular.pluralize(count, 'apples!') }

        it { is_expected.to eq '2 apples!' }
      end
    end
  end

  describe '#strip_html' do
    it 'strips HTML' do
      expect((
        'You can find feed2email ' +
        '<a href="http://github.com/agorf/feed2email">here</a>.'
      ).strip_html).to eq 'You can find feed2email here.'
    end
  end

  describe '#to_markdown' do
    subject { html.to_markdown }

    let(:html) { File.read(fixture_path('to_markdown.html')) }
    let(:markdown) { File.read(fixture_path('to_markdown.markdown')) }

    it { is_expected.to eq markdown }
  end
end
