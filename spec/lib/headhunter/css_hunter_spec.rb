require 'spec_helper'

module Headhunter
  describe CssHunter do
    describe '#remove_pseudo_classes_from' do
      subject { described_class.new }

      it 'returns pseudo classes' do
        expect(subject.remove_pseudo_classes_from('textarea:not(.something)')).to eq 'textarea'
      end
    end

    describe '#bare_selector_from' do
      subject { described_class.new }

      it 'cleans a selector from stuff like pseudo classes' do
        expect(subject.bare_selector_from('textarea:not(.something)')).to eq 'textarea'
      end
    end

    describe '#add_css_selectors_from' do
      subject { described_class.new }

      it 'adds selectors' do
        subject.add_css_selectors_from(read_file('css_validator/valid.css'))

        expect(subject.error_selectors).to eq []
        expect(subject.used_selectors).to eq []
        expect(subject.unused_selectors).to match_array ['html', 'body', '*', 'ul', 'ul li', '.hidden', 'a img', 'a',
                                                         'a:hover', '.clear-float']
      end
    end

    describe '#detect_used_selectors_in' do
      subject { described_class.new }

      it 'adds selectors' do
        subject.add_css_selectors_from(read_file('css_validator/valid.css'))

        expect(subject.detect_used_selectors_in(read_file('css_hunter/valid.html'))).to match_array ['html', 'body', '*']
      end

      it 'gracefully ignores invalid rules' do
        pending "Don't know how to do this"
      end
    end

    describe '#process' do
      subject { described_class.new }

      it 'processes given html' do
        subject.add_css_selectors_from(read_file('css_validator/valid.css'))
        subject.process(read_file('css_hunter/valid.html'))

        expect(subject.error_selectors).to eq []
        expect(subject.used_selectors).to eq ['html', 'body', '*']
        expect(subject.unused_selectors).to match_array ['ul', 'ul li', '.hidden', 'a img', 'a', 'a:hover',
                                                         '.clear-float']
      end
    end

    describe '#statistics' do
      subject do
        css_hunter = described_class.new
        css_hunter.add_css_selectors_from(read_file('css_validator/valid.css'))
        css_hunter.process(read_file('css_hunter/valid.html'))
        css_hunter.statistics
      end

      it "returns a text with nice statistics" do
        expect(subject).to match 'Found 10 CSS selectors.'
        expect(subject).to match '7 selectors are not in use:'
        expect(subject).to match '.clear-float'
        expect(subject).to match '.hidden'
        expect(subject).to match 'a'
        expect(subject).to match 'a img'
        expect(subject).to match 'a:hover'
        expect(subject).to match 'ul'
        expect(subject).to match 'ul li'
      end
    end
  end
end
