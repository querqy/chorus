/**
 * UBI Event Tracking for Chorus Electronics
 * This module provides functions to track user behavior events:
 * - Search queries
 * - Product clicks
 * - Product views
 * - Add to cart
 * - Purchases
 */

import { UbiEvent, UbiEventAttributes, UbiQueryRequest } from './ubi';
import { 
  getUbiClient, 
  getClientId, 
  getSessionId, 
  getQueryId, 
  generateQueryId,
  getApplicationName 
} from './ubi-client';

/**
 * Track a search query
 * Call this when a user performs a search
 * @param {string} query - The search query string
 * @param {string} objectIdField - The field name for object IDs (e.g., '_id', 'product_id')
 * @param {object} queryAttributes - Additional query attributes (optional)
 */
export function trackSearchQuery(query, objectIdField = '_id', queryAttributes = {}) {
  try {
    const queryId = generateQueryId(); // Generate new query ID for this search
    const clientId = getClientId();
    const application = getApplicationName();

    const ubiQuery = new UbiQueryRequest(
      application,
      clientId,
      queryId,
      query,
      objectIdField,
      queryAttributes
    );

    const client = getUbiClient();
    client.trackQuery(ubiQuery);
    
    console.log('UBI: Tracked search query:', query, 'Query ID:', queryId);
  } catch (error) {
    console.error('UBI: Error tracking search query:', error);
  }
}

/**
 * Track a product click event
 * Call this when a user clicks on a product in search results
 * @param {object} product - The product object with id, title, etc.
 * @param {number} position - The position of the product in search results (0-indexed)
 */
export function trackProductClick(product, position) {
  try {
    const eventAttributes = new UbiEventAttributes(
      'product_id',
      product.id || product.product_id,
      product.title || product.name,
      product,
      { ordinal: position }
    );

    const event = new UbiEvent(
      getApplicationName(),
      'product_click',
      getClientId(),
      getSessionId(),
      getQueryId(),
      eventAttributes,
      `Clicked: ${product.title || product.name} (${product.id})`
    );

    const client = getUbiClient();
    client.trackEvent(event);
    
    console.log('UBI: Tracked product click:', product.title || product.name);
  } catch (error) {
    console.error('UBI: Error tracking product click:', error);
  }
}

/**
 * Track a product view event
 * Call this when a user views a product detail page
 * @param {object} product - The product object
 */
export function trackProductView(product) {
  try {
    const eventAttributes = new UbiEventAttributes(
      'product_id',
      product.id || product.product_id,
      product.title || product.name,
      product,
      { ordinal: 0 } // Single product view, position is 0
    );

    const event = new UbiEvent(
      getApplicationName(),
      'product_view',
      getClientId(),
      getSessionId(),
      getQueryId(),
      eventAttributes,
      `Viewed: ${product.title || product.name} (${product.id})`
    );

    const client = getUbiClient();
    client.trackEvent(event);
    
    console.log('UBI: Tracked product view:', product.title || product.name);
  } catch (error) {
    console.error('UBI: Error tracking product view:', error);
  }
}

/**
 * Track an add to cart event
 * Call this when a user adds a product to their cart
 * @param {object} product - The product object
 * @param {number} quantity - Quantity added (optional, default 1)
 */
export function trackAddToCart(product, quantity = 1) {
  try {
    const productWithQuantity = { ...product, quantity };
    
    const eventAttributes = new UbiEventAttributes(
      'product_id',
      product.id || product.product_id,
      product.title || product.name,
      productWithQuantity,
      { ordinal: 0 }
    );

    const event = new UbiEvent(
      getApplicationName(),
      'add_to_cart',
      getClientId(),
      getSessionId(),
      getQueryId(),
      eventAttributes,
      `Added to cart: ${product.title || product.name} (${product.id}), qty: ${quantity}`
    );

    const client = getUbiClient();
    client.trackEvent(event);
    
    console.log('UBI: Tracked add to cart:', product.title || product.name);
  } catch (error) {
    console.error('UBI: Error tracking add to cart:', error);
  }
}

/**
 * Track a purchase/conversion event
 * Call this when a user completes a purchase
 * @param {array} products - Array of product objects with quantities
 * @param {object} orderInfo - Order information (order_id, total, etc.)
 */
export function trackPurchase(products, orderInfo = {}) {
  try {
    products.forEach((product, index) => {
      const eventAttributes = new UbiEventAttributes(
        'product_id',
        product.id || product.product_id,
        product.title || product.name,
        { ...product, ...orderInfo },
        { ordinal: index }
      );

      const event = new UbiEvent(
        getApplicationName(),
        'purchase',
        getClientId(),
        getSessionId(),
        getQueryId(),
        eventAttributes,
        `Purchased: ${product.title || product.name} (${product.id})`
      );

      const client = getUbiClient();
      client.trackEvent(event);
    });
    
    console.log('UBI: Tracked purchase:', products.length, 'items');
  } catch (error) {
    console.error('UBI: Error tracking purchase:', error);
  }
}

/**
 * Track a custom event
 * Use this for tracking custom user interactions
 * @param {string} actionName - The name of the action
 * @param {object} eventData - Event data including object details and position
 */
export function trackCustomEvent(actionName, eventData) {
  try {
    const eventAttributes = new UbiEventAttributes(
      eventData.idField || '_id',
      eventData.id,
      eventData.description,
      eventData.details || {},
      eventData.position || { ordinal: 0 }
    );

    const event = new UbiEvent(
      getApplicationName(),
      actionName,
      getClientId(),
      getSessionId(),
      getQueryId(),
      eventAttributes,
      eventData.message
    );

    const client = getUbiClient();
    client.trackEvent(event);
    
    console.log('UBI: Tracked custom event:', actionName);
  } catch (error) {
    console.error('UBI: Error tracking custom event:', error);
  }
}

// Make functions available globally for use in Rails views
if (typeof window !== 'undefined') {
  window.UbiTracking = {
    trackSearchQuery,
    trackProductClick,
    trackProductView,
    trackAddToCart,
    trackPurchase,
    trackCustomEvent
  };
}
