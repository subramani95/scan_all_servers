# example script to initiate scans
# on all active servers
# Eric Hoffmann <ehoffmann@cloudpassage.com>

require 'optparse'
require 'oauth2'
require 'rest-client'
require 'json'
require 'yaml'

# API helper class
class API
  def initialize (key_id, secret_key, host)
    client = OAuth2::Client.new(key_id, secret_key,
                  :site => "https://#{host}",
                  :token_url => '/oauth/access_token')
    token = client.client_credentials.get_token.token
    @base = "https://#{host}/v1"
    @header = {'Authorization' => "Bearer #{token}"}
  end
  def get(url)
    RestClient.get("#{@base}/#{url}", @header){|resp, req, res, &block|
    if (200..499).include? resp.code
      return resp
    else
      resp.return!(req, res, &block)
    end
    }
  end
  def post(url, body)
    RestClient.post("#{@base}/#{url}", body, @header){|resp, req, res, &block|
    if (200..499).include? resp.code
      return resp
    else
      resp.return!(req, res, &block)
    end
    }
  end
end

# pass in scan type 
options = {}
parser = OptionParser.new do |opts|
  opts.on('--sva', 'SVA scan') do |sva|
    options[:sva] = {:scan => {:module => "svm"}}
  end
  opts.on('--csm', 'CSM scan') do |csm|
    options[:csm] = {:scan => {:module => "sca"}}
  end
  opts.on('--sam', 'SAM scan') do |sam|
    options[:sam] = {:scan => {:module => "sam"}}
  end
  opts.on('--fim', 'FIM scan (requires active baseline)') do |fim|
    options[:fim] = {:scan => {:module => "fim"}}
  end
  msg = "usage: scan_active_srvs.rb [ --sva | --csm | --sam | --fim ]"
  opts.on('-h', '--help', msg) do
    puts opts
    exit
  end
end
parser.parse!

# setup the account specific API-Client key/secret and
# save these in a dot file like ~/.halo Reference the
# location as a ENV param instead of "hardcoding"
# them into this script (which may end up in a repo
# by mistake)
#
# the format of the yaml file ie ~/.halo
# halo-acct1:
#   key_id : XXXXXXX1
#   secret_key : XXXXXXXXXXXXXXXXXXXXXXXXXX1
#
# optionally, add a second, third etc. acct key/secret
# halo-acct2:
#   key_id : XXXXXXX2
#   secret_key : XXXXXXXXXXXXXXXXXXXXXXXXXX2
#
# and adding an additional grid param is supported as well
# halo-acct3:
#   key_id : XXXXXXX3
#   secret_key : XXXXXXXXXXXXXXXXXXXXXXXXXX3
#   grid : api.<unique>.cloudpassage.com
#
# don't forget to add and export HALO_API_KEY_FILE
# in your ~/.bash_profile Should look something like
# HALO_API_KEY_FILE="/home/ehoffmann/.halo"
# export HALO_API_KEY_FILE
begin
  api_keys = YAML.load_file("#{ENV['HALO_API_KEY_FILE']}")
  srv_counts = Hash.new()
rescue => e
  puts "[ERROR] loading api_keys"
  puts e
  exit
end

# loop through each acct
api_keys.each do |acct, attrs|
  if attrs['grid'].nil? # set a default
    attrs['grid'] = 'api.cloudpassage.com'
  end
  # setup our api session
  @api = API.new(attrs['key_id'], attrs['secret_key'], attrs['grid'])

  # search for active servers
  resp = @api.get("/servers?state=active")
  data = JSON.parse(resp)

  # iterate through each server, and launch the scan 
  scan_type = nil
  body = nil
  options.each do |o|
    scan_type = o[0]
    body = o[1]

    data['servers'].each do |srv|
      r = @api.post("/servers/#{srv['id']}/scans", body)
      if r.code == 202
        puts "[INFO] successfully launched #{scan_type} against #{srv['hostname']}:#{srv['connecting_ip_address']}"
      else
        puts "[WARNING] #{scan_type} against #{srv['hostname']}:#{srv['connecting_ip_address']} had a issue. Returned: #{r.code}"
        puts "[WARNING] #{r}"
      end
    end
  end
end
