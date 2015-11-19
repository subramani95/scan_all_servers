#!/usr/bin/env ruby

# example script to initiate scans
# on all active servers
# Eric Hoffmann <ehoffmann@cloudpassage.com>

require 'optparse'
require 'oauth2'
require 'rest-client'
require 'json'
require 'yaml'

require './lib/api_helper'
require './lib/account_manager'

# pass in scan type
options = {}
parser = OptionParser.new do |opts|
  opts.on('--sva', 'SVA scan') do |_sva|
    options[:sva] = { scan: { module: 'svm' } }
  end
  opts.on('--csm', 'CSM scan') do |_csm|
    options[:csm] = { scan: { module: 'sca' } }
  end
  opts.on('--sam', 'SAM scan') do |_sam|
    options[:sam] = { scan: { module: 'sam' } }
  end
  opts.on('--fim', 'FIM scan (requires active baseline)') do |_fim|
    options[:fim] = { scan: { module: 'fim' } }
  end
  opts.on('--group ', 'Filter active servers by group_name (partial matches)') do |group|
    options[:group] = URI.encode("&group_name=#{group}")
  end
  msg = "usage: scan_all_servers.rb [ --sva | --csm | --sam | --fim ][--group=\"Group Name\"]"
  opts.on('-h', '--help', msg) do
    puts opts
    exit
  end
end
parser.parse!

# Ensure HALO_API_KEY_FILE environment is pointing at a valid configuration
# file. See lib/account_manager.rb for details.
api_keys = AccountManager.new.api_keys

# loop through each acct
api_keys.each do |_acct, attrs|
  attrs['grid'] = 'api.cloudpassage.com' if attrs['grid'].nil? # set a default
  @api = ApiHelper.new(attrs['key_id'], attrs['secret_key'], attrs['grid'])

  # search for active servers
  if group = options.delete(:group).nil?
    resp = @api.get('/servers?state=active')
  else
    resp = @api.get("/servers?state=active#{group}")
  end

  data = JSON.parse(resp)
  options.each do |scan_type, body|
    data['servers'].each do |server|
      r = @api.post("/servers/#{server['id']}/scans", body)
      if r.code == 202
        puts "[INFO] successfully launched #{scan_type} against #{server['hostname']}:#{server['connecting_ip_address']}"
      else
        puts "[WARNING] #{scan_type} against #{server['hostname']}:#{server['connecting_ip_address']} had a issue. Returned: #{r.code}"
        puts "[WARNING] #{r}"
      end
    end
  end
end
