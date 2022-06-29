# Monitoring

We use self-hosted Prometheus and Grafana for monitoring infrastructure metrics. These are run in a dedicated Gov PaaS space called "monitoring" and are deployed as Docker images using Github action pipelines. The repository for these and more information is here: [dluhc-data-collection-monitoring](https://github.com/communitiesuk/dluhc-data-collection-monitoring).

## Performance monitoring and alerting

For application error and performance monitoring we use managed [Sentry](https://sentry.io/organizations/dluhc-core). You will need to be added to the DLUHC account to access this. It triggers slack notifications to the #team-data-collection-alerts channel for all application errors in staging and production and for any controller endpoints that have a P95 transaction duration > 250ms over a 24 hour period.

## Logs

For log persistence we use a managed ELK (Elasticsearch, Logstash, Kibana) stack provided by [Logit](https://logit.io/). You will need to be added to the DLUHC account to access this. Longs are retained for 14 days with a daily limit of 2GB.

Logs are also available from Gov PaaS directly via CLI:

```bash
cf logs <gov-paas-space-name> --recent
```
