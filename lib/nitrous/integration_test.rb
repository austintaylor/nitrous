require 'webrick_server'
module Nitrous
  class IntegrationTest < Test
    include ActionController::Assertions::SelectorAssertions
    attr_accessor :cookies, :response, :status, :headers
    at_exit {start_server}
    
    def self.start_server
      @server_thread = Thread.start do
        DispatchServlet.dispatch(:ip => '0.0.0.0', :server_type => WEBrick::SimpleServer, :port => 4033, :server_root => File.expand_path(RAILS_ROOT + "/public/"))
      end
    end
    
    ActionController::Routing::Routes.install_helpers(self)
    def url_for(options)
      options.delete(:only_path)
      ActionController::Routing::Routes.generate(options)
    end
    
    def navigate_to(path)
      get path
      follow_redirect! if redirect?
      puts response.body if error?
      assert !error?
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
      process(headers) do
        http_session.get(path, headers)
      end
    end
    
    def post(path, parameters=nil, headers={})
      data = requestify(parameters) || ""
      headers['CONTENT_LENGTH'] = data.length.to_s
      process(headers) do
        http_session.post(path, data, headers)
      end
    end
    
    def delete(path, parameters=nil, headers={})
      headers['QUERY_STRING'] = requestify(parameters) || ""
      process(headers) do
        http_session.delete(path, headers)
      end
    end
    
    def put(path, parameters=nil, headers={})
      data = requestify(parameters) || ""
      headers['CONTENT_LENGTH'] = data.length.to_s
      process(headers) do
        http_session.put(path, data, headers)
      end
    end
    
    def process(headers)
      headers['Cookie'] = encode_cookies unless encode_cookies.blank?
      self.response = yield
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
      uri = URI.parse("http://localhost:4033/") unless @http
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
