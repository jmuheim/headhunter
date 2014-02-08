require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Headhunter::CssValidator do
  describe '#validate' do
    subject { described_class.new }

    it 'returns a local response when calling the validator succeeds' do
      expect(subject.validate(path_to_file('invalid.css'))).to be_a Headhunter::LocalResponse
    end

    it 'throws an exception when calling the validator fails'
  end

  describe '#extract_filename' do
    subject { described_class.new }

    it 'for a compiled asset, it returns the name of the file without the cache hash' do
      filename = '/rails/root/public/assets/some-rails_asset-1f6355461e8ff118448a9649a392632c.css'
      expect(subject.send(:extract_filename, filename)).to eq 'some-rails_asset.css'
    end

    it 'for any other file, it simply returns the name' do
      filename = '/rails/root/public/assets/some_other-file.css'
      expect(subject.send(:extract_filename, filename)).to eq 'some_other-file.css'
    end
  end

  describe '#x_stylesheets_be' do
    subject { described_class.new }

    it "creates a grammatically correct sentence when there is no stylesheet" do
      expect(subject.x_stylesheets_be(0)).to eq '0 stylesheet is'
    end

    it "creates a grammatically correct sentence when there is only one stylesheet" do
      expect(subject.x_stylesheets_be(1)).to eq '1 stylesheet is'
    end

    it "creates a grammatically correct sentence when there is more than one stylesheet" do
      expect(subject.x_stylesheets_be(2)).to eq '2 stylesheets are'
    end
  end

  describe '#statistics' do
    context 'for valid CSS' do
      subject { described_class.new([path_to_file('valid.css')]).statistics }

      it "returns a text with nice statistics" do
        expect(subject).to match 'Validated 1 stylesheet.'
        expect(subject).to match '1 stylesheet is valid.'
      end
    end

    context 'for invalid CSS' do
      subject { described_class.new([path_to_file('invalid.css')]).statistics }

      it "returns a text with nice statistics" do
        expect(subject).to match 'Validated 1 stylesheet.'
        expect(subject).to match '1 stylesheet is invalid.'
        expect(subject).to match 'invalid.css:'
        expect(subject).to match "Line 8: Property wibble doesn't exist."
      end
    end
  end

  describe '#initialize' do
    context 'for no CSS' do
      subject { described_class.new }

      it 'executes validation' do
        expect(subject.valid_responses.size).to eq 0
        expect(subject.invalid_responses.size).to eq 0
      end
    end

    context 'for valid CSS' do
      subject { described_class.new([path_to_file('valid.css')]) }

      it 'executes validation' do
        expect(subject.valid_responses.size).to eq 1
        expect(subject.invalid_responses.size).to eq 0
      end
    end

    context 'for invalid CSS' do
      subject { described_class.new([path_to_file('invalid.css')]) }

      it 'executes validation' do
        expect(subject.invalid_responses.size).to eq 1
        expect(subject.valid_responses.size).to eq 0
      end
    end
  end

  describe '#valid_responses' do
    subject { described_class.new([path_to_file('valid.css')]) }

    it 'returns all valid responses' do
      expect(subject.valid_responses.size).to eq 1
      expect(subject.invalid_responses.size).to eq 0
    end
  end

  describe '#invalid_responses' do
    subject { described_class.new([path_to_file('invalid.css')]) }

    it 'returns all valid responses' do
      expect(subject.invalid_responses.size).to eq 1
      expect(subject.valid_responses.size).to eq 0
    end
  end
end