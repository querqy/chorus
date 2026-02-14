/*
 * Copyright OpenSearch Contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * The OpenSearch Contributors require contributions made to
 * this file be licensed under the Apache-2.0 license or a
 * compatible open source license.
 */
 
/*
ubi.js is sourced from
https://github.com/opensearch-project/user-behavior-insights/tree/main/ubi-javascript-collector.
*/

import axios from 'axios';

/**
 * Methods and client to manage tracking queries and events that follow the User Behavior Insights specification.
 */
export class UbiClient {
  constructor(baseUrl) {
    // point to the specific middleware endpoint for receiving events
    this.eventUrl = `${baseUrl}/ubi_events`;
    this.queryUrl = `${baseUrl}/ubi_queries`;
    
    this.rest_config = {
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      }
    };

    this.rest_client = axios.create({
      baseURL: baseUrl,
      headers: { 
        'Content-type': 'application/json', 
        'Accept': 'application/json' 
      },
      withCredentials: false
    });

    this.verbose = 0; // Default value for verbose
  }

  async trackEvent(event, message = null, message_type = null) {
    if (message) {
      if (event.message) {
        event['extra_info'] = message;
        if (message_type) {
          event['extra_info_type'] = message_type;
        }
      } else {
        event.message = message;
        event.message_type = message_type;
      }
    }

    // Data prepper wants an array of JSON.
    let json = JSON.stringify([event]);
    if (this.verbose > 0) {
      console.log('POSTing event: ' + json);
    }

    return this._post(json, this.eventUrl);
  }

  async trackQuery(query, message = null, message_type = null) {
    if (message) {
      if (query.message) {
        query['extra_info'] = message;
        if (message_type) {
          query['extra_info_type'] = message_type;
        }
      } else {
        query.message = message;
        query.message_type = message_type;
      }
    }

    // Data prepper wants an array of JSON.
    let json = JSON.stringify([query]);
    if (this.verbose > 0) {
      console.log('POSTing query: ' + json);
    }

    return this._post(json, this.queryUrl);
  }

  async _post(data, url) {
    try {
      const response = await this.rest_client.post(url, data, this.rest_config);
      return response.data;
    } catch (error) {
      console.error(error);
    }
  }
}

export class UbiEvent {
  /**
   * This maps to the UBI Event Specification at https://github.com/o19s/ubi
   */
  constructor(application, action_name, client_id, session_id, query_id, event_attributes, message = null) {
    this.application = application;
    this.action_name = action_name;
    this.query_id = query_id;
    this.session_id = session_id;        
    this.client_id = client_id;
    this.user_id = '';
    this.timestamp = new Date().toISOString();
    this.message_type = 'INFO';
    this.message = message || '';  // Default to an empty string if no message
    this.event_attributes = event_attributes
  }

  setMessage(message, message_type = 'INFO') {
    this.message = message;
    this.message_type = message_type;
  }

  /**
   * Use to suppress null objects in the json output
   * @param key 
   * @param value 
   * @returns 
   */
  static replacer(key, value) {
    return (value == null) ? undefined : value; // Return undefined for null values
  }

  /**
   * 
   * @returns json string
   */
  toJson() {
    return JSON.stringify(this, UbiEvent.replacer);
  }
}

export class UbiEventAttributes {
  constructor(idField, id = null, description = null, details = null, position = null) {
    this.object = {
      object_id: id,
      object_id_field: idField,
      description: description,
    }
    
    // merge in the details, but make sure to filter out any defined properties
    // since details is a free form structure that could be anything.  
    var { object_id, object_id_field, description, ...filteredDetails } = details;
    
    this.object = { ...this.object, ...filteredDetails };

    // validate positional information
    // either ordinal or xy have to be set with ordinal, x and y being numbers
    if (!position) {
      throw new Error("The 'position' parameter is required.");
    }
    const hasOrdinal = 'ordinal' in position && Number.isInteger(position.ordinal);
    const hasXY =
      'xy' in position &&
      typeof position.xy === 'object' &&
      'x' in position.xy &&
      'y' in position.xy &&
      typeof position.xy.x === 'number' &&
      typeof position.xy.y === 'number';

    if (!hasOrdinal && !hasXY) {
      throw new Error(
        "The 'position' object must have either an 'ordinal' property (integer) or an 'xy' property (object with 'x' and 'y' as numbers)." + position.ordinal
      );
    }

    this.position = { ...position }; // Merge position into top-level property
  }
}

export class UbiQueryRequest {
  /**
   * This maps to the UBI Query Request Specification at https://github.com/o19s/ubi
   */
  constructor(application, client_id, query_id, user_query, object_id_field, query_attributes = {}) {
    this.application = application;
    this.query_id = query_id;    
    this.client_id = client_id;
    this.user_query = user_query;       
    this.query_attributes = query_attributes    
    this.object_id_field = object_id_field;
    this.timestamp = new Date().toISOString();
  }

  /**
   * Use to suppress null objects in the json output
   * @param key 
   * @param value 
   * @returns 
   */
  static replacer(key, value) {
    return (value == null) ? undefined : value; // Return undefined for null values
  }

  /**
   * 
   * @returns json string
   */
  toJson() {
    return JSON.stringify(this, UbiEvent.replacer);
  }
}
