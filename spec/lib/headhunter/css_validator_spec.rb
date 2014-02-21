require 'spec_helper'

describe Headhunter::CssValidator do # TODO: "Module Headhunter"
  describe '#validate' do
    subject { described_class.new }

    it 'adds a response when calling the validator succeeds' do
      expect {
        subject.validate(path_to_file('css_validator/invalid.css'))
      }.to change { subject.responses.count }.by 1
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
      subject { described_class.new([path_to_file('css_validator/valid.css')]).statistics }

      it "returns a text with nice statistics" do
        expect(subject).to match 'Validated 1 stylesheet.'
        expect(subject).to match 'All stylesheets are valid.'
      end
    end

    context 'for invalid CSS' do
      subject { described_class.new([path_to_file('css_validator/invalid.css')]).statistics }

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
      subject { described_class.new([path_to_file('css_validator/valid.css')]) }

      it 'executes validation' do
        expect(subject.valid_responses.size).to eq 1
        expect(subject.invalid_responses.size).to eq 0
      end
    end

    context 'for invalid CSS' do
      subject { described_class.new([path_to_file('css_validator/invalid.css')]) }

      it 'executes validation' do
        expect(subject.invalid_responses.size).to eq 1
        expect(subject.valid_responses.size).to eq 0
      end
    end
  end

  describe '#valid_responses' do
    subject { described_class.new([path_to_file('css_validator/valid.css')]) }

    it 'returns all valid responses' do
      expect(subject.valid_responses.size).to eq 1
      expect(subject.invalid_responses.size).to eq 0
    end
  end

  describe '#invalid_responses' do
    subject { described_class.new([path_to_file('css_validator/invalid.css')]) }

    it 'returns all valid responses' do
      expect(subject.invalid_responses.size).to eq 1
      expect(subject.valid_responses.size).to eq 0
    end
  end
end

describe Headhunter::CssValidator::Response do
  describe '#initialize' do
    context 'valid response' do
      subject { described_class.new(read_file('css_validator/valid_response.xml')) }

      it { should be_valid }
    end

    context 'invalid response' do
      subject { described_class.new(read_file('css_validator/invalid_response.xml')) }

      it { should_not be_valid }
    end
  end

  describe '#errors' do
    context 'valid response' do
      subject { described_class.new(read_file('css_validator/valid_response.xml')) }

      it 'returns an empty array' do
        expect(subject.errors).to eq []
      end
    end

    context 'invalid response' do
      subject { described_class.new(read_file('css_validator/invalid_response.xml')) }

      it 'returns an array of errors' do
        expect(subject.errors.size).to eq 1
        expect(subject.errors.first).to be_a Headhunter::CssValidator::Response::Error
      end
    end
  end

  describe '#convert_soap_to_xml' do
    subject { described_class.new }

    it 'converts SOAP to XML' do
      string = "this is the first line\n<m:errors><m:pipapo><bla>Bla!</bla</m:pipapo</m:errors>"
      expect(subject.send :convert_soap_to_xml, string).to eq "<errors><pipapo><bla>Bla!</bla</pipapo</errors>"
    end
  end

  describe '#remove_first_line_from' do
    subject { described_class.new }

    it 'removes the first line from a passed string' do
      string = "this is the first line\nthis\nis the\nrest"
      expect(subject.send :remove_first_line_from, string).to eq "this\nis the\nrest"
    end
  end

  describe '#sanitize_prefixed_tags_from' do
    subject { described_class.new }

    it 'replaces tags like <m:error> with <error> in a passed string' do
      string = "<m:errors><m:pipapo><bla>Bla!</bla</m:pipapo</m:errors>"
      expect(subject.send :sanitize_prefixed_tags_from, string).to eq "<errors><pipapo><bla>Bla!</bla</pipapo</errors>"
    end
  end

  describe '#uri' do
    subject { described_class.new(read_file('css_validator/valid_response.xml')) }

    it "returns the validated uri's path" do
      expect(subject.send :uri).to eq 'file:tmp.css'
    end
  end
end

describe Headhunter::CssValidator::Response::Error do
  describe '#initialize' do
    subject { described_class.new(123, "Attribute xyz doesn't exist", context: 'something', anything_else: 'bla') }

    it 'assigns the passed params correctly' do
      expect(subject.line).to eq 123
      expect(subject.message).to eq "Attribute xyz doesn't exist"
      expect(subject.details).to eq context: 'something', anything_else: 'bla'
    end
  end
end
