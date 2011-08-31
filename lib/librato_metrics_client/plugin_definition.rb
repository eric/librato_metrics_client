module LibratoMetricsClient
  class PluginDefinition
    attr_accessor :name, :file

    def initialize(file)
      @file = file
    end

    def name
      @name ||= plugin.name.sub(/^.*:/, '').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").downcase
    end

    def plugin
      @plugin ||= Plugin.load(file)
    end

    def run(metrics, settings)
      plugin.new(metrics, settings).run
    end
  end
end
