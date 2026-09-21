# discourse-toggle-whisper

This theme component adds a post menu button to make a regular post a whisper or vice versa.

This is useful especially for forums where a lot of conversations happen in whisper and a user ends up posting something and later wants to hide or show the post to non-staff users.

## Settings

### `toggle_whisper_allowed_groups`

Groups whose members see the button. Defaults to `staff`. Add any group here (e.g. `eyantra_staff`).

Members also need to be in the site's `whispers_allowed_groups` to see whisper posts at all.

### `toggle_whisper_endpoint`

**Read this if you added a non-staff group above.**

Discourse core restricts the `PUT /posts/:id/post_type` route to staff — `PostGuardian#can_change_post_type?` is literally `is_staff?`. Showing the button to a non-staff group is therefore not enough on its own: the request comes back `403`. That cannot be changed from a theme component, and on Discourse-hosted sites it cannot be changed by a plugin either.

The way around it is to let a backend you control make the change with an API key belonging to a staff account:

1. Expose an endpoint on your own server (the same service that runs the bot is a natural home for it).
2. On request, verify the caller is allowed to do this, then call the Discourse API as a staff user:

   ```
   PUT https://<forum>/posts/<post_id>/post_type
   Api-Key: <key>
   Api-Username: <staff username>
   post_type=<1|4>
   ```
3. Put that endpoint's URL in this setting.

The button then POSTs JSON to it instead:

```json
{ "post_id": 123, "post_type": 4, "username": "alice" }
```

The endpoint must be reachable from the browser (CORS: allow your forum's origin, `POST`, `Content-Type: application/json`).

**The `username` in the payload is not proof of identity** — anyone can call your endpoint with any username. Authorize the request yourself, for example by checking the session against Discourse (`GET /session/current.json` proxied with the user's cookie) or by putting the endpoint behind your own auth. Do not treat the payload as trusted.

[:wrench: How to install ](https://meta.discourse.org/t/how-do-i-install-a-theme-or-theme-component/63682)

[:page_facing_up: Read the documentation ](https://thepavilion.io/t/4029)
