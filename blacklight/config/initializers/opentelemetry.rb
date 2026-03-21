require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/all'

# Configure the sdk with the OTLP exporter for LGTM stack
ENV['OTEL_TRACES_EXPORTER'] = 'otlp'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'blacklight'
  
  # Configure OTLP exporter
  # The endpoint is set via OTEL_EXPORTER_OTLP_ENDPOINT environment variable
  # which should be http://lgtm:4318 for HTTP or http://lgtm:4317 for gRPC
  
  ##### Instruments
  c.use 'OpenTelemetry::Instrumentation::Rack'
  #c.use 'OpenTelemetry::Instrumentation::ActionPack'
  #c.use 'OpenTelemetry::Instrumentation::ActionView'
  #c.use 'OpenTelemetry::Instrumentation::ActiveJob'
  c.use 'OpenTelemetry::Instrumentation::ActiveRecord'
  c.use 'OpenTelemetry::Instrumentation::ConcurrentRuby'
  #c.use 'OpenTelemetry::Instrumentation::Faraday'
  #c.use 'OpenTelemetry::Instrumentation::HttpClient'
  c.use 'OpenTelemetry::Instrumentation::Net::HTTP'
  c.use 'OpenTelemetry::Instrumentation::Rails'
  #c.use 'OpenTelemetry::Instrumentation::Redis'
  #c.use 'OpenTelemetry::Instrumentation::RestClient'
  #c.use 'OpenTelemetry::Instrumentation::RubyKafka'
  #c.use 'OpenTelemetry::Instrumentation::Sidekiq'
end