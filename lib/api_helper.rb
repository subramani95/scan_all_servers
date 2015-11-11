require 'oauth2'
require 'rest-client'

class ApiHelper
  def initialize(key_id, secret_key, host)
    client = OAuth2::Client.new(key_id, secret_key,
                                site: "https://#{host}",
                                token_url: '/oauth/access_token')
    token = client.client_credentials.get_token.token
    @base = "https://#{host}/v1"
    @header = { 'Authorization' => "Bearer #{token}" }
  end

  def get(url)
    RestClient.get("#{@base}/#{url}", @header) do |resp, req, res, &block|
      if (200..499).include? resp.code
        return resp
      else
        resp.return!(req, res, &block)
      end
    end
  end

  def post(url, body)
    RestClient.post("#{@base}/#{url}", body, @header) do |resp, req, res, &block|
      if (200..499).include? resp.code
        return resp
      else
        resp.return!(req, res, &block)
      end
    end
  end
end
