require 'optparse'

module LibratoMetricsClient
  class Cli
    def initialize(args)
      @system_args = []
      @args        = args.dup
      @config      = LibratoMetricsClient::Config.new
    end

    def program_name
      File.basename($0)
    end

    def run!
      opts = OptionParser.new do |opts|
        opts.on("-c <name>=<value>", "Pass a configuration parameter to the command") do |c|
          k, v = c.split('=', 2)
          @config.set(:runtime, k, v)
        end
        opts.on("-h", "--help", "This help message") do
          help
        end
      end
      @args = opts.order(@args)

      case command = @args.shift
      when 'help', nil, ''
        help
      when 'config'
        config
      when 'plugin'
        plugin
      when 'probe'
        probe
      end
    end

    def help
      puts unindent(<<-EOF)
        Usage: #{program_name} [-c <name>=<value>] <command> [<args>]

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

    def help_config
      puts unindent(<<-EOF)
        Usage: #{File.basename($0)} config [options] [<key>] [[<value>]]

        Action
           --get        get value
           --list       list all values
      EOF
      exit(1)
    end

    def config
      operation = nil
      opts = OptionParser.new do |opts|
        opts.on("--get", "get value") do
          operation = :get
        end
        opts.on("--list", "list all values") do |v|
          operation = :list
        end
      end
      @args = opts.order!(@args)

      if (!operation || operation == :get) && @args.length == 1
        puts @config.get(@args[0])
      elsif !operation && @args.length == 2
        @config.set(:global, @args[0], @args[1])
        @config.save
      elsif operation == :list
        @config.flatten.each_pair do |key, value|
          puts "#{key}=#{value}"
        end
      else
        help_config
      end
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

        opts.on("--interval INTERVAL", Integer, "interval for running probe") do |v|
          @interval = v
        end

      end
      @args = opts.order!(@args)

      unless filename = @args.shift
        help_probe
      end

      agent = Agent.new(@config)
      definition = PluginDefinition.new(filename)
      probe = Probe.new(definition, @prefix, settings)
      agent.probe(probe)

      agent.interval = @interval if @interval

      agent.run
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