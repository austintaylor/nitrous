require 'webrick_server'
require 'action_controller/assertions/selector_assertions'
require 'rails_ext'
module Nitrous
  class IntegrationTest < RailsTest
    include ActionController::Assertions::SelectorAssertions
    attr_accessor :cookies, :response, :status, :headers, :current_uri
    at_exit {start_server}
    
    def self.start_server
      # parameters = [
      #   "start",
      #   "-p", '4033',
      #   "-a", '0.0.0.0',
      #   "-e", 'development',
      #   "-l", "#{RAILS_ROOT}/tmp/mongrel.log",
      #   "-c", RAILS_ROOT,
      #   "-r", File.expand_path(RAILS_ROOT + "/public/"),
      #   "-P", "#{RAILS_ROOT}/tmp/pids/mongrel.pid"
      # ]
      # `mongrel_rails #{parameters.join(" ")} -d`
      @server_thread = Thread.start do
        Socket.do_not_reverse_lookup = true # patch for OS X
        server = WEBrick::HTTPServer.new(:BindAddress => '0.0.0.0', :ServerType => WEBrick::SimpleServer, :Port => 4022, :AccessLog => [], :Logger => WEBrick::Log.new("/dev/null"))
        server.mount('/', DispatchServlet, :server_root => File.expand_path(RAILS_ROOT + "/public/"))
        trap("INT") { server.shutdown }
        server.start
      end
      sleep 0.001 until @server_thread.status == "sleep"
    end
    
    ActionController::Routing::Routes.install_helpers(self)
    def url_for(options)
      if options.delete(:only_path)
        ActionController::Routing::Routes.generate(options)
      else
        "http://localhost:4022" + ActionController::Routing::Routes.generate(options)
      end
    end
    
    def navigate_to(path)
      get path
      follow_redirect! if redirect?
      puts response.body if error?
      assert !error?
    end

    def submit_form(id, data = {})
      id, data = nil, id if id.is_a?(Hash)
      form = css_select(id ? "form##{id}" : "form").first
      fail(id ? "Form not found with id <#{id}>" : "No form found") unless form
      validate_form_fields(form, data)
      self.send(form["method"], form["action"], data.with_indifferent_access.reverse_merge(hidden_values(form)))
      puts response.body if error?
      assert !error?
      @redisplay = true if !redirect? && id && css_select("form##{id}").first
      follow_redirect! if redirect?
      puts response.body if error?
      assert !error? 
    end
    
    def click_link(url)
      fail("No link found with url <#{url}>") unless css_select("a[href=#{url}]").first
      navigate_to(url)
    end
    
    def assert_form_redisplayed
      assert @redisplay
    end
    
    def field_value(name)
      css_select(html_document.root, "input, select, textarea").detect {|field| field["name"] == name}["value"]
    end

    def assert_viewing(request_uri, message="")
      assert_match %r(#{request_uri}(\?|&|$)), current_uri, message
    end
    
    def assert_page_contains!(string)
      fail("Expected page to contain <#{string}> but it did not. Page:\n#{response.body}") unless response.body.include?(string)
    end
    
    def hidden_values(form)
      hiddens = css_select(form, "input[type=hidden]")
      pairs = hiddens.inject({}) {|p,h| p[h["name"]] = h["value"]; p}
      ActionController::UrlEncodedPairParser.new(pairs).result
    end

    def validate_form_fields(form, data)
      data.to_fields.each do |name, value|
        form_fields = css_select form, "input, select, textarea"
        matching_field = form_fields.detect {|field| field["name"] == name || field["name"] == "#{name}[]"}
        fail "Could not find a form field having the name #{name}" unless matching_field
        assert_equal "multipart/form-data", form["enctype"], "Form <#{selector}> has a file field <#{name}>, but the enctype is not multipart/form-data" if matching_field["type"] == "file"
      end
    end
    
    def view(email)
      @response = ActionController::TestResponse.new
      @response.body = email.body
      @html_document = nil
    end

    def follow_redirect!
      raise "not a redirect! #{@status} #{@status_message}" unless redirect?
      get(interpret_uri(headers['location'].first))
      status
    end

    def html_document
      xml = @response.content_type =~ /xml$/
      @html_document ||= HTML::Document.new(@response.body, false, xml)
    end
    
    def interpret_uri(path)
      location = URI.parse(path)
      location.query ? "#{location.path}?#{location.query}" : location.path
    end
    
    def get(path, parameters=nil, headers={})
      headers['QUERY_STRING'] = requestify(parameters) || ""
      process(headers, path) do
        http_session.get(path, headers)
      end
    end
    
    def post(path, parameters=nil, headers={})
      data = requestify(parameters) || ""
      headers['CONTENT_LENGTH'] = data.length.to_s
      process(headers, path) do
        http_session.post(path, data, headers)
      end
    end
    
    def delete(path, parameters=nil, headers={})
      headers['QUERY_STRING'] = requestify(parameters) || ""
      process(headers, path) do
        http_session.delete(path, headers)
      end
    end
    
    def put(path, parameters=nil, headers={})
      data = requestify(parameters) || ""
      headers['CONTENT_LENGTH'] = data.length.to_s
      process(headers, path) do
        http_session.put(path, data, headers)
      end
    end
    
    def process(headers, path=nil)
      headers['Cookie'] = encode_cookies unless encode_cookies.blank?
      self.response = yield
      self.current_uri = path
      @html_document = nil
      parse_result
    end
    
    # was the response successful?
    def success?
      status == 200
    end

    # was the URL not found?
    def missing?
      status == 404
    end

    # were we redirected?
    def redirect?
      (300..399).include?(status)
    end

    # was there a server-side error?
    def error?
      (500..599).include?(status)
    end

    private
    
    def encode_cookies
      (cookies||{}).inject("") do |string, (name, value)|
        string << "#{name}=#{value}; "
      end
    end
    
    def http_session
      uri = URI.parse("http://localhost:4022/") unless @http
      @http ||= Net::HTTP.start(uri.host, uri.port)
    end

    def parse_result
      @headers = @response.to_hash
      @cookies = {}
      (@headers['set-cookie'] || [] ).each do |string|
        name, value = string.match(/^([^=]*)=([^;]*);/)[1,2]
        @cookies[name] = value
      end
      @status, @status_message = @response.code.to_i, @response.message
    end
    
    def name_with_prefix(prefix, name)
      prefix ? "#{prefix}[#{name}]" : name.to_s
    end

    def requestify(parameters, prefix=nil)
      if Hash === parameters
        return nil if parameters.empty?
        parameters.map { |k,v| requestify(v, name_with_prefix(prefix, k)) }.join("&")
      elsif Array === parameters
        parameters.map { |v| requestify(v, name_with_prefix(prefix, "")) }.join("&")
      elsif prefix.nil?
        parameters
      else
        "#{CGI.escape(prefix)}=#{CGI.escape(parameters.to_s)}"
      end
    end
  end
end
