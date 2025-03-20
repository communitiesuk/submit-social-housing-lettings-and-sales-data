---
title: PlanUML source for diagrams
---

{% plantuml %}
!define AWSPuml https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/v19.0/dist
!include AWSPuml/AWSCommon.puml
!include AWSPuml/Groups/VPC.puml
!include AWSPuml/Groups/GenericOrange.puml
!include AWSPuml/Storage/SimpleStorageService.puml
!include AWSPuml/AWSSimplified.puml
!include AWSPuml/Groups/PublicSubnet.puml
!include AWSPuml/Groups/PrivateSubnet.puml
!include AWSPuml/Containers/ElasticContainerService.puml
!include AWSPuml/Database/RDS.puml
!include AWSPuml/Database/ElastiCacheElastiCacheforRedis.puml
!include AWSPuml/NetworkingContentDelivery/CloudFront.puml
!include AWSPuml/NetworkingContentDelivery/ElasticLoadBalancingApplicationLoadBalancer.puml
!include AWSPuml/Containers/ElasticContainerRegistry.puml
!include AWSPuml/Groups/AWSAccount.puml

' External Systems
actor User

' Main System: Meta Environment
AWSAccountGroup(meta, "Meta Environment") {
ElasticContainerRegistry(ecr, "ECR (Elastic Container Registry) - Shared between environments", "ECR (Elastic Container Registry)","")
}

VPCGroup(vpc) {
PublicSubnetGroup(public_subnet, "Public subnet") {
ElasticLoadBalancingApplicationLoadBalancer(loadBalancer, "Load Balancer", "Load Balancer", "")
}
PrivateSubnetGroup(private_subnet, "Private subnet") {
GenericOrangeGroup(fargateTasks, "ECS Fargate Tasks") {
ElasticContainerService(App, "App", "Container", "")
ElasticContainerService(Sidekiq, "Sidekiq", "Container", "")
ElasticContainerService(AdHocTasks, "Ad-hoc Tasks", "Container", "")
}

    RDS(rdsDatabase, "RDS", "RDS","")
    ElastiCacheElastiCacheforRedis(redis, "ElastiCache for Redis", "Redis","")

}
}
' Networking

SimpleStorageService(bulkUpload, "Bulk Upload", "Bulk upload bucket", "")
SimpleStorageService(cdsExport, "CDS Export", "CDS export bucket", "")
SimpleStorageService(collectionResources, "Collection resources", "Collection resources bucket", "")
CloudFront(cloudFront, "CloudFront", "CloudFront", "")

' Relationships
User --> [cloudFront] : Interacts with
[loadBalancer] --> [fargateTasks] : Routes traffic to

[ecr] --> [fargateTasks] : Pulls Docker images from
[cloudFront] --> [loadBalancer] : Routes traffic to

[fargateTasks] --> [bulkUpload] : Uploads data to
[fargateTasks] --> [cdsExport] : Exports data to
[fargateTasks] --> [collectionResources] : Reads/writes data to
[fargateTasks] --> [rdsDatabase] : Writes data to
[fargateTasks] --> [redis] : Caches data in

{% endplantuml %}

---

{% plantuml %}
!define AWSPuml https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/v19.0/dist
!include AWSPuml/AWSCommon.puml
!include AWSPuml/Storage/SimpleStorageService.puml
!include AWSPuml/Groups/GenericOrange.puml
!define SPRITESURL https://raw.githubusercontent.com/plantuml-stdlib/gilbarbara-plantuml-sprites/v1.1/sprites
!define IMAGESSURL https://raw.githubusercontent.com/plantuml-stdlib/gilbarbara-plantuml-sprites/v1.1/pngs
!includeurl SPRITESURL/sentry.puml
!includeurl SPRITESURL/google-analytics.puml
!include AWSPuml/Containers/ElasticContainerService.puml
!include AWSPuml/AWSSimplified.puml

skinparam actorPadding 15
skinparam packagePadding 20
skinparam componentPadding 20
skinparam rectanglePadding 20

rectangle "<img:IMAGESSURL/google-analytics.png>" as ga
rectangle "<img:IMAGESSURL/sentry.png>" as sentry
rectangle "GOV.UK Notify" as notify
rectangle "OS Places API" as osapi
rectangle "CDS Ingest Pipeline" as cds

actor "End Users" as Users
actor "Support Users" as SupportUsers

' Main System: Application Package
package "Application" {
ElasticContainerService(App, "App", "Container", "")
SimpleStorageService(cdsExport, "CDS Export", "CDS export bucket", "")
}

' Relationships and interactions
Users --> [App] : Provides data, downloads CSVs
SupportUsers --> [App] : Support tasks, file downloads
[App] --> [notify] : Email notifications
[App] --> [sentry] : Alerts
[App] --> [osapi] : Address lookup
[cds] --> [cdsExport] : Downloads data for processing
[App] --> [ga] : Sends analytics data to Google Analytics

{% endplantuml %}
