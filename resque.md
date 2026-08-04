# Resque on boxrunner — Recommendations

## Context

- **Rails:** 8.1.3
- **Ruby:** 3.4.9
- **Current Active Job adapter:** `:solid_queue` (see `config/environments/production.rb`)

Because this is a Rails 8 app already wired up with Solid Queue, the recommendation
below leads with "should you?" before "how".

## Should you use Resque on Rails 8?

For a **new** Rails 8 app, Resque is usually *not* the best choice anymore:

- **Solid Queue** (already your adapter) is the Rails 8 default. It's database-backed,
  needs **no Redis**, and is maintained by the Rails team. You already have it wired up.
- **Sidekiq** is the most popular Redis-backed option — multithreaded, far more efficient
  than Resque (which is process-per-worker), actively maintained, and the de-facto standard
  if you *do* want Redis.
- **Resque** is mature and battle-tested but comparatively dated: it forks one process per
  job (memory-heavy), and the ecosystem has largely moved to Sidekiq/Solid Queue.

**Only reach for Resque if you have a specific reason** (existing Resque infrastructure,
team familiarity, a plugin you depend on). Otherwise stick with Solid Queue or pick Sidekiq.

## Installing & configuring Resque (best practice)

### 1. Gems

```ruby
# Gemfile
gem "resque", "~> 2.6"
gem "redis"
# Optional but recommended:
gem "resque-scheduler"   # cron-style + delayed jobs
gem "resque-web"         # the dashboard (extracted from core in Resque 2.x)
```

```bash
bundle install
```

### 2. Use it *through* Active Job, not directly

The single most important best practice: **don't write `Resque.enqueue` and
`def self.perform` everywhere.** Use Active Job with the Resque adapter so your job code
stays backend-agnostic.

```ruby
# config/application.rb  (or per-environment)
config.active_job.queue_adapter = :resque
```

```ruby
# app/jobs/welcome_email_job.rb
class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome(user).deliver_now
  end
end

WelcomeEmailJob.perform_later(user.id)
```

This way, if you later move to Sidekiq or Solid Queue, you change one config line,
not your jobs.

### 3. Redis connection — make it environment-driven

```ruby
# config/initializers/resque.rb
require "resque"

Resque.redis = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
Resque.redis.namespace = "resque:boxrunner"
```

Drive `REDIS_URL` from Rails credentials / env vars; never hardcode production hosts.

### 4. Workers — rake task + queue list

Run workers in priority order:

```bash
QUEUE=critical,default,low bundle exec rake resque:work
```

In production, supervise workers with **systemd**, **foreman/Procfile**, or your container
orchestrator — one process per worker, and run multiple processes for concurrency
(Resque is single-job-per-process).

### 5. Restart workers on deploy

Resque workers load your app code at boot and **don't pick up new code automatically**.
Your deploy must restart (or send `QUIT` for graceful shutdown of) workers, or you'll run
stale code. This is a common production gotcha.

### 6. Dashboard — mount it securely behind auth

```ruby
# config/routes.rb
require "resque/server"

authenticate :user, ->(u) { u.admin? } do   # requires an admin flag on User
  mount Resque::Server.new, at: "/resque"
end
```

Never expose `/resque` unauthenticated — it can delete/retry jobs.

### 7. Failure handling

- Configure the failure backend (Redis by default) and monitor the failed queue.
- For automatic retries, add `gem "resque-retry"` (Resque core has none built in — unlike
  Sidekiq/Active Job's `retry_on`). Note that Active Job's `retry_on`/`discard_on` *do*
  work through the adapter, which is another reason to go via Active Job.

### 8. Don't enqueue inside DB transactions

Enqueue jobs **after_commit**, not inside a transaction — otherwise a worker may pick up
the job before the record is committed (or after a rollback) and fail with
"record not found."

## Recommendation for this app

**Stay on Solid Queue** unless you have a concrete reason to need Resque/Redis. If you do
need a Redis-backed queue, prefer **Sidekiq** over Resque for new work.
