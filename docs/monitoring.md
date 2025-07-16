---
nav_order: 6
---

# Logs and Debugging

## Logs

Logs can be found in two locations:

- AWS CloudWatch (for general application / infrastructure logging)
- Sentry (for application error logging)

### CloudWatch

The CloudWatch service can be accessed from the AWS Console. You should authenticate onto the infrastructure environment whose logs you want to check.
From CloudWatch, navigate to the desired log group (e.g. for the app task running on ECS) and open the desired log stream, in order to read its log “events”.
Alternatively, you can also navigate to a specific AWS service / resource in question (e.g. ECS tasks), selecting the instance of interest (e.g. a specific ECS task), and finding the “logs” tab (or similar) to view the log “events”.

### Sentry

To access Sentry, ensure you have been added to the MHCLG account.
Generally error logs in Sentry will also be present somewhere in the CloudWatch logs, but they will be easier to assess here (e.g. number of occurrences over a time period). The logs in Sentry are created by the application when it makes Rails.logger.error calls.

## Debugging

### Application infrastructure

For debugging / investigating infrastructure issues you can use the AWS CloudWatch automatic dashboards. (e.g. is there a lack of physical space on the database, how long has the ECS had very high compute usage for etc.)
They can be found in the CloudWatch service on AWS console, by going to dashboards → automatic dashboards, and selecting the desired dashboard (e.g. Elastic Container Service).
Alternatively, you can also navigate to the AWS resource in question (e.g. RDS database), selecting the instance of interest, and selecting the “monitoring” / ”metrics” tab (or similar), as this can provide alternate useful information also.

### Exec into a container

You can open a terminal directly on a running container / app, in order to run some commands that may help with debugging an issue.
To do this, you will need to “exec” into the container.

#### Prerequisites

- AWS CLI
- AWS Session manager plugin Install the Session Manager plugin for the AWS CLI - AWS Systems Manager
- AWS access

#### Accessing the rails console

Prerequisite:
Configure AWS auth following the [documentation in the infra repo](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data-infrastructure/blob/main/docs/development_setup.md). This also details how to enter a subshell with suitable AWS credentials.

In a shell using suitable AWS credentials for the relevant account (e.g. the development, staging, or production account), run `./exec.sh env command`

E.g. `./exec.sh staging "rails c"` - this will open the rails console on an app container in the staging environment, when authenticated for the staging aws account.

You can use this for other commands, e.g. to get a bash shell.

For production, use `prod` as the environment. For a review app, use `review-<PR-NUM>`

Alternatively, if you care about which container you're accessing, you can view a table of container details with e.g.

```
env=staging
taskArns=$(aws ecs list-tasks --cluster "core-$env-app" --query "taskArns[*]")
aws ecs describe-tasks --cluster "core-$env-app" --tasks "${taskArns[@]}" --query "tasks[*].{arn:taskArn, status:lastStatus, startedAt:startedAt, group:group, image:containers[0].image}" --output text
```

You can then use `aws ecs execute-command --cluster "core-$env-app" --task <taskid> --interactive --command <command>` to run the relevant command on a specific task.

### Database

In order to investigate or look more closely at the database, you can exec into a container as above, and use the rails console to query the database.
