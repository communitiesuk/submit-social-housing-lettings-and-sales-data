---
nav_order: 11
---

# Running Rake Tasks
On CORE, we sometimes need to run a Rake task manually on one of our deployed environments.

## Rake Tasks
Rake tasks are defined in the `lib/tasks` directory of a Rails application.

## Running Rake Tasks locally
This can be done from the command line:
```bash
bundle exec rake <task>
```

## Running Rake Tasks on CORE infrastructure
### Get access to an AWS CLI
TODO docs on this

### Set up environment variables
Set the env as appropriate:
```bash
export env=prod
```
Other options are `staging` or `review-XXXX`, where `XXXX` is the review app number.

Set up the Rake Task as appropriate:
```bash
export rake_task=<task>
```
Where `<task>` is the name of the Rake task you want to run, local equivalent would be `bundle exec rake <task>`.

Set up the CPU and memory requirements for the task:
```bash
export cpu_value=1024
export memory_value=2048
```
See [the AWS documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size) for valid CPU and memory pairs.

Set the other environment variables:
```bash
export cluster=core-$env-app
export service=core-$env-app
export ad_hoc_task_definition=core-$env-ad-hoc
export network=$(aws ecs describe-services --cluster $cluster --services $service --query services[0].networkConfiguration)
export overrides="{ \"containerOverrides\" : [{ \"name\" : \"app\", \"command\" : [\"bundle\", \"exec\", \"rake\", \"$rake_task\"], \"memory\" : $memory_value, \"cpu\" : $cpu_value }] }"
```

### Start the Rake Task
```bash
aws ecs run-task --cluster $cluster --task-definition $ad_hoc_task_definition --network-configuration "$network" --overrides "$overrides" --launch-type FARGATE --query tasks[0].taskArn
```
   
The task ARN will be printed to the console.

### View the Task progress
This can be viewed in the AWS console by navigating to the ECS cluster specified in the environment variables, listing all tasks in the cluster, and selecting the task with the ARN printed in the previous step.
