# frozen_string_literal: true

require_relative "./helper"

class TestBridgetownCms < Bridgetown::TestCase
  def setup
    Bridgetown.reset_configuration!
    @config = Bridgetown.configuration(
      "root_dir"    => root_dir,
      "source"      => source_dir,
      "destination" => dest_dir,
      "quiet"       => true
    )
    @config.run_initializers! context: :static
    @site = Bridgetown::Site.new(@config)

    with_metadata title: "My Awesome Site" do
      @site.process
    end
  end

  describe "BridgetownCms" do
    before do
      @contents = File.read(dest_dir("index.html"))
    end

    it "outputs the overridden metadata" do
      assert_includes @contents, "<title>My Awesome Site</title>"
    end

    it "outputs the sample Liquid tag" do
      assert_includes @contents, "This plugin works!"
    end
  end
end
