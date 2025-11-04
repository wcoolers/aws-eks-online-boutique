#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
REGION="us-east-1"
REPO="online-boutique"
SERVICES=("frontend" "cartservice" "checkoutservice" "productcatalogservice" "recommendationservice" "currencyservice" "shippingservice" "emailservice" "paymentservice" "adservice" "loadgenerator" "redis-cart")

for SERVICE in "${SERVICES[@]}"
do
    IMAGE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO/$SERVICE:latest"
    
    echo "============ Building $SERVICE ============"
    
    docker build -t $IMAGE ./src/$SERVICE
    
    echo "============ Pushing $SERVICE to ECR ============"
    
    aws ecr describe-repositories --repository-name "$REPO/$SERVICE" --region $REGION >/dev/null 2>&1 || \
    aws ecr create-repository --repository-name "$REPO/$SERVICE" --region $REGION
    
    docker push $IMAGE
done

echo "✅ All images built and pushed successfully!"


