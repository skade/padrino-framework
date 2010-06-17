require File.expand_path(File.dirname(__FILE__) + '/helper')

class PadrinoTestApp < Padrino::Application; end

class TestApplication < Test::Unit::TestCase
  def teardown
    remove_views
  end

  context 'for application functionality' do

    should 'check default options' do
      assert File.identical?(__FILE__, PadrinoTestApp.app_file)
      assert_equal :padrino_test_app, PadrinoTestApp.app_name
      assert_equal :test, PadrinoTestApp.environment
      assert_equal Padrino.root("views"), PadrinoTestApp.views
      assert PadrinoTestApp.raise_errors
      assert !PadrinoTestApp.logging
      assert !PadrinoTestApp.sessions
    end

    should 'check padrino specific options' do
      assert !PadrinoTestApp.instance_variable_get(:@_configured)
      PadrinoTestApp.send(:setup_application!)
      assert_equal :padrino_test_app, PadrinoTestApp.app_name
      assert_equal 'StandardFormBuilder', PadrinoTestApp.default_builder
      assert PadrinoTestApp.instance_variable_get(:@_configured)
      assert !PadrinoTestApp.reload?
      assert !PadrinoTestApp.flash
    end

    #compare to: test_routing: allow global provides
    should "set content_type to :html if none can be determined" do
      mock_app do
        provides :xml

        get("/foo"){ "Foo in #{content_type}" }
        get("/bar"){ "Foo in #{content_type}" }
      end

      get '/foo', {}, { 'HTTP_ACCEPT' => 'application/xml' }
      assert_equal 'Foo in xml', body
      get '/foo'
      assert not_found?

      get '/bar', {}, { 'HTTP_ACCEPT' => 'application/xml' }
      assert_equal "Foo in html", body
    end
    
    should 'use correct layout with each controller' do
      create_layout :foo, "foo layout at <%= yield %>"
      create_layout :bar, "bar layout at <%= yield %>"
      create_layout :application, "default layout at <%= yield %>"
      mock_app do
        get("/"){ render :erb, "application" }
        controller :foo do
          layout :foo
          get("/"){ render :erb, "foo" }
        end
        controller :bar do
          layout :bar
          get("/"){ render :erb, "bar" }
        end
        controller :none do
          get("/") { render :erb, "none" }
          get("/with_foo_layout")  { render :erb, "none with layout", :layout => :foo }
        end
      end
      get "/foo"
      assert_equal "foo layout at foo", body
      get "/bar"
      assert_equal "bar layout at bar", body
      get "/none"
      assert_equal "default layout at none", body
      get "/none/with_foo_layout"
      assert_equal "foo layout at none with layout", body
      get "/"
      assert_equal "default layout at application", body
    end

  end
end
