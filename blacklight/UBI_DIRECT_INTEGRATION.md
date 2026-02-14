# UBI Direct Integration (No Webpack/Yarn Required!)

The UBI tracking is now set up to work directly with Rails asset pipeline - no webpack or yarn compilation needed!

## What Changed

### ✅ Created Browser-Compatible Files:
1. **`app/assets/javascripts/ubi.js`** - Core UBI library (browser-compatible, uses fetch instead of axios)
2. **`app/assets/javascripts/ubi-client.js`** - Client helpers (browser-compatible)
3. **`app/assets/javascripts/ubi-tracking.js`** - Tracking functions (browser-compatible)

### ✅ Updated Files:
1. **`app/views/catalog/_search_header.html.erb`** - Now includes script tags directly
2. **`config/initializers/assets.rb`** - Registered UBI files for precompilation

## How It Works

The scripts are loaded via Rails asset pipeline using `javascript_include_tag`:
```erb
<%= javascript_include_tag 'ubi' %>
<%= javascript_include_tag 'ubi-client' %>
<%= javascript_include_tag 'ubi-tracking' %>
```

All functions are available globally:
- `window.UbiClient` - UBI client class
- `window.UbiEvent` - Event class
- `window.UbiEventAttributes` - Event attributes class
- `window.UbiQueryRequest` - Query request class
- `window.UbiClientHelpers` - Helper functions
- `window.UbiTracking` - High-level tracking functions

## Configuration

Edit `app/assets/javascripts/ubi-client.js` to set your OpenSearch URL (line 9):
```javascript
const OPENSEARCH_URL = 'http://localhost:9200'; // Change to your OpenSearch endpoint
```

## Testing

1. **Restart your Rails server** (important for asset pipeline changes):
   ```bash
   cd /Users/epugh/Documents/projects/chorus/blacklight
   rails s
   ```

2. Open browser console and perform a search

3. You should see:
   ```
   Setting up UBI search query tracking
   Search field value: notebook
   About to track search query: notebook
   UBI: Tracked search query: notebook Query ID: xxxx-xxxx-xxxx
   ```

## Usage Examples

### Track Product Clicks
```erb
<%= link_to product_path(product), 
    onclick: "window.UbiTracking.trackProductClick({id: '#{product.id}', title: '#{escape_javascript(product.title)}'}, #{index}); return true;" do %>
  <%= product.title %>
<% end %>
```

### Track Product Views
```erb
<script>
  window.UbiTracking.trackProductView({
    id: '<%= @product.id %>',
    title: '<%= escape_javascript(@product.title) %>'
  });
</script>
```

### Debug
```javascript
window.UbiClientHelpers.debugUbiIds()
```

## Key Differences from Module Version

- ✅ No webpack/yarn needed
- ✅ No module imports/exports
- ✅ Uses native `fetch` instead of axios
- ✅ All code in browser-compatible IIFE format
- ✅ Works with Rails asset pipeline
- ✅ Available immediately after page load

## Next Steps

1. ⚠️ **Restart Rails server** for asset pipeline changes
2. ⚙️ Update OpenSearch URL in `ubi-client.js`
3. 🧪 Test search tracking in browser console
4. 📝 Add product click tracking to search results
5. 🔍 Verify events in OpenSearch

---

**Ready to track! No build tools required!** 🎉
