module LibratoMetricsClient
  class Plugin
    # From Mr. Ola Bini:
    # http://ola-bini.blogspot.com/2007/07/objectspace-to-have-or-not-to-have.html
    class << self
      attr_accessor :subclasses
    end
    self.subclasses = []

    def self.inherited(klazz)
      self.subclasses << klazz
      super
    end

    def self.load(file)
      before = self.subclasses.dup
      Kernel.load file
      added = self.subclasses - before
      added.first
    end

    def initialize(metrics, settings)
      @metrics  = metrics
      @settings = settings
    end

    def gauge(name, value, options = {})
      @metrics.gauge(name, value, options)
    end

    def counter(name, value, options = {})
      @metrics.counter(name, value, options)
    end
  end
end