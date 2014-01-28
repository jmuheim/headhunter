require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

unless defined?(SpecFailed)
  SpecFailed = RSpec::Expectations::ExpectationNotMetError
end

describe Headhunter::CssValidator do
  subject(:css) { described_class.new }

  it 'should validate a valid string' do
    css.add_stylesheet('/Users/josh/Documents/Work/MuheimWebdesign/Headhunter/spec/files/valid.css')
    binding.pry
  end
  
  it "should validate an empty string" do
    ''.should be_valid_css
  end

  it "should validate a valid response" do
    response = MockResponse.new(get_file('valid.css'))
    response.should be_valid_css
  end

  it "should validate if body is not a string but can be converted to valid string" do
    response = MockResponse.new(stub("CSS", :to_s => get_file('valid.css')))
    response.should be_valid_css
  end

  it "should not validate an invalid string" do
    css = get_file('invalid.css')
    lambda {
      css.should be_valid_css
    }.should raise_error(SpecFailed) { |e|
      e.message.should match(/expected css to be valid, but validation produced these errors/)
      e.message.should match(/Invalid css: line 8: Property wibble doesn't exist/)
    }
  end

  it "should not validate an invalid response" do
    response = MockResponse.new(get_file('invalid.css'))
    lambda {
      response.should be_valid_css
    }.should raise_error(SpecFailed) { |e|
      e.message.should match(/expected css to be valid, but validation produced these errors/)
      e.message.should match(/Invalid css: line 8: Property wibble doesn't exist/)
    }
  end

  it "should display invalid content when requested" do
    BeValidAsset::Configuration.display_invalid_content = true
    css = get_file('invalid.css')
    lambda {
      css.should be_valid_css
    }.should raise_error(SpecFailed) { |e|
      e.message.should match(/wibble:0;/)
    }
    BeValidAsset::Configuration.display_invalid_content = false
  end

  it "should fail unless resposne is HTTP OK" do
    css = get_file('valid.css')

    r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
    h = Net::HTTP.new(BeValidAsset::Configuration.css_validator_host)
    h.stub!(:post2).and_return(r)
    Net::HTTP.stub!(:start).and_return(h)

    lambda {
      css.should be_valid_css
    }.should raise_error
  end

  it "should mark test as pending if ENV['NONET'] is true" do
    ENV['NONET'] = 'true'

    css = get_file('valid.css')
    lambda {
      css.should be_valid_css
    }.should raise_error(RSpec::Core::Pending::PendingDeclaredInExample)

    ENV.delete('NONET')
  end

  describe "CSS version" do
    (1..3).each do |version|
      describe version.to_s do
        before(:each) do
          @css = get_file("valid-#{version.to_s}.css")
        end
        (1..3).each do |test_version|
          if test_version < version
            it "should not be valid css#{test_version.to_s}" do
              lambda {
                @css.should send("be_valid_css#{test_version.to_s}".to_sym)
                }.should raise_error(SpecFailed)
            end
          else
            it "should be valid css#{test_version.to_s}" do
              @css.should send("be_valid_css#{test_version.to_s}".to_sym)
            end
          end
        end
      end
    end
  end
  
  describe "with caching" do
    before(:each) do
      BeValidAsset::Configuration.enable_caching = true
      FileUtils.rm Dir.glob(BeValidAsset::Configuration.cache_path + '/*')
    end
    after(:each) do
      BeValidAsset::Configuration.enable_caching = false
    end

    it "should validate valid css and cache the response" do
      css = get_file('valid.css')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      css.should be_valid_css
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end

    it "should validate valid css using the cached response" do
      css = get_file('valid.css')
      css.should be_valid_css

      Net::HTTP.should_not_receive(:start)
      css.should be_valid_css
    end

    it "should not validate invalid css, but still cache the response" do
      css = get_file('invalid.css')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      lambda {
        css.should be_valid_css
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/expected css to be valid, but validation produced these errors/)
        e.message.should match(/Invalid css: line 8: Property wibble doesn't exist/)
      }
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end

    it "should not validate invalid css, but use the cached response" do
      css = get_file('invalid.css')
      css.should_not be_valid_css

      Net::HTTP.should_not_receive(:start)
      lambda {
        css.should be_valid_css
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/expected css to be valid, but validation produced these errors/)
        e.message.should match(/Invalid css: line 8: Property wibble doesn't exist/)
      }
    end

    it "should not cache the result unless it is an HTTP OK response" do
      css = get_file('valid.css')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.css_validator_host)
      h.stub!(:post2).and_return(r)
      Net::HTTP.stub!(:start).and_return(h)

      lambda {
        css.should be_valid_css
      }.should raise_error
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count)
    end

    it "should use the cached result (if available) when network tests disabled" do
      css = get_file('valid.css')
      css.should be_valid_css

      ENV['NONET'] = 'true'

      Net::HTTP.should_not_receive(:start)
      css.should be_valid_css

      ENV.delete('NONET')
    end

    it "should mark test as pending if network tests are disabled, and no cached result is available" do
      ENV['NONET'] = 'true'

      css = get_file('valid.css')
      lambda {
        css.should be_valid_css
      }.should raise_error(RSpec::Core::Pending::PendingDeclaredInExample)

      ENV.delete('NONET')
    end
  end
end