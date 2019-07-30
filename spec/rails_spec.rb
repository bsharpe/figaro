describe Figaro::Rails do
  before do
    run_command_and_stop(<<-CMD)
      rails new example \
        --skip-gemfile \
        --skip-bundle \
        --skip-keeps \
        --skip-sprockets \
        --skip-javascript \
        --skip-test-unit \
        --no-rc \
        --quiet
      CMD
    cd("example")
  end

  describe "initialization" do
    before do
      write_file("config/application.yml", "FOO: bar")
    end

    it "loads application.yml" do
      x = run_command_and_stop("rails runner 'puts Figaro.env.FOO'")

      # assert_partial_output("bar", all_stdout)
      expect(all_stdout).to include_output_string("bar")
    end

    it "happens before database initialization" do
      write_file("config/database.yml", <<-EOF)
development:
  adapter: sqlite3
  database: db/<%= ENV["FOO"] %>.sqlite3
EOF

      run_command_and_stop("rake db:migrate")

      expect("db/bar.sqlite3").to be_an_existing_file
    end

    it "happens before application configuration" do
      content = <<-EOL
        config.foo = ENV["FOO"]
      EOL
      insert_into_file_after("config/application.rb", /< Rails::Application$/, content)

      run_command_and_stop("rails runner 'puts Rails.application.config.foo'")

      #assert_partial_output("bar", all_stdout)
      expect(all_stdout).to include_output_string("bar")
    end
  end
end
