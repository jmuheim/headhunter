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

    it "extracts the file's name from a Rails' asset path" do
      filename = '/rails/root/public/assets/application-123abc.css'
      expect(subject.send(:extract_filename, filename)).to eq 'application.css'
    end

    it 'allows underscores in the file name' do
      filename = '/rails/root/public/assets/some_file-123abc.css'
      expect(subject.send(:extract_filename, filename)).to eq 'some_file.css'
    end

    it 'allows hyphens in the file name' do
      filename = '/rails/root/public/assets/some-file-123abc.css'
      expect(subject.send(:extract_filename, filename)).to eq 'some-file.css'
    end
  end

  describe '#x_stylesheets_be' do
    subject { described_class.new }

    it "creates a grammatically correct sentence when there is no stylesheet" do
      expect(subject.send(:x_stylesheets_be, 0)).to eq '0 stylesheet is'
    end

    it "creates a grammatically correct sentence when there is only one stylesheet" do
      expect(subject.send(:x_stylesheets_be, 1)).to eq '1 stylesheet is'
    end

    it "creates a grammatically correct sentence when there is more than one stylesheet" do
      expect(subject.send(:x_stylesheets_be, 2)).to eq '2 stylesheets are'
    end
  end
end