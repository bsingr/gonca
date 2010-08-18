require 'test/unit'
require 'lib/server'
require 'rubygems'
require 'capybara'
require 'capybara/dsl'

class Gonca < Test::Unit::TestCase
  include Capybara

  Capybara.current_driver = :selenium
  Capybara.app_host = 'http://www.website-to-test.com'
  Capybara.run_server = true
  Capybara.default_wait_time = 20

  @@signed_in = false

  def setup
    Capybara.app = Sinatra::Application.new
    intranet_sign_in unless @@signed_in
  end

  def intranet_sign_in
    visit '/'
    within("//form[@name='credentials']") do
      fill_in 'username', :with => 'fooUser' # intranet user
      fill_in 'password', :with => 'barPass' # intranet pass
    end
    click ' Login '
    @@signed_in = true
  end

  def inject_client
    js_files = ['lib/jquery-1.4.2.min.js', 'lib/client.js']
    js_files.each do |filename|
      if File.exists?(filename)
        puts filename
        page.execute_script(File.new(filename).readlines.to_s)
      end
    end
  end

  def write_report
    tmpl = File.new('lib/jspec-report.tmpl.html').readlines.to_s
    report = page.evaluate_script('jQuery(".jspec").html()')
    html = tmpl.gsub('___REPORT___', report)
    File.open('jspec-report.log.html', 'w') do |f|
      f.write(html)
    end
  end

  def calc_asserts
    passes = page.locate(:css, ".passes em").text
    passes.to_i.times {|i| assert true }

    fails = page.locate(:css, ".failures em").text
    fails.to_i.times {|i| assert false }
  end

  def jspec_exec(filename)
    visit '/dashboard'

    inject_client
    page.execute_script("Gonca.syncXSS('#{filename}', Gonca.runSuites);")

    page.has_css?("#jspec-report") # does a delay
    write_report
    calc_asserts
  end

  ['unit/test.js', 'unit/test2.js'].each do |filename|
    define_method "test_#{filename.gsub(".", "_")}" do
      jspec_exec(filename)
    end
  end
end
