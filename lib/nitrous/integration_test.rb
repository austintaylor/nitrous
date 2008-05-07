require 'webrick_server'
module Nitrous
  class IntegrationTest < Test
    attr_accessor :cookies, :response
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
    
    %w[get post put delete].each do |method|
      class_eval <<-"end;"
        def #{method}(path, parameters=nil, headers=nil)
          process :#{method}, path, parameters, headers
        end
      end;
    end
    
    def process(method, path, parameters, headers)
      self.response = http_session.send(method, path, headers)
      self.cookies ||= response['set-cookie']
    end

    private
    def http_session
      uri = URI.parse("http://localhost:4033/") unless @http
      @http ||= Net::HTTP.start(uri.host, uri.port)
    end

    def headers
      returning Hash.new do |headers|
        headers['Cookie'] = cookies if cookies
      end
    end
  end
end
