module LibratoMetricsClient
  class Probe
    def initialize(plugin_definition, prefix, settings)
      @plugin_definition = plugin_definition
      @prefix            = prefix
      @settings          = settings

      if !@prefix || @prefix == ''
        @prefix = @plugin_definition.name
      end
    end

    def run
      metrics = Metrics.new(@prefix)
      @plugin_definition.run(metrics, @settings)
      metrics
    end
  end
end