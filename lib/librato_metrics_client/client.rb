require 'faraday'

module LibratoMetricsClient
  class Client
    def self.connection
      @connection ||= begin
        conn = Faraday::Connection.new do |b|
          b.request :url_encoded
          b.request :json
          b.adapter Faraday.default_adapter
        end

        conn.headers[:content_type] = 'application/json'
        conn.url_prefix = 'https://metrics-api.librato.com/v1/'

        conn
      end
    end

    def initialize(user, token)
      @user  = user
      @token = token
    end

    def connection
      @connection ||= begin
        conn = self.class.connection.dup
        conn.basic_auth @user, @token
        conn
      end
    end

    def post(body)
      result = connection.post 'metrics.json' do |req|
        req.body = body
      end
    end
  end
end