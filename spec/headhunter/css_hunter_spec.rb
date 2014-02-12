require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Headhunter::CssHunter do
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
      subject.add_css_selectors_from(read_file('valid.css'))

      expect(subject.error_selectors).to eq []
      expect(subject.used_selectors).to eq []
      expect(subject.unused_selectors).to match_array ['html', 'body', '*', 'ul', 'ul li', '.hidden', 'a img', 'a',
                                                       'a:hover', '.clear-float']
    end
  end

  describe '#detect_used_selectors_in' do
    subject { described_class.new }

    it 'adds selectors' do
      subject.add_css_selectors_from(read_file('valid.css'))

      expect(subject.detect_used_selectors_in(read_file('valid.html'))).to match_array ['html', 'body', '*']
    end

    it 'gracefully ignores invalid rules' do
      pending "Don't know how to do this"
    end
  end

  describe '#process' do
    subject { described_class.new }

    it 'processes given html' do
      subject.add_css_selectors_from(read_file('valid.css'))
      subject.process(read_file('valid.html'))

      expect(subject.error_selectors).to eq []
      expect(subject.used_selectors).to eq ['html', 'body', '*']
      expect(subject.unused_selectors).to match_array ['ul', 'ul li', '.hidden', 'a img', 'a', 'a:hover',
                                                       '.clear-float']
    end
  end

  describe '#statistics' do
    subject do
      css_hunter = described_class.new
      css_hunter.add_css_selectors_from(read_file('valid.css'))
      css_hunter.process(read_file('valid.html'))
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

# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# 
# unless defined?(SpecFailed)
#   SpecFailed = RSpec::Expectations::ExpectationNotMetError
# end
# 
# describe Headhunter::CssValidator::Validator do
#   describe '#validate_file' do
#     def absolute_path(file)
#       "/Users/josh/Documents/Work/MuheimWebdesign/Headhunter/spec/files/#{file}"
#     end
# 
#     it 'raises an error if the file can not be found'
# 
#     it 'returns a valid result for a valid CSS file' do
#       result = described_class.validate_file(absolute_path('valid.css'))
#       expect(result).to be_valid
#     end
# 
#     it 'returns an invalid result for an invalid CSS file' do
#       result = described_class.validate_file(absolute_path('invalid.css'))
#       expect(result).not_to be_valid
#       binding.pry
#       # css = get_file('invalid.css')
#       # lambda {
#       #   css.should be_valid_css
#       # }.should raise_error(SpecFailed) { |e|
#       #   e.message.should match(/expected css to be valid, but validation produced these errors/)
#       #   e.message.should match(/Invalid css: line 8: Property wibble doesn't exist/)
#       # }
#     end
# 
#     it "should not validate an invalid response" do
#       response = MockResponse.new(get_file('invalid.css'))
#       lambda {
#         response.should be_valid_css
#       }.should raise_error(SpecFailed) { |e|
#         e.message.should match(/expected css to be valid, but validation produced these errors/)
#         e.message.should match(/Invalid css: line 8: Property wibble doesn't exist/)
#       }
#     end
# 
#     it "should display invalid content when requested" do
#       BeValidAsset::Configuration.display_invalid_content = true
#       css = get_file('invalid.css')
#       lambda {
#         css.should be_valid_css
#       }.should raise_error(SpecFailed) { |e|
#         e.message.should match(/wibble:0;/)
#       }
#       BeValidAsset::Configuration.display_invalid_content = false
#     end
#   end
# 
#   describe '#validate_string' do
#     it 'should validate an empty string' do
#       result = described_class.validate_string('')
#       expect(result.valid?).to be true
#     end
#   end
# 
#   it "should fail unless resposne is HTTP OK" do
#     css = get_file('valid.css')
# 
#     r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
#     h = Net::HTTP.new(BeValidAsset::Configuration.css_validator_host)
#     h.stub!(:post2).and_return(r)
#     Net::HTTP.stub!(:start).and_return(h)
# 
#     lambda {
#       css.should be_valid_css
#     }.should raise_error
#   end
# 
#   it "should mark test as pending if ENV['NONET'] is true" do
#     ENV['NONET'] = 'true'
# 
#     css = get_file('valid.css')
#     lambda {
#       css.should be_valid_css
#     }.should raise_error(RSpec::Core::Pending::PendingDeclaredInExample)
# 
#     ENV.delete('NONET')
#   end
# 
#   describe "CSS version" do
#     (1..3).each do |version|
#       describe version.to_s do
#         before(:each) do
#           @css = get_file("valid-#{version.to_s}.css")
#         end
#         (1..3).each do |test_version|
#           if test_version < version
#             it "should not be valid css#{test_version.to_s}" do
#               lambda {
#                 @css.should send("be_valid_css#{test_version.to_s}".to_sym)
#                 }.should raise_error(SpecFailed)
#             end
#           else
#             it "should be valid css#{test_version.to_s}" do
#               @css.should send("be_valid_css#{test_version.to_s}".to_sym)
#             end
#           end
#         end
#       end
#     end
#   end
#   
#   describe "with caching" do
#     before(:each) do
#       BeValidAsset::Configuration.enable_caching = true
#       FileUtils.rm Dir.glob(BeValidAsset::Configuration.cache_path + '/*')
#     end
#     after(:each) do
#       BeValidAsset::Configuration.enable_caching = false
#     end
# 
#     it "should validate valid css and cache the response" do
#       css = get_file('valid.css')
#       count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
#       css.should be_valid_css
#       Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
#     end
# 
#     it "should validate valid css using the cached response" do
#       css = get_file('valid.css')
#       css.should be_valid_css
# 
#       Net::HTTP.should_not_receive(:start)
#       css.should be_valid_css
#     end
# 
#     it "should not validate invalid css, but still cache the response" do
#       css = get_file('invalid.css')
#       count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
#       lambda {
#         css.should be_valid_css
#       }.should raise_error(SpecFailed) { |e|
#         e.message.should match(/expected css to be valid, but validation produced these errors/)
#         e.message.should match(/Invalid css: line 8: Property wibble doesn't exist/)
#       }
#       Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
#     end
# 
#     it "should not validate invalid css, but use the cached response" do
#       css = get_file('invalid.css')
#       css.should_not be_valid_css
# 
#       Net::HTTP.should_not_receive(:start)
#       lambda {
#         css.should be_valid_css
#       }.should raise_error(SpecFailed) { |e|
#         e.message.should match(/expected css to be valid, but validation produced these errors/)
#         e.message.should match(/Invalid css: line 8: Property wibble doesn't exist/)
#       }
#     end
# 
#     it "should not cache the result unless it is an HTTP OK response" do
#       css = get_file('valid.css')
#       count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
# 
#       r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
#       h = Net::HTTP.new(BeValidAsset::Configuration.css_validator_host)
#       h.stub!(:post2).and_return(r)
#       Net::HTTP.stub!(:start).and_return(h)
# 
#       lambda {
#         css.should be_valid_css
#       }.should raise_error
#       Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count)
#     end
# 
#     it "should use the cached result (if available) when network tests disabled" do
#       css = get_file('valid.css')
#       css.should be_valid_css
# 
#       ENV['NONET'] = 'true'
# 
#       Net::HTTP.should_not_receive(:start)
#       css.should be_valid_css
# 
#       ENV.delete('NONET')
#     end
# 
#     it "should mark test as pending if network tests are disabled, and no cached result is available" do
#       ENV['NONET'] = 'true'
# 
#       css = get_file('valid.css')
#       lambda {
#         css.should be_valid_css
#       }.should raise_error(RSpec::Core::Pending::PendingDeclaredInExample)
# 
#       ENV.delete('NONET')
#     end
#   end
# end