# UBI Rails Proxy Integration Guide

This document explains the Rails proxy architecture for UBI (User Behavior Insights) tracking in the Chorus Electronics application.

## Architecture Overview

```
Browser JavaScript → Rails UBI Endpoints → OpenSearch UBI Plugin
                  (/ubi_queries, /ubi_events)
```

Instead of sending events directly from the browser to OpenSearch, events are proxied through Rails endpoints. This provides:

- **Security**: No direct OpenSearch exposure to browsers
- **Simple same-origin requests**: No CORS complexity needed
- **Server-side validation**: Can validate/sanitize events
- **Centralized logging**: Server-side event logging
- **Configuration management**: OpenSearch URL stays server-side

## Implementation Files

### 1. Rails Controller: `app/controllers/ubi_controller.rb`

Handles incoming UBI events and forwards them to OpenSearch:

```ruby
class UbiController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  # POST /ubi_queries - Handles search query tracking
  def queries
    # Parses JSON, logs event, forwards to OpenSearch
  end
  
  # POST /ubi_events - Handles user interaction events  
  def events
    # Parses JSON, logs event, forwards to OpenSearch
  end
end
```

### 2. Routes: `config/routes.rb`

Adds UBI endpoints:

```ruby
# UBI tracking endpoints
post '/ubi_queries', to: 'ubi#queries'
post '/ubi_events', to: 'ubi#events'
```

### 3. JavaScript Client: `app/javascript/ubi-client.js`

Updated to use Rails endpoints instead of direct OpenSearch:

```javascript
function getRailsBaseUrl() {
  return window.location.origin; // Uses same origin as Rails app
}

export function getUbiClient() {
  if (!ubiClient) {
    // Points to Rails instead of OpenSearch
    ubiClient = new UbiClient(getRailsBaseUrl());
    ubiClient.verbose = 1;
  }
  return ubiClient;
}
```

### 4. UBI Core Library: `app/javascript/ubi.js`

The OpenSearch UBI JavaScript library (unchanged):
- `UbiClient` - HTTP client for sending events
- `UbiEvent` - Event data structure
- `UbiQueryRequest` - Query tracking structure

### 5. Tracking Functions: `app/javascript/ubi-tracking.js`

High-level tracking functions (unchanged):
- `trackSearchQuery()`
- `trackProductClick()`
- `trackProductView()`
- `trackAddToCart()`
- `trackPurchase()`

## Configuration

### OpenSearch URL (Server-Side)

Configure in your Rails environment files:

**Development** (`config/environments/development.rb`):
```ruby
config.opensearch_url = ENV['OPENSEARCH_URL'] || 'http://localhost:9200'
```

**Production** (`config/environments/production.rb`):
```ruby  
config.opensearch_url = ENV['OPENSEARCH_URL'] || 'https://your-opensearch.domain.com'
```

### Environment Variables

Set your OpenSearch endpoint using any of these:
```bash
export OPENSEARCH_URL="https://your-opensearch.domain.com"
# or
export ELASTICSEARCH_URL="https://your-elasticsearch.domain.com"  
```

### Application Configuration

The application name and other settings are in `ubi-client.js`:
```javascript
const APPLICATION_NAME = 'chorus-electronics';
```

## Event Flow

### 1. Search Query Tracking
```
User performs search → Search results page loads → JavaScript tracks query → 
POST /ubi_queries → Rails logs event → Forwards to OpenSearch /ubi_queries
```

### 2. Product Interaction Tracking  
```
User clicks product → JavaScript tracks event → POST /ubi_events → 
Rails logs event → Forwards to OpenSearch /ubi_events
```

## Usage Examples

### Automatic Search Tracking

Already implemented in `app/views/catalog/_search_header.html.erb`:

```javascript
document.addEventListener('DOMContentLoaded', function() {
  const searchField = document.querySelector('input[name="q"]');
  if (searchField && searchField.value && window.UbiTracking) {
    window.UbiTracking.trackSearchQuery(searchField.value, '_id', {
      algorithm: '<%= params[:search_field] %>',
      filters: <%= params[:f]&.to_json || '{}' %>,
      total_results: <%= @response.total rescue 0 %>
    });
  }
});
```

### Manual Product Click Tracking

Add to your product listing templates:

```erb
<% @response.documents.each_with_index do |document, index| %>
  <div class="document">
    <%= link_to url_for_document(document),
        data: { 
          product_id: document.id,
          product_title: document.title&.first,
          position: index
        },
        onclick: "if (window.UbiTracking) {
          window.UbiTracking.trackProductClick({
            id: this.dataset.productId,
            title: this.dataset.productTitle
          }, parseInt(this.dataset.position));
        }" do %>
      <%= document.title&.first %>
    <% end %>
  </div>
<% end %>
```

### Product Detail View Tracking

Add to your show/detail page:

```erb
<script>
  document.addEventListener('DOMContentLoaded', function() {
    if (window.UbiTracking) {
      window.UbiTracking.trackProductView({
        id: '<%= @document.id %>',
        title: '<%= escape_javascript(@document.title&.first || '') %>',
        category: '<%= escape_javascript(@document.fetch(:subject, []).first || '') %>',
        price: '<%= @document.fetch(:price_display, []).first || 0 %>'
      });
    }
  });
</script>
```

