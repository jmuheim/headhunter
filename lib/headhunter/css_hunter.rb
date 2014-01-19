class Headhunter
  class CssHunter
    def initialize(root)
      @root = root
      @stylesheets = []

      load_css!
    end

    def process!(url, html)
    
    end

    def report
    
    end

    def clean_up!
      remove_assets!
    end

    private

    def load_css!
      precompile_assets!
      @stylesheets += Dir.chdir("#{@root}/public") { Dir.glob("assets/*.css") }
    end

    # TODO: suppress logging output of rake tasks!
    def precompile_assets!
      system "rake assets:clobber HEADHUNTER=false" # Remove existing assets! This seems to be necessary to make sure that they don't exist twice, see http://stackoverflow.com/questions/20938891
      system "rake assets:precompile HEADHUNTER=false"
    end

    def remove_assets!
      system "rake assets:clobber HEADHUNTER=false"
    end
  end
end
