module LibratoMetricsClient
  class Plugin
    # From Mr. Ola Bini:
    # http://ola-bini.blogspot.com/2007/07/objectspace-to-have-or-not-to-have.html
    def self.extended(klazz)
      (class <<klazz; self; end).send(:attr_accessor, :subclasses)
      (class <<klazz; self; end).send(:define_method, :inherited) do |clzz|
        klazz.subclasses << clzz
        super
      end
      klazz.subclasses = []
    end

    def self.load(file)
      before = subclasses.dup
      Kernel.load file
      added = subclasses - before
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