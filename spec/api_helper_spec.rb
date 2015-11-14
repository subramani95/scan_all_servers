require_relative 'spec_helper'

describe ApiHelper do
  describe "launch scans" do
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
