require_relative 'spec_helper'

describe AccountManager do
  before do
    @fake_accounts = {
      'halo1' => {
        'key_id' => 'some_key_id',
        'secret_key' => 'some_secret_key'
      },
      'halo2' => {
        'key_id' => 'some_key_id2',
        'secret_key' => 'some_secret_key2',
        'grid' => 'api.somegrid.local'
      }
    }
  end

  it "exits when no config file given and not environment specified" do
    ENV['HALO_API_KEY_FILE'] = nil
    am = AccountManager.new
    expect { am.api_keys }.to raise_error RuntimeError
  end

  it "loads locally specified config file" do
    api_keys = AccountManager.new('./spec/fixtures/halo_accounts.yml').api_keys
    expect(api_keys).to eq(@fake_accounts)
  end
end
