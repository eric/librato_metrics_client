class DiskUsage < LibratoMetricsClient::Plugin
  LINE_MATCH = /^\s*(\S.*?)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*$/

  def run
    disk_output = `df -k`

    raise "Could not run df" unless $?.success?

    md = LINE_MATCH.match(disk_output)
    begin
      next if md[1] == 'Filesystem'
      next unless md[1] =~ %r{^/dev/}

      name = md[6]
      source = "#{Socket.gethostname}:#{name}"

      gauge :size, md[2],  :source => source
      gauge :used, md[3],  :source => source
      gauge :avail, md[4], :source => source
    end while md = LINE_MATCH.match(md.post_match)
  end
end