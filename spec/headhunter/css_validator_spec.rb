require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Headhunter::CssValidator do
  describe '#validate' do
    subject { described_class.new }

    it 'returns a local response when calling the validator succeeds' do
      expect(subject.validate(path_to_file('invalid.css'))).to be_a Headhunter::LocalResponse
    end

    it 'throws an exception when calling the validator fails'
  end
end