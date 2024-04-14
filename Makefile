include .devcontainer/hostname.env
export

.PHONY: help all create
.DEFAULT_GOAL := all

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  all         start the ArgoCD installation"

all:
	@echo "Replacing ingress hostname..."
	
	@sed -i "s|127.0.0.1.nip.io|$$WORKSPACE_ID|" gitops/manifests/prometheus-grafana/prometheus-ingress.yaml
	@sed -i "s|127.0.0.1.nip.io|$$WORKSPACE_ID|" gitops/manifests/prometheus-grafana/grafana-ingress.yaml
	@sed -i "s|127.0.0.1.nip.io|$$WORKSPACE_ID|" gitops/manifests/argo-config/ingress.yaml
	@sed -i "s|127.0.0.1.nip.io|$$WORKSPACE_ID|" gitops/manifests/demo-application/ingress.yaml

	@echo "Deploy ArgoCD"
	@kubectl create namespace argocd || true
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Wait for ArgoCD to be ready..."
	@kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
	@echo "Configure ArgoCD"
	@kubectl apply -n argocd -f .devcontainer/argocd-no-tls.yaml
	@kubectl apply -n argocd -f .devcontainer/argocd-nodeport.yaml
	@echo "Restart ArgoCD server..."
	@kubectl -n argocd rollout restart deploy/argocd-server
	@kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
	@echo "Create ArgoCD App of Apps..."
	@kubectl -n argocd apply -f gitops/app-of-apps.yaml
	@echo "ArgoCD Admin Password"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo ""
	@echo ""
	@echo "🎉 Installation Complete! 🎉"
