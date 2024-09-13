#!/usr/bin/env bash

if [ -z "$IMG" ]; then
  echo "no found IMG env"
  exit 1
fi

set -e

make kustomize
KUSTOMIZE=$(ls $(pwd)/bin/kustomize-* 2>/dev/null | head -n 1)
(cd config/manager && "${KUSTOMIZE}" edit set image controller="${IMG}")
"${KUSTOMIZE}" build config/default | sed -e 's/imagePullPolicy: Always/imagePullPolicy: IfNotPresent/g' > /tmp/rollout-kustomization.yaml
echo -e "resources:\n- manager.yaml" > config/manager/kustomization.yaml
kubectl apply -f /tmp/rollout-kustomization.yaml
