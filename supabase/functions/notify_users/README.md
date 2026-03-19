# notify_users Edge Function

Sends OneSignal push notifications for: checkin reminder, letter delivery, milestone day-before.

## Env vars (Supabase Dashboard → Edge Functions → Secrets)
- `ONESIGNAL_APP_ID` — from app (os_v2_app_...)
- `ONESIGNAL_REST_API_KEY` — OneSignal Dashboard → Keys
- `CRON_SECRET` — random string for auth

## Cron setup (e.g. GitHub Actions, Vercel Cron, or pg_cron)

```bash
# Every hour: checkin reminder (pass current hour 0-23)
curl -H "Authorization: Bearer $CRON_SECRET" "https://YOUR_PROJECT.supabase.co/functions/v1/notify_users?type=checkin&hour=$(date +%H)"

# Daily 08:00: letter delivery
curl -H "Authorization: Bearer $CRON_SECRET" "https://YOUR_PROJECT.supabase.co/functions/v1/notify_users?type=letter"

# Daily 20:00: milestone day-before
curl -H "Authorization: Bearer $CRON_SECRET" "https://YOUR_PROJECT.supabase.co/functions/v1/notify_users?type=milestone"
```
