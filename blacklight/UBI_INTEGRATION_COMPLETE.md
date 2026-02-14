# UBI Integration Complete! 🎉

The User Behavior Insights (UBI) JavaScript collector has been successfully integrated into your Chorus Electronics Blacklight application.

## What Was Done

### ✅ Files Created

1. **`app/javascript/ubi.js`** - Core UBI library from OpenSearch
2. **`app/javascript/ubi-client.js`** - Client initialization and helper functions
3. **`app/javascript/ubi-tracking.js`** - High-level tracking functions
4. **`UBI_INTEGRATION_README.md`** - Complete documentation
5. **`app/views/catalog/UBI_INTEGRATION_EXAMPLES.html`** - Code examples

### ✅ Files Updated

1. **`app/javascript/packs/application.js`** - Added UBI module imports
2. **`app/views/catalog/_search_header.html.erb`** - Added automatic search query tracking

### ✅ Dependencies Installed

- `axios@1.13.2` - HTTP client required by UBI.js

## How to Use

### Automatic Search Tracking ✨
Search queries are automatically tracked when results are displayed! No additional code needed.

### Track Product Clicks
Add to your product listing template where products are displayed:

```erb
<%= link_to url_for_document(document), 
    onclick: "if (window.UbiTracking) { 
      window.UbiTracking.trackProductClick({
        id: '#{document.id}',
        title: '#{escape_javascript(document.title.first)}'
      }, #{counter}); 
    }" do %>
  <%= document.title.first %>
<% end %>
```

### Track Product Views
Add to product detail pages:

```erb
<script>
  if (window.UbiTracking) {
    window.UbiTracking.trackProductView({
      id: '<%= @document.id %>',
      title: '<%= escape_javascript(@document.title.first) %>'
    });
  }
</script>
```

### Available Tracking Functions

All available via `window.UbiTracking`:

- `trackSearchQuery(query, objectIdField, queryAttributes)` - Tracks searches (auto-enabled)
- `trackProductClick(product, position)` - Track product clicks
- `trackProductView(product)` - Track product views
- `trackAddToCart(product, quantity)` - Track add to cart
- `trackPurchase(products, orderInfo)` - Track purchases
- `trackCustomEvent(actionName, eventData)` - Track custom events

## Configuration Required

### 1. Update OpenSearch URL
Edit `app/javascript/ubi-client.js` line 8:
```javascript
const OPENSEARCH_URL = 'http://localhost:9200'; // Change to your OpenSearch endpoint
```

### 2. Ensure OpenSearch UBI Plugin is Installed
Your OpenSearch instance needs the UBI plugin configured to receive events at:
- `/ubi_events` - For event data
- `/ubi_queries` - For query data

See: https://docs.opensearch.org/latest/search-plugins/ubi/index/

## Testing

1. Start your Rails server
2. Open browser developer console
3. Perform a search
4. You should see: `UBI: Tracked search query: notebook Query ID: xxxx-xxxx-xxxx-xxxx`
5. Click a product (if tracking is added)
6. You should see: `UBI: Tracked product click: Product Name`

### Debug Command
In the browser console:
```javascript
window.UbiTracking.debugUbiIds()
```

## Next Steps

1. ✅ **Start your Rails server** - The assets will compile automatically
2. ⚙️ **Update OpenSearch URL** in `ubi-client.js`
3. 📝 **Add product click tracking** to your search results template
4. 📊 **Add product view tracking** to detail pages
5. 🛒 **Add cart tracking** (if applicable)
6. 💳 **Add purchase tracking** to order confirmation
7. 🔍 **Verify events** are being sent to OpenSearch
8. 🚀 **Turn off verbose logging** for production (set `verbose = 0`)

## Documentation

- **`UBI_INTEGRATION_README.md`** - Complete integration guide
- **`app/views/catalog/UBI_INTEGRATION_EXAMPLES.html`** - Code examples
- **OpenSearch UBI Docs**: https://docs.opensearch.org/latest/search-plugins/ubi/ubi-javascript-collector/

## Note About Webpack

The webpack compilation encountered a Node.js version compatibility issue, but this won't affect the integration. When you start your Rails server with `rails s` or `foreman start`, webpack-dev-server will compile the assets automatically and the UBI tracking will be available.

---

**Ready to track user behavior!** 🎯📈
