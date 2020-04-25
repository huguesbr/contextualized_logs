require 'contextualized_logs'
require 'json'

module ContextualizedLogs
  configure do |config|
    config.log_formatter = proc do |severity, timestamp, progname, msg|
      log = ContextualizedLogger.default_formatter.call(severity, timestamp, progname, msg)
      log = JSON.parse(log)
      # set log <> APM trace correlation
      datadog_correlation = Datadog.tracer.active_correlation
      log.merge(
        dd: {
          trace_id: datadog_correlation.trace_id,
          span_id: datadog_correlation.span_id
        },
        ddsource: ['ruby']
      ).to_json + "\n"
    end
    config.controller_default_contextualizer = proc do |controller|
      ContextualizedController.default_contextualize_request(controller)
    end
  end
end
