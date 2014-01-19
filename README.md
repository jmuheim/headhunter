# Headhunter

Headhunter is an HTML and CSS validation tool that injects itself into your Rails feature tests and automagically checks all your generated HTML and CSS for validity.

In addition, it also looks out for unused (and therefore superfluous) CSS selectors.

## How to execute

Just set the environment variable `HEADHUNTER` to `true` when running your tests, e.g.:

- `rake HEADHUNTER=true`
- `rspec HEADHUNTER=true`
- `cucumber HEADHUNTER=true`

Headhunter doesn't keep your tests from passing if invalid HTML or unused CSS is found. Instead it displays a short statistic after the tests are run.

    30/30 |============================= 100 ==============================>| Time: 00:00:02

    Finished in 2.65 seconds
    30 examples, 0 failures

    Validated 42 HTML pages.
    41 pages are valid.
    1 page is invalid.
    Open .validation/results.html to view full results.

    Found 23 CSS selectors.
    20 selectors are in use.
    3 selectors are not in use: a img, #flash.failure, input[type='file']

## How it works

Headhunter registers itself as middleware in the Rack stack and triggers validation for every HTML response.

For every `.css` file, validation is also triggered. In addition, it iterates over every HTML page's selectors to see whether there exist any unused CSS definitions in your `.css` files.

For being able to validate CSS, `rake assets:precompile` is triggered at the beginning of running tests. This may slow down starting your tests a bit. (Notice: after the tests have finished, the precompiled assets are also removed automatically by running `rake assets:clobber`.)

## Requirements

### Tidy HTML

[Tidy HTML](http://tidy.sourceforge.net/) should be installed on a typical OSX and Linux installation already. You're not developing on a Windows machine, are you?!

If you want to validate HTML5 (and you should want to!), install the HTML5 version like described here: [homebrew tidy html5](http://techblog.willshouse.com/2013/10/21/homebrew-tidy-html5/).

### Working internet connection

You need a working internet connection to run CSS validation.

## Known issues and plans

- It would be nice to use Rails' own assets compilation that's executed when the first JavaScript test is run. Anyone has an idea on how to do this?
- At the moment, in addition to precompiling and removing your assets, `rake assets:clobber` is run also **before** precompiling! The issue is explained here: [Rake assets are generated twice when precompiling them once from command line and once from within a Ruby script](http://stackoverflow.com/questions/20938891/rake-assets-are-generated-twice-when-precompiling-them-once-from-command-line-an)
- Instead of running `rake assets:clobber`, it may be also sufficient to simply remove all *.css files from `public/assets/stylesheets` manually. This would save some compilation time.

## Disclaimer

Headhunter is heavily inspired by Aanand Prasad's nice (but outdated) [Deadweight](https://github.com/aanand/deadweight) gem. Thank you for your pioneer work!

USE THIS GEM AT YOUR OWN RISK