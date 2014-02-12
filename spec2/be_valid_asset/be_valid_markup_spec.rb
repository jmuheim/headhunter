require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

unless defined?(SpecFailed)
  SpecFailed = RSpec::Expectations::ExpectationNotMetError
end

describe 'be_valid_markup' do

  describe "without caching" do
    it "should validate a valid string" do
      html = get_file('valid.html')
      html.should be_valid_markup
    end

    it "should validate a valid xhtml response" do
      response = MockResponse.new(get_file('valid.html'))
      response.should be_valid_markup
    end
    
    it "should validate a valid html5 response" do
      response = MockResponse.new(get_file('valid.html5'))
      response.should be_valid_markup
    end

    it "should validate a valid html5 response when only 'source' is available" do
      response = mock(:source => get_file('valid.html5'))
      response.should be_valid_markup
    end
    
    it "should validate a valid html5 response when only 'body' is available" do
      response = mock(:body => get_file('valid.html5'))
      response.should be_valid_markup
    end

    it "should validate if body is not a string but can be converted to valid string" do
      response = MockResponse.new(stub("XHTML", :to_s => get_file('valid.html')))
      response.should be_valid_markup
    end

    it "should validate a valid fragment" do
      "<p>This is a Fragment</p>".should be_valid_markup_fragment
    end

    it "should not validate an invalid string" do
      html = get_file('invalid.html')
      lambda {
        html.should be_valid_markup
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/expected markup to be valid, but validation produced these errors/)
        e.message.should match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        e.message.should match(/Invalid markup: line 12: end tag for element "b" which is not open/)
      }
    end

    it "should not validate an invalid response" do
      response = MockResponse.new(get_file('invalid.html'))
      lambda {
        response.should be_valid_markup
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/expected markup to be valid, but validation produced these errors/)
        e.message.should match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        e.message.should match(/Invalid markup: line 12: end tag for element "b" which is not open/)
      }
    end

    it "should display invalid content when requested" do
      BeValidAsset::Configuration.display_invalid_content = true
      html = get_file('invalid.html')
      lambda {
        html.should be_valid_markup
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/<p><b>This is an example invalid html file<\/p><\/b>/)
      }
      BeValidAsset::Configuration.display_invalid_content = false
    end

    describe "displaying invalid lines" do
      before :each do
        BeValidAsset::Configuration.display_invalid_lines = true
      end
      after :each do
        BeValidAsset::Configuration.display_invalid_lines = false
        BeValidAsset::Configuration.display_invalid_lines_count = 5 # Restore the default value
      end

      it "should display invalid lines when requested" do
        html = get_file('invalid.html')
        lambda do
          html.should be_valid_markup
        end.should raise_error(SpecFailed) { |e|
          e.message.should match(/expected markup to be valid, but validation produced these errors/)
          e.message.should_not match(/0009  :/)
          e.message.should match(/0010  :/)
          e.message.should match(/0011  :/)
          e.message.should match(/0012>>:/)
          e.message.should match(/0013  :/)
          e.message.should match(/0014  :/)
          e.message.should_not match(/0015  :/)
        }
      end

      it "should display specified invalid lines window when requested" do
        BeValidAsset::Configuration.display_invalid_lines_count = 3
        html = get_file('invalid.html')
        lambda do
          html.should be_valid_markup
        end.should raise_error(SpecFailed) { |e|
          e.message.should match(/expected markup to be valid, but validation produced these errors/)
          e.message.should_not match(/0010  :/)
          e.message.should match(/0011  :/)
          e.message.should match(/0012>>:/)
          e.message.should match(/0013  :/)
          e.message.should_not match(/0014  :/)
        }
      end

      it "should not underrun the beginning of the source" do
        BeValidAsset::Configuration.display_invalid_lines_count = 7
        html = get_file('invalid2.html')
        lambda do
          html.should be_valid_markup
        end.should raise_error(SpecFailed) { |e|
          e.message.should match(/expected markup to be valid, but validation produced these errors/)
          e.message.should_not match(/0000  :/)
          e.message.should match(/0001  :/)
          e.message.should match(/0003>>:/)
        }
      end

      it "should not overrun the end of the source" do
        BeValidAsset::Configuration.display_invalid_lines_count = 11
        html = get_file('invalid.html')
        lambda do
          html.should be_valid_markup
        end.should raise_error(SpecFailed) { |e|
          e.message.should match(/expected markup to be valid, but validation produced these errors/)
          e.message.should match(/0012>>:/)
          e.message.should match(/0015  :/)
          e.message.should_not match(/0016  :/)
        }
      end
    end

    it "should fail when passed a response with a blank body" do
      response = MockResponse.new('')
      lambda {
        response.should be_valid_markup
      }.should raise_error(SpecFailed)
    end

    it "should fail unless resposne is HTTP OK" do
      html = get_file('valid.html')

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.markup_validator_host)
      h.stub!(:post2).and_return(r)
      Net::HTTP.stub!(:start).and_return(h)

      lambda {
        html.should be_valid_markup
      }.should raise_error
    end

    it "should mark test as pending if network tests are disabled" do
      ENV['NONET'] = 'true'

      html = get_file('valid.html')
      lambda {
        html.should be_valid_markup
      }.should raise_error(RSpec::Core::Pending::PendingDeclaredInExample)

      ENV.delete('NONET')
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

    it "should validate a valid string and cache the response" do
      html = get_file('valid.html')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      html.should be_valid_markup
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end

    it "should validate a valid string using the cached response" do
      html = get_file('valid.html')
      html.should be_valid_markup

      Net::HTTP.should_not_receive(:start)
      html.should be_valid_markup
    end

    it "should not validate an invalid response, but still cache the response" do
      response = MockResponse.new(get_file('invalid.html'))
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      lambda {
        response.should be_valid_markup
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/expected markup to be valid, but validation produced these errors/)
        e.message.should match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        e.message.should match(/Invalid markup: line 12: end tag for element "b" which is not open/)
      }
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end

    it "should not validate an invalid response, but use the cached response" do
      response = MockResponse.new(get_file('invalid.html'))
      response.should_not be_valid_markup

      Net::HTTP.should_not_receive(:start)
      lambda {
        response.should be_valid_markup
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/expected markup to be valid, but validation produced these errors/)
        e.message.should match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        e.message.should match(/Invalid markup: line 12: end tag for element "b" which is not open/)
      }
    end

    it "should not cache the result unless it is an HTTP OK response" do
      html = get_file('valid.html')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.markup_validator_host)
      h.stub!(:post2).and_return(r)
      Net::HTTP.stub!(:start).and_return(h)

      lambda {
        html.should be_valid_markup
      }.should raise_error
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count)
    end

    it "should use the cached result (if available) when network tests disabled" do
      html = get_file('valid.html')
      html.should be_valid_markup

      ENV['NONET'] = 'true'

      Net::HTTP.should_not_receive(:start)
      html.should be_valid_markup

      ENV.delete('NONET')
    end

    it "should mark test as pending if network tests are disabled, and no cached result is available" do
      ENV['NONET'] = 'true'

      html = get_file('valid.html')
      lambda {
        html.should be_valid_markup
      }.should raise_error(RSpec::Core::Pending::PendingDeclaredInExample)

      ENV.delete('NONET')
    end

    describe "with default modifiers" do
      it "should strip off cache busters for href and src attributes" do
        html = get_file('valid_with_cache_busters.html')
        html_modified = get_file('valid_without_cache_busters.html')
        be_valid_markup = BeValidAsset::BeValidMarkup.new
        be_valid_markup.should_receive(:validate).with({:fragment => html_modified})
        be_valid_markup.matches?(html)
      end

      it "should not strip off cache busters if caching isn't enabled" do
        BeValidAsset::Configuration.enable_caching = false
        html = get_file('valid_with_cache_busters.html')
        be_valid_markup = BeValidAsset::BeValidMarkup.new
        be_valid_markup.should_receive(:validate).with({:fragment => html})
        be_valid_markup.matches?(html)
      end
    end
  end

  describe "markup modification" do
    before :each do
      BeValidAsset::Configuration.markup_modifiers = [[/ srcset=".*"/, '']]
    end
    after :each do
      BeValidAsset::Configuration.markup_modifiers = []
    end
    it "should apply modification" do
      html = get_file('html_with_srcset.html')
      html_modified = get_file('html_without_srcset.html')
      be_valid_markup = BeValidAsset::BeValidMarkup.new
      be_valid_markup.should_receive(:validate).with({:fragment => html_modified})
      be_valid_markup.matches?(html)
    end
  end

  describe "Proxying" do
    before :each do
      r = Net::HTTPSuccess.new('1.1', 200, 'HTTPOK')
      r['x-w3c-validator-status'] = 'Valid'
      @http = mock('HTTP')
      @http.stub!(:post2).and_return(r)

      @html = MockResponse.new(get_file('valid.html'))
    end

    it "should use direct http without ENV['http_proxy']" do
      ENV.delete('http_proxy')
      Net::HTTP.should_receive(:start).with(BeValidAsset::Configuration.markup_validator_host).and_return(@http)
      @html.should be_valid_markup
    end

    it "should use proxied http connection with ENV['http_proxy']" do
      ENV['http_proxy'] = "http://user:pw@localhost:3128"
      Net::HTTP.should_receive(:start).with(BeValidAsset::Configuration.markup_validator_host, nil, 'localhost', 3128, "user", "pw").and_return(@http)
      @html.should be_valid_markup
      ENV.delete('http_proxy')
    end

    it "should raise exception with invalid http_proxy" do
      ENV['http_proxy'] = "http://invalid:uri"
      lambda {
        @html.should be_valid_markup
      }.should raise_error(URI::InvalidURIError)
      ENV.delete('http_proxy')
    end
  end
end
