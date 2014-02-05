require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Headhunter::LocalResponse do
  describe '#initialize' do
    context 'valid response' do
      subject { Headhunter::LocalResponse.new(read_file('valid_response.xml')) }

      it { should be_valid }

      it 'sets the w3c validator status header to true' do
        expect(subject['x-w3c-validator-status']).to be_true
      end
    end

    context 'invalid response' do
      subject { Headhunter::LocalResponse.new(read_file('invalid_response.xml')) }

      it { should_not be_valid }

      it 'sets the w3c validator status header to false' do
        expect(subject['x-w3c-validator-status']).to be_false
      end
    end
  end

  describe '#remove_first_line_from' do
    subject { Headhunter::LocalResponse.new }

    it 'removes the first line from a passed string' do
      string = "this is the first line\nthis\nis the\nrest"
      expect(subject.send :remove_first_line_from, string).to eq "this\nis the\nrest"
    end
  end

  describe '#sanitize_prefixed_tags_from' do
    subject { Headhunter::LocalResponse.new }

    it 'replaces tags like <m:error> with <error> in a passed string' do
      string = "<m:errors><m:pipapo><bla>Bla!</bla</m:pipapo</m:errors>"
      expect(subject.send :sanitize_prefixed_tags_from, string).to eq "<errors><pipapo><bla>Bla!</bla</pipapo</errors>"
    end
  end

  describe '#convert_soap_to_xml' do
    subject { Headhunter::LocalResponse.new }

    it 'converts SOAP to XML' do
      string = "this is the first line\n<m:errors><m:pipapo><bla>Bla!</bla</m:pipapo</m:errors>"
      expect(subject.send :convert_soap_to_xml, string).to eq "<errors><pipapo><bla>Bla!</bla</pipapo</errors>"
    end
  end
end
