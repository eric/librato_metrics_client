module LibratoMetricsClient
  class PluginDefinition
    attr_accessor :name, :file

    def initialize(file)
      @file = file
    end

    def plugin
      @plugin ||= Plugin.load(file)
    end

    def run(metrics, settings)
      plugin.new(metrics, settings).run
    end
  end
end
