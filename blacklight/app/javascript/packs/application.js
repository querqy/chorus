// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

// Import UBI tracking modules - these need to execute to set up window.UbiTracking
import '../ubi-client.js'
import '../ubi-tracking.js'

// Debug UBI loading
document.addEventListener('DOMContentLoaded', function() {
  console.log('Application.js loaded');
  console.log('UbiTracking available:', !!window.UbiTracking);
  if (window.UbiTracking) {
    console.log('UbiTracking methods:', Object.keys(window.UbiTracking));
  }
});

Rails.start()
Turbolinks.start()
ActiveStorage.start()
