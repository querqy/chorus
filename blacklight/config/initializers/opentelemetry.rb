require 'opentelemetry/sdk'
require 'opentelemetry/exporter/jaeger'
require 'opentelemetry/instrumentation/all'

# Configure the sdk with the Jaeger collector exporter
ENV['OTEL_TRACES_EXPORTER'] = 'jaeger'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'blacklight'
  #c.use_all() # enables all instrumentation!  We should prune this down.
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
