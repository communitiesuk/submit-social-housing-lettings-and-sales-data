if [ $# -ne 2 ];
  then echo "Expected 2 arguments: exec.sh env command"
fi

env=$1
command=$2
cluster="core-$env-app"

taskId=$(aws ecs list-tasks --cluster $cluster --service-name "core-$env-app" --query "taskArns[0]" | grep -o "/$cluster/\w*" | sed "s@/$cluster/@@g")
aws ecs execute-command --cluster "core-$env-app" --task $taskId --interactive --command "$command"
