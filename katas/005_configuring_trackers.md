__ This is just notes for now! __

1. Bring up http://localhost:8000/preflight, and specify you are "just experimenting".  We don't have SSL on Chorus yet, so that impacts PostHog.

1. Create an account:
admin@choruselectronics.com

1. Specify Web and copy the resulting line `posthog.init()`.

1. Open up `./blacklight/app/views/layouts/chorus.html.erb` and scroll down to the `<head/>` section and update the existing `posthog.init()` line.

1. Go to blacklight: http://localhost:4000 and do a search for "teapot"
