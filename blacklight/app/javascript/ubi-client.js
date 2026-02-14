/**
 * UBI Client initialization and helper functions for Chorus Electronics
 * This file manages the UbiClient instance and provides helper methods for
 * generating client IDs, session IDs, and query IDs.
 */

import { UbiClient } from './ubi';

// Configuration
const APPLICATION_NAME = 'chorus-electronics';

// Get the current origin for Rails endpoints
function getRailsBaseUrl() {
  return window.location.origin;
}

// Initialize the UBI client
let ubiClient = null;

export function getUbiClient() {
    console.log('Getting UBI Client');
  if (!ubiClient) {
    // Use Rails endpoints instead of direct OpenSearch
    ubiClient = new UbiClient(getRailsBaseUrl());
    // Set verbose to 1 for debugging (set to 0 in production)
    ubiClient.verbose = 1;
  }
  return ubiClient;
}

/**
 * Generate a GUID for unique identifiers
 * Works in both HTTPS and HTTP contexts
 */
export function generateGuid() {
  try {
    // Try to use crypto.randomUUID (works in HTTPS)
    return crypto.randomUUID();
  } catch (error) {
    // Fallback for HTTP contexts
    return '10000000-1000-4000-8000-100000000000'.replace(/[018]/g, c =>
      (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
    );
  }
}

/**
 * Get or create a client ID
 * Client ID persists across sessions (stored in localStorage)
 */
export function getClientId() {
  let clientId = localStorage.getItem('ubi_client_id');
  if (!clientId) {
    clientId = generateGuid();
    localStorage.setItem('ubi_client_id', clientId);
  }
  return clientId;
}

/**
 * Get or create a session ID
 * Session ID persists for the current session (stored in sessionStorage)
 */
export function getSessionId() {
  let sessionId = sessionStorage.getItem('ubi_session_id');
  if (!sessionId) {
    sessionId = generateGuid();
    sessionStorage.setItem('ubi_session_id', sessionId);
  }
  return sessionId;
}

/**
 * Generate a new query ID and store it in session storage
 * This should be called when a new search is performed
 */
export function generateQueryId() {
  const queryId = generateGuid();
  sessionStorage.setItem('ubi_query_id', queryId);
  return queryId;
}

/**
 * Get the current query ID from session storage
 */
export function getQueryId() {
  return sessionStorage.getItem('ubi_query_id') || generateQueryId();
}

/**
 * Clear the current query ID
 * Call this when starting a new search
 */
export function clearQueryId() {
  sessionStorage.removeItem('ubi_query_id');
}

/**
 * Get the application name
 */
export function getApplicationName() {
  return APPLICATION_NAME;
}

// Export for debugging
export function debugUbiIds() {
  console.log('UBI Debug Info:', {
    clientId: getClientId(),
    sessionId: getSessionId(),
    queryId: getQueryId(),
    application: getApplicationName()
  });
}
