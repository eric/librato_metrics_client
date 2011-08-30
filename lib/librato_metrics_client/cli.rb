require 'optparse'

module LibratoMetricsClient
  class Cli
    def initialize(args)
      @system_args = []
      @args        = args.dup
    end

    def run!
      # Take system args off
      @system_args << @args.shift while @args.first && @args.first[0..0] == '-'

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
      opts.parse!(@system_args)

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
      unless filename = @args.shift
        help_probe
      end

      settings = {}
      opts = OptionParser.new do |opts|
        opts.on("-s", "--set NAME=VALUE", "Set a variable for the probe") do |s|
          k, v = s.split('=', 2)
          settings[k] = v
        end
      end
      opts.parse!(@args)

      definition = PluginDefinition.new(filename)
      metrics    = Metrics.new
      definition.run(metrics, settings)

      client = Client.new(@user || ENV['LIBRATO_USER'], @token || ENV['LIBRATO_TOKEN'])
      client.post(metrics.metrics)
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