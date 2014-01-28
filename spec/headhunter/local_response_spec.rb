require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Headhunter::LocalResponse do
  context 'valid response' do
    subject do
      Headhunter::LocalResponse.new(
        <<-EOF
          <env:Envelope xmlns:env='http://www.w3.org/2003/05/soap-envelope'>
            <m:cssvalidationresponse
              env:encodingStyle='http://www.w3.org/2003/05/soap-encoding'
              xmlns:m='http://www.w3.org/2005/07/css-validator'>
              <m:validity>true</m:validity>
            </m:cssvalidationresponse>
          </env:Envelope>
        EOF
      )
    end

    it { should be_valid }

    it 'sets the w3c validator status header to true' do
      expect(subject['x-w3c-validator-status']).to be_true
    end
  end

  context 'invalid response' do
    subject do
      Headhunter::LocalResponse.new(
        <<-EOF
          <env:Envelope xmlns:env='http://www.w3.org/2003/05/soap-envelope'>
            <m:cssvalidationresponse
              env:encodingStyle='http://www.w3.org/2003/05/soap-encoding'
              xmlns:m='http://www.w3.org/2005/07/css-validator'>
              <m:validity>false</m:validity>
            </m:cssvalidationresponse>
          </env:Envelope>
        EOF
      )
    end

    it { should_not be_valid }

    it 'sets the w3c validator status header to false' do
      expect(subject['x-w3c-validator-status']).to be_false
    end
  end
end