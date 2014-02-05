require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Headhunter::CssValidator::Validator do
  describe '.validate_file' do
    subject { described_class.validate_file(path_to_file('invalid_response.xml')) }

    it 'validates the contents of a file at a specified path' do
      expect(subject).not_to be_valid
      expect(subject.errors.count).to eq 1
    end
  end

  describe '.validate_string' do
    subject { described_class.validate_string(read_file('invalid_response.xml')) }

    it 'validates the content of a given string' do
      expect(subject).not_to be_valid
      expect(subject.errors.count).to eq 1
    end
  end

  describe '.fetch_file_content' do
    subject { described_class.fetch_file_content(path_to_file('invalid_response.xml')) }

    it 'returns the contents of a file at a specified path' do
      expect(subject).to start_with '{vextwarning=false, output=soap12, lang=en, warning=2, medium=all, profile=css3}'
    end
  end
end