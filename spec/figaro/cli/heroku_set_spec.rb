describe "figaro heroku:set", type: :aruba do
  before do
    create_directory("example")
    cd("example")
    write_file("config/application.yml", "FOO: bar")
    write_file("bin/heroku", IO.read(`which heroku`.chomp))
    FileUtils.chmod(0755, File.join(expand_path('.'), "bin", "heroku"))
  end

  it "overrides Heroku command" do
    expect("heroku").to be_a_command_found_in_path
    # ap `which heroku`.chomp
    # ap which("heroku", ENV['PATH'])
    # ap which("heroku")
  end

  it "sends Figaro configuration to Heroku" do
    expect("heroku").to be_a_command_found_in_path
    run_command("figaro heroku:set")

    expect(commands.size).to be > 1
    command = commands.last
    expect(command.name).to eq("heroku")
    expect(command.args).to eq(["config:set", "FOO=bar"])
  end

  it "respects path" do
    write_file("env.yml", "foo: bar")

    run_command("figaro heroku:set -p env.yml")

    command = commands.last
    expect(command.name).to eq("heroku")
    expect(command.args).to eq(["config:set", "FOO=bar"])
  end

  it "respects environment" do
    overwrite_file("config/application.yml", <<-EOF)
FOO: bar
test:
  FOO: baz
EOF

    run_command("figaro heroku:set -e test")

    command = commands.last
    expect(command.name).to eq("heroku")
    expect(command.args).to eq(["config:set", "foo=baz"])
  end

  it "targets a specific Heroku app" do
    run_command("figaro heroku:set -a foo-bar-app")

    command = commands.last
    expect(command.name).to eq("heroku")
    expect(command.args.shift).to eq("config:set")
    expect(command.args).to match_array(["FOO=bar", "--app=foo-bar-app"])
  end

  it "targets a specific Heroku git remote" do
    run_command("figaro heroku:set -r production")

    command = commands.last
    expect(command.name).to eq("heroku")
    expect(command.args.shift).to eq("config:set")
    expect(command.args).to match_array(["FOO=bar", "--remote=production"])
  end

  it "handles values with special characters" do
    overwrite_file("config/application.yml", "FOO: bar baz")

    run_command("figaro heroku:set")

    command = commands.last
    expect(command.name).to eq("heroku")
    expect(command.args).to eq(["config:set", "FOO=bar baz"])
  end
end
