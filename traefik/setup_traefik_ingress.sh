HOSTED_ZONE="kube.citizendev.vn."
SERVER_SUBDOMAIN="base"
SERVER_FQDN="$SERVER_SUBDOMAIN.$HOSTED_ZONE"


# helm install -n traefik traefik

export AWS_PAGER=""
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --output json | jq -r ".HostedZones[] | select(.Name==\"$HOSTED_ZONE\").Id")
echo HOSTED_ZONE=$HOSTED_ZONE_ID

LB_DOMAIN=$(kubectl get svc -n traefik traefik -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

echo LB_DOMAIN=$LB_DOMAIN

aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch '
  {
    "Comment": "Update Domain for LB",
    "Changes": [{
      "Action"              : "UPSERT",
      "ResourceRecordSet"  : {
        "Name"              : "'"$SERVER_FQDN"'",
        "Type"             : "CNAME",
        "TTL"              : 120,
        "ResourceRecords"  : [{
            "Value"         : "'"$LB_DOMAIN"'"
        }]
      }
    }]
  }
  '
