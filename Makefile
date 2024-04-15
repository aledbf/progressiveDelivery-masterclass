include .devcontainer/container.env
export

.PHONY: help all create
.DEFAULT_GOAL := all

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  all         start the ArgoCD installation"

all:	
	@echo "Deploy ArgoCD"
	@kubectl create namespace argocd || true
	@echo "Replacing ingress hostname..."
	@sed -i "s|ENCODED_WORKSPACE_ID|$$ENCODED_WORKSPACE_ID|" gitops/argo-secret-vars.yaml
	@kubectl apply -n argocd -f gitops/argo-secret-vars.yaml
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Wait for ArgoCD to be ready..."
	@kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
	@helm repo add appset-secret-plugin https://small-hack.github.io/appset-secret-plugin
	@helm install appset-secret-plugin appset-secret-plugin/appset-secret-plugin	
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
