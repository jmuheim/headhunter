require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Headhunter::HtmlValidator do
  describe '#validate' do
    subject { described_class.new }

    it 'returns a local response when calling the validator succeeds' do
      expect(subject.validate('invalid.html', read_file('invalid.html'))).to be_a Headhunter::HtmlValidator::Response
    end

    it 'throws an exception when calling the validator fails'
  end

  describe '#x_pages_be' do
    subject { described_class.new }

    it "creates a grammatically correct sentence when there is no page" do
      expect(subject.x_pages_be(0)).to eq '0 page is'
    end

    it "creates a grammatically correct sentence when there is only one page" do
      expect(subject.x_pages_be(1)).to eq '1 page is'
    end

    it "creates a grammatically correct sentence when there is more than one page" do
      expect(subject.x_pages_be(2)).to eq '2 pages are'
    end
  end

  describe '#statistics' do
    context 'for valid HTML' do
      subject do
        validator = described_class.new
        validator.validate('valid.html', read_file('valid.html'))
        validator.statistics
      end

      it "returns a text with nice statistics" do
        expect(subject).to match 'Validated 1 page.'
        expect(subject).to match 'All pages are valid.'
      end
    end

    context 'for invalid HTML' do
      subject do
        validator = described_class.new
        validator.validate('invalid.html', read_file('invalid.html'))
        validator.statistics
      end

      it "returns a text with nice statistics" do
        expect(subject).to match 'Validated 1 page.'
        expect(subject).to match '1 page is invalid.'
        expect(subject).to match 'invalid.html:'
        expect(subject).to match 'Line 12, column 6: Warning: missing </b> before </p>.'
        expect(subject).to match 'Line 12, column 54: Warning: discarding unexpected </b>.'
      end
    end
  end

  describe '#valid_responses' do
    subject do
      validator = described_class.new
      validator.validate('valid.html', read_file('valid.html'))
      validator
    end

    it 'returns all valid responses' do
      expect(subject.valid_responses.size).to eq 1
      expect(subject.invalid_responses.size).to eq 0
    end
  end

  describe '#invalid_responses' do
    subject do
      validator = described_class.new
      validator.validate('invalid.html', read_file('invalid.html'))
      validator
    end

    it 'returns all valid responses' do
      expect(subject.invalid_responses.size).to eq 1
      expect(subject.valid_responses.size).to eq 0
    end
  end
end
