#!/bin/bash
helm template ./cilium \
  --namespace=kube-system \
  --set preflight.enabled=true \
  --set agent.enabled=false \
  --set config.enabled=false \
  --set operator.enabled=false \
  --set global.k8sServiceHost=127.0.0.1 \
  --set global.k8sServicePort=39145 \
  > cilium-without-kube-proxy--upgrade-preflight.yaml
