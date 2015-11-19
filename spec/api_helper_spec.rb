require_relative 'spec_helper'

describe ApiHelper do
  # Currently this is a dumb integration test which pounds on the grid
  # to ensure the script is working. The architecture needs to be changed
  # to allow testing without hitting the grid.
  describe "launch scans" do
    before :all do
      # This will be removed once the grid response is mocked.
      ENV['HALO_API_KEY_FILE'] = Dir.home + '/.halo'
    end

    it "launches sva scan" do
      results = `ruby scan_all_servers.rb --sva`
      expect(results).to match(/INFO|WARNING/)
    end

    it "launches sca scan" do
      results = `ruby scan_all_servers.rb --csm`
      expect(results).to match(/INFO|WARNING/)
    end

    it "launches fim scan" do
      results = `ruby scan_all_servers.rb --fim`
      expect(results).to match(/INFO|WARNING/)
    end

    it "launches sam scan" do
      results = `ruby scan_all_servers.rb --sam`
      expect(results).to match(/INFO|WARNING/)
    end
  end
end
