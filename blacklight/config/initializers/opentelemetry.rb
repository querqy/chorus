require 'opentelemetry/sdk'
require 'opentelemetry/exporter/jaeger'
require 'opentelemetry/instrumentation/all'

# Configure the sdk with the Jaeger collector exporter
ENV['OTEL_TRACES_EXPORTER'] = 'jaeger'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'blacklight'
  c.use_all() # enables all instrumentation!  We should prune this down.
end