## Testing

### 1. Test Script

Use the included test script:

```bash
# Start Rails server
bundle exec rails server

# In another terminal, run the test
ruby test_ubi_endpoints.rb http://localhost:3000
```

### 2. Manual Testing

1. Open browser developer console
2. Navigate to your site and perform a search
3. Check for console logs:
   ```
   UBI: Tracked search query: notebook Query ID: abc-123
   ```
4. Check Rails logs:
   ```
   UBI Query received: [{"application":"chorus-electronics",...}]
   ```

### 3. Verify OpenSearch Integration

Check your OpenSearch instance for UBI indices:
```bash
curl -X GET "localhost:9200/_cat/indices/ubi*?v"
```

Should show indices like:
```
ubi_queries
ubi_events
```

## Debugging

### Enable Verbose Logging

In `ubi-client.js`:
```javascript
ubiClient.verbose = 1; // Enable console logging
```

### Check Rails Logs

```bash
tail -f log/development.log
```

Look for:
```
UBI Query received: [...]
UBI Event received: [...]
```

### Debug UBI IDs

In browser console:
```javascript
if (window.UbiTracking) {
  // Show current IDs
  console.log('Client ID:', localStorage.getItem('ubi_client_id'));
  console.log('Session ID:', sessionStorage.getItem('ubi_session_id')); 
  console.log('Query ID:', sessionStorage.getItem('ubi_query_id'));
}
```

### Test Endpoints Directly

Using curl:

```bash
# Test query endpoint
curl -X POST http://localhost:3000/ubi_queries \
  -H "Content-Type: application/json" \
  -d '[{"application":"chorus-electronics","query_id":"test-123","client_id":"test-client","user_query":"notebook","object_id_field":"_id","timestamp":"2024-01-01T12:00:00Z"}]'

# Test event endpoint  
curl -X POST http://localhost:3000/ubi_events \
  -H "Content-Type: application/json" \
  -d '[{"application":"chorus-electronics","action_name":"product_click","query_id":"test-123","client_id":"test-client","session_id":"test-session","timestamp":"2024-01-01T12:00:00Z","event_attributes":{"object":{"object_id":"prod-123","object_id_field":"product_id","description":"Test Product"},"position":{"ordinal":0}}}]'
```

## Deployment Checklist

- [ ] Set `OPENSEARCH_URL` environment variable
- [ ] Verify OpenSearch has UBI plugin installed
- [ ] Test `/ubi_queries` and `/ubi_events` endpoints
- [ ] Set `ubiClient.verbose = 0` for production
- [ ] Configure OpenSearch authentication if needed
- [ ] Monitor Rails logs for UBI events
- [ ] Verify events appear in OpenSearch UBI indices

## OpenSearch UBI Plugin Setup

Ensure your OpenSearch instance has the UBI plugin installed:

1. **Install Plugin**:
   ```bash
   opensearch-plugin install https://github.com/opensearch-project/user-behavior-insights/releases/latest/download/user-behavior-insights.zip
   ```

2. **Restart OpenSearch**

3. **Verify Installation**:
   ```bash
   curl -X GET "localhost:9200/_nodes/plugins?pretty" | grep ubi
   ```

4. **Create UBI Index Templates** (automatic on first event)

See: https://docs.opensearch.org/latest/search-plugins/ubi/index/

## Benefits of Rails Proxy Architecture

1. **Security**: OpenSearch credentials stay server-side
2. **Performance**: Can batch/cache events if needed
3. **Reliability**: Server-side retry logic possible  
4. **Monitoring**: Centralized logging and metrics
5. **Flexibility**: Can transform/enrich events before forwarding
6. **Maintenance**: Easier to update OpenSearch endpoints
7. **Simplicity**: Same-origin requests, no CORS complexity

## Troubleshooting Common Issues

### "UbiTracking is not defined"
- Run `bin/webpack` to compile JavaScript modules
- Restart Rails server
- Check browser console for JavaScript errors

### Rails UBI endpoints return 404
- Verify routes are added to `config/routes.rb`
- Restart Rails server after route changes

### Events not reaching OpenSearch
- Check Rails logs for forwarding errors
- Verify `OPENSEARCH_URL` configuration
- Test OpenSearch connectivity from Rails server
- Check OpenSearch logs for incoming requests

### Network connection errors
- Verify Rails server is running and accessible
- Check browser network tab for failed requests

### OpenSearch authentication errors
- Configure authentication in `UbiController#forward_to_opensearch`
- Add authentication headers as needed

## Next Steps

1. **Add Authentication**: Secure UBI endpoints if needed
2. **Add Validation**: Validate event data before forwarding
3. **Add Rate Limiting**: Prevent abuse of tracking endpoints
4. **Add Monitoring**: Monitor event volume and errors
5. **Add Testing**: Write automated tests for UBI controller
6. **Add Documentation**: Document custom event tracking patterns