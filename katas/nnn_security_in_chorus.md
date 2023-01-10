# Seventh Kata: Let's talk a bit about managing your users!

The hackers are everywhere, and they just want to bring down your site!

We are using a mix of Basic auth and OpenID based authorization.   

Basic auth is used to secure communication between processes, for example to let Blacklight talk to Solr, or Prometheus to get metrics from Solr.

We do have the `/solr/ecommerce/select?q=*:*` end point exposed for RRE to access right now.

<<Move to top?>>  
However, for our users, well we need to be able to manage them in a central location.   We have set up Keycloak as our centralized user management system for Quepid, SMUI, and Solr for individual users.   Users can register on Keycloak, but we have to grant them access to systems.  <-- maybe remove the registering???



http://localhost:9080/auth/realms/chorus/.well-known/openid-configuration

https://clemente-biondo.github.io/ for generating solr passwords.
