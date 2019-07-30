require "fileutils"
require "ostruct"
require "yaml"
require "awesome_print"

module CommandInterceptor
  class Command < OpenStruct
  end

  BIN_PATH = File.expand_path("../bin", __FILE__)
  LOG_PATH = File.expand_path("../../../tmp/commands.yml", __FILE__)

  def self.setup
    # ap "#{self.name}.setup > #{BIN_PATH}"
    ENV["PATH"] = "#{BIN_PATH}:#{ENV["PATH"]}"
  end

  def self.intercept(name)
    # ap "#{self.name}.intercept(#{name}) > #{LOG_PATH}"
    FileUtils.mkdir_p(File.dirname(LOG_PATH))
    FileUtils.touch(LOG_PATH)

    command = { "env" => ENV.to_hash, "name" => name, "args" => ARGV }
    commands = self.commands << command

    File.write(LOG_PATH, YAML.dump(commands))
  end

  def self.commands
    # ap "#{self.name}.commands > #{LOG_PATH}"
    (File.exist?(LOG_PATH) && YAML.load_file(LOG_PATH) || []).map { |c| Command.new(c) }
  end

  def self.reset
    # ap "#{self.name}.reset > #{LOG_PATH}"
    FileUtils.rm_f(LOG_PATH)
  end
end
