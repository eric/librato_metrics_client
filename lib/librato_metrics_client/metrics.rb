module LibratoMetricsClient
  class Metrics
    attr_reader :gauges, :counters

    def initialize(prefix)
      @prefix   = prefix
      @gauges   = []
      @counters = []
    end

    def gauge(name, value, options = {})
      metric = options.merge(:name => metric_name(name), :value => value)
      metric[:measure_time] ||= Time.now.to_i
      @gauges << metric
    end

    def counter(name, value, options = {})
      metric = options.merge(:name => metric_name(name), :value => value)
      metric[:measure_time] ||= Time.now.to_i
      @counters << metric
    end

    def metric_name(name)
      @prefix && @prefix != '' ? "#{@prefix}.#{name}" : name
    end
  end
end