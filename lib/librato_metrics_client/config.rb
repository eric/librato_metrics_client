module LibratoMetricsClient
  class Config
    def initialize
      @runtime = {}
      @global  = {}
      load
    end

    def global_filename
      File.expand_path("~/.librato_metrics_client_config")
    end

    def flatten
      hash = {}

      flatten = lambda do |h, *args|
        prev_key = *args
        h.each_pair do |key, value|
          curr_key = [ prev_key, key ].compact.flatten.join('.')
          if value.is_a?(Hash)
            flatten[value, curr_key]
          else
            hash[curr_key] = value
          end
        end
      end

      flatten.call(@global)
      flatten.call(@runtime)

      hash
    end

    def get(path)
      [ @runtime, @global ].each do |hash|
        if val = path.split('.').inject(hash) { |hash, key| hash[key] || break }
          return val
        end
      end

      nil
    end

    def set(file_type, path, value)
      segments = path.split('.')
      key      = segments.pop
      hash     = hash_for(file_type)

      segments.each do |segment|
        hash = (hash[segment] ||= {})
      end

      hash[key] = value
    end

    def unset(file_type, path)
      segments = path.split('.')
      key      = segments.pop
      hash     = hash_for(file_type)

      segments.each do |segment|
        hash = hash[segment] if hash
      end

      hash.delete(key) if hash
    end

    def load
      if File.exists?(global_filename)
        data = YAML.load_file(global_filename)

        if data.is_a?(Hash)
          @global = data
        end
      end
    end

    def save
      File.open(global_filename, 'w') do |io|
        YAML.dump(@global, io)
      end
    end

    def hash_for(file_type)
      case file_type
      when :runtime
        @runtime
      when :global
        @global
      else
        raise "Unknown file type: #{file_type.inspect}"
      end
    end
  end
end