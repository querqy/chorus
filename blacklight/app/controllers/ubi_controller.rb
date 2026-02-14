class UbiController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  # POST /ubi_queries
  def queries
    process_ubi_request('/ubi_queries')
  end
  
  # POST /ubi_events  
  def events
    process_ubi_request('/ubi_events')
  end
  
  private
  
  def process_ubi_request(endpoint_type)
    raw_body = request.body.read
    
    Rails.logger.info "UBI #{endpoint_type}: Received request (#{raw_body.length} bytes)"
    
    response = forward_to_opensearch(endpoint_type, raw_body)
    
    if ['200', '201', '202'].include?(response.code)
      Rails.logger.info "UBI #{endpoint_type}: Successfully forwarded to OpenSearch (#{response.code})"
      render json: { status: 'success' }, status: :ok
    else
      Rails.logger.error "UBI #{endpoint_type}: OpenSearch failed - #{response.code}: #{response.body[0..200]}"
      puts "UBI #{endpoint_type}: OpenSearch failed - #{response.code}: #{response.body[0..200]}"
      
      render json: { status: 'error', message: 'Failed to forward request' }, status: :internal_server_error
    end
    
  rescue => e
    Rails.logger.error "UBI #{endpoint_type}: Error - #{e.class}: #{e.message}"
    render json: { status: 'error', message: 'Internal server error' }, status: :internal_server_error
  end
  
  def forward_to_opensearch(endpoint_type, data)
    # Map to working OpenSearch UBI endpoints
    opensearch_endpoint = case endpoint_type
    when '/ubi_queries'
      '/ubi_queries/_doc'
    when '/ubi_events'
      '/ubi_events/_doc'
    end
    
    url = opensearch_base_url + opensearch_endpoint
    uri = URI(url)
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.read_timeout = 10
    http.open_timeout = 5
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request.body = prepare_ubi_data(data)
    
    http.request(request)
  end
  
  def prepare_ubi_data(raw_data)
    # Parse JSON array and extract single object for UBI endpoints
    parsed_data = JSON.parse(raw_data)
    
    if parsed_data.is_a?(Array) && parsed_data.length == 1
      parsed_data.first.to_json
    elsif parsed_data.is_a?(Array)
      # Multiple objects - use NDJSON format
      parsed_data.map(&:to_json).join("\n")
    else
      parsed_data.to_json
    end.force_encoding('UTF-8')
    
  rescue JSON::ParserError => e
    Rails.logger.warn "UBI: JSON parse error (#{e.message}), using raw data"
    raw_data.force_encoding('UTF-8')
  end
  
  def opensearch_base_url
    @opensearch_base_url ||= begin
      url = Rails.application.config.opensearch_url ||
            ENV['OPENSEARCH_URL'] ||
            ENV['ELASTICSEARCH_URL']
      
      if url.blank?
        raise "OpenSearch URL not configured. Set OPENSEARCH_URL environment variable or Rails config."
      end
      
      url.chomp('/')
    end
  end
end
