# UBI Integration for Chorus Electronics

This document explains how the User Behavior Insights (UBI) JavaScript collector has been integrated into the Chorus Electronics Blacklight application.

## Files Created

### 1. `app/javascript/ubi.js`
The core UBI library from OpenSearch, containing:
- `UbiClient` - Client for sending events to OpenSearch
- `UbiEvent` - Event data structure
- `UbiEventAttributes` - Event attribute data structure  
- `UbiQueryRequest` - Query tracking data structure

### 2. `app/javascript/ubi-client.js`
Client initialization and helper functions:
- `getUbiClient()` - Returns singleton UBI client instance
- `getClientId()` - Gets/generates persistent client ID (localStorage)
- `getSessionId()` - Gets/generates session ID (sessionStorage)
- `getQueryId()` - Gets current query ID
- `generateQueryId()` - Generates new query ID for each search
- `generateGuid()` - Creates unique identifiers (works in HTTP and HTTPS)

### 3. `app/javascript/ubi-tracking.js`
High-level tracking functions for common events:
- `trackSearchQuery(query, objectIdField, queryAttributes)` - Track search queries
- `trackProductClick(product, position)` - Track product clicks
- `trackProductView(product)` - Track product detail views
- `trackAddToCart(product, quantity)` - Track add to cart
- `trackPurchase(products, orderInfo)` - Track purchases
- `trackCustomEvent(actionName, eventData)` - Track custom events

All functions are available globally via `window.UbiTracking`.

### 4. `app/javascript/packs/application.js`
Updated to import UBI modules so they're compiled by webpack.

### 5. `app/views/catalog/_search_header.html.erb`
Updated to automatically track search queries when results are displayed.

## Configuration

### Rails Proxy Endpoints
The UBI client now sends events through Rails endpoints instead of directly to OpenSearch:
- `/ubi_queries` - For query tracking data
- `/ubi_events` - For event tracking data

The Rails `UbiController` forwards these to your OpenSearch instance.

### OpenSearch Endpoint (Server-Side)
Configure your OpenSearch URL in Rails. You can use any of these methods:
- Set `Rails.application.config.opensearch_url` in your environment config
- Set `OPENSEARCH_URL` environment variable  
- Set `ELASTICSEARCH_URL` environment variable
- Defaults to `http://localhost:9200`

### Application Name
The application name is set in `ubi-client.js`:
```javascript
const APPLICATION_NAME = 'chorus-electronics';
```

## How It Works

### ID Management
- **Client ID**: Unique per user, persisted in localStorage across sessions
- **Session ID**: Unique per browser session, stored in sessionStorage
- **Query ID**: Generated for each new search, linked to all events from that search

### Rails Proxy Architecture
Events flow: Browser → Rails `/ubi_*` endpoints → OpenSearch UBI endpoints

Benefits:
- No CORS issues
- OpenSearch URL stays server-side
- Can add authentication/validation
- Server-side logging and error handling

### Automatic Search Tracking
Search queries are automatically tracked when the search results page loads. The tracking includes:
- The search query string
- The search algorithm used
- Applied filters
- Total number of results

### Manual Event Tracking
For product clicks, views, and other interactions, you need add tracking calls in your templates.

## Usage Examples

### Track Product Clicks
Add to your product listing template:
```erb
<div class="document" data-document-id="<%= document.id %>">
  <%= link_to url_for_document(document), 
      onclick: "if (window.UbiTracking) { window.UbiTracking.trackProductClick({ id: '#{document.id}', title: '#{escape_javascript(document.title.first)}' }, #{counter}); }" do %>
    <%= document.title.first %>
  <% end %>
</div>
```

### Track Product Views
Add to your product detail page:
```erb
<script>
  document.addEventListener('DOMContentLoaded', function() {
    if (window.UbiTracking) {
      window.UbiTracking.trackProductView({
        id: '<%= @document.id %>',
        title: '<%= escape_javascript(@document.title.first) %>',
        price: '<%= @document.fetch(:price, 0) %>',
        category: '<%= @document.fetch(:category, '') %>'
      });
    }
  });
</script>
```

### Track Add to Cart
Add to your add-to-cart button handler:
```javascript
function addProductToCart(product, quantity) {
  // Your existing add to cart logic
  // ...
  
  // Track with UBI
  if (window.UbiTracking) {
    window.UbiTracking.trackAddToCart(product, quantity);
  }
}
```

### Track Purchase
Add to your order confirmation page:
```erb
<script>
  if (window.UbiTracking) {
    window.UbiTracking.trackPurchase(
      <%= raw @order.items.map { |item| {
        id: item.product_id,
        title: item.product_name,
        price: item.price,
        quantity: item.quantity
      }}.to_json %>,
      {
        order_id: '<%= @order.id %>',
        total: <%= @order.total %>,
        currency: 'USD'
      }
    );
  }
</script>
```

## Testing

To verify the integration is working:

1. Open your browser's developer console
2. Navigate to the site and perform a search
3. You should see console logs like:
   ```
   UBI: Tracked search query: notebook Query ID: 1234-5678-9abc-def0
   ```
4. Click on a product and you should see:
   ```
   UBI: Tracked product click: Product Name
   ```

To debug UBI IDs, run in the console:
```javascript
UbiTracking.debugUbiIds()
```

## Next Steps

1. **Configure OpenSearch URL**: Set your OpenSearch endpoint in Rails config or environment variables
2. **Add Product Click Tracking**: Update your product listing templates to track clicks
3. **Add Product View Tracking**: Update product detail pages to track views
4. **Add Cart Tracking**: If you have a shopping cart, add tracking for add/remove events
5. **Add Purchase Tracking**: Add tracking to your order confirmation page
6. **Verify Events**: Check Rails logs and OpenSearch to confirm events are flowing through
7. **Turn Off Verbose Logging**: Set `ubiClient.verbose = 0` in production

## OpenSearch UBI Plugin Setup

Make sure your OpenSearch instance has the UBI plugin installed and configured to receive events at:
- `/ubi_events` - For event data  
- `/ubi_queries` - For query data

The Rails `UbiController` will forward events from `/ubi_events` and `/ubi_queries` endpoints to your OpenSearch instance.

See: https://docs.opensearch.org/latest/search-plugins/ubi/index/

## Dependencies

- `axios` - HTTP client (automatically installed)
- Webpack/Webpacker - For compiling JavaScript modules

## Troubleshooting

- **"UbiTracking is not defined"**: Make sure webpack has compiled the assets. Run `bin/webpack` or restart your Rails server.
- **No events showing in OpenSearch**: Check Rails logs for UBI controller errors and verify the OpenSearch URL configuration.
- **Network errors**: Check that `/ubi_events` and `/ubi_queries` endpoints are accessible and responding.
- **OpenSearch connection issues**: Verify Rails can connect to your OpenSearch instance using the configured URL.
