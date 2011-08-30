require 'optparse'
require 'librato_metrics_client/plugin_definition'
require 'librato_metrics_client/plugin'
require 'librato_metrics_client/client'
require 'librato_metrics_client/metrics'

module LibratoMetricsClient
  class Cli
    def initialize(args)
      @system_args = []
      @args        = args.dup
    end

    def run!
      opts = OptionParser.new do |opts|
        opts.on("-u", "--user USER", "Set username for Librato Metrics") do |v|
          @user = v
        end
        opts.on("-t", "--token TOKEN", "Set token for Librato Metrics") do |v|
          @token = v
        end
        opts.on("-h", "--help", "This help message") do
          help
        end
      end
      @args = opts.order(@args)

      case command = @args.shift
      when 'help', nil, ''
        help
      when 'plugin'
        plugin
      when 'probe'
        probe
      end
    end

    def help
      puts unindent(<<-EOF)
        Usage: #{File.basename($0)} [-u|--user=<username>] [-t|--token=<token>] <command> [<args>]

        The available commands are:
          probe       Add, remove and manage probes
          agent       Run the agent to run plugins
          config      Get and set global and plugin options

        See '#{File.basename($0)} help <command>' for more information on a specific command.
      EOF
      exit(1)
    end

    def help_probe
      puts unindent(<<-EOF)
        Usage: #{File.basename($0)} run <filename> [[-s|--set KEY=VALUE]]
      EOF
      exit(1)
    end

    def probe_run
      settings = {}
      opts = OptionParser.new do |opts|
        opts.on("-s", "--set NAME=VALUE", "Set a variable for the probe") do |s|
          k, v = s.split('=', 2)
          settings[k] = v
        end
        opts.on("--prefix PREFIX", "Prefix for submitted metrics") do |v|
          @prefix = v
        end
      end
      @args = opts.order!(@args)

      unless filename = @args.shift
        help_probe
      end

      definition = PluginDefinition.new(filename)
      metrics    = Metrics.new(@prefix)
      definition.run(metrics, settings)

      client = Client.new(@user || ENV['LIBRATO_USER'], @token || ENV['LIBRATO_TOKEN'])

      response = client.post(metrics.metrics)
    end

    def probe
      case command = @args.shift
      when 'run'
        probe_run
      when 'help', '-h', nil, ''
        help_probe
      end
    end

    def plugin
      case command = @args.shift
      when 'run'
      end

      opts = OptionParser.new do |opts|
      end

      opts.parse!(@args)
    end

    def unindent(string)
      indentation = string[/\A\s*/]
      string.strip.gsub(/^#{indentation}/, "") + "\n"
    end
  end
end