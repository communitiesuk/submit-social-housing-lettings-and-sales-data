### ADR - 008: Background Job Queueing and Processing

#### Why background jobs?

While we can probably target making validations run fast enough to be able to complete all single case log API actions synchronously in process, with arbitrarily large bulk actions that becomes impossible so we probably need to introduce background job queueing and processing. This will enable us to return an API response immediately and process the Case Logs sent asynchronously.

We will use ActiveJob backed by Good Job (https://github.com/bensheldon/good_job) for this.

#### Why Good Job?

There are multiple options we could use for this, with the main differences being Thread based vs Process based, and Queueing database (Postgres vs Redis):

- Sidekiq (Thread-based, Redis)
- Faktory (Thread-based, Redis)
- Resque (Process-based, Redis)
- Delayed Job (Process-based, Postgres)
- Good Job (Thread-based, Postgres)

Sidekiq is probably the most widely used multi-threaded job backend, and is also widely used in Gov.UK services (https://docs.publishing.service.gov.uk/manual/sidekiq.html) but requires additional infrastructure (Redis). By sticking with a Postgres based backend initially we can keep our architecture simpler, and only add Redis if we need to later.

By using ActiveJob as our interface we can ensure that changing backend later requires minimal if any rewriting of job code. Of the two Postgres based backends Good Job is the more recent, inspired by Delayed Job but specifically written for Rails and ActiveJob making it a good fit here. It also expects to be performant for up to 1-million jobs per day which is more than we're expecting by orders of magnitude.
