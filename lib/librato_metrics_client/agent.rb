module LibratoMetricsClient
  class Agent
    attr_accessor :interval

    def initialize(config)
      @config = config
      @client = Client.new(@config.get('user.email'), @config.get('user.token'))
      @probes = []
    end

    def probe(probe)
      @probes << probe
    end

    def run
      if interval
        loop do
          run_once
          sleep interval
        end
      else
        run_once
      end
    end

    def run_once
      metrics = {
        :gauges => [],
        :counters => []
      }

      @probes.each do |probe|
        m = probe.run
        metrics[:gauges] += m.gauges
        metrics[:counters] += m.counters
      end

      response = @client.post(metrics)

      raise response.body unless response.success?
    end
  end
end