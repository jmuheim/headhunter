require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Headhunter::LocalResponse do
  context 'valid response' do
    subject { Headhunter::LocalResponse.new(read_file('valid_response.xml')) }

    describe '#initialize' do
      it { should be_valid }

      it 'sets the w3c validator status header to true' do
        expect(subject['x-w3c-validator-status']).to be_true
      end
    end
  end

  context 'invalid response' do
    subject { Headhunter::LocalResponse.new(read_file('invalid_response.xml')) }

    describe '#initialize' do
      it { should_not be_valid }

      it 'sets the w3c validator status header to false' do
        expect(subject['x-w3c-validator-status']).to be_false
      end
    end

    describe '#extract_line_from_error' do
      # it 'extracts the line number from an error object' do
      #   error = subject.document
      #   expect(subject.send :extract_line_from_error, error).to eq 'Bla'
      # end
    end
  end
end