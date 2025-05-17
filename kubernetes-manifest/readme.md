Ingress controller installation

Let’s clarify: YES, conceptually it is the same whether you:

✅ Manually install the NGINX Ingress Controller using a YAML file (like we just did), or

✅ Use Helm to install the NGINX Ingress Controller (which is often preferred in production).

🔍 So what’s the difference?
Aspect	kubectl apply .../deploy.yaml	helm install ingress-nginx ...
Installation Method	Static manifest	Helm chart
Customization	Minimal, manual edits	Highly configurable via values.yaml
Upgrade/Downgrade	Manual delete & re-apply	Easy with helm upgrade or rollback
Tracking changes	Harder	Helm tracks releases
Default config	NGINX best defaults	Same defaults but configurable
Used in examples	Lightweight demos, quick tests	Production setups

✅ Example:
When we did this earlier:

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/cloud/deploy.yaml
We used a predefined manifest that:

Sets up the ingress-nginx-controller deployment

Exposes it via a LoadBalancer service

Uses default configuration from the NGINX team

🔧 If we used Helm, it would be like:

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace
And later you could run:


helm upgrade ingress-nginx ingress-nginx/ingress-nginx
helm uninstall ingress-nginx
✅ Summary:
What you did now (using raw YAML) is 100% functionally valid and equivalent to the Helm version in terms of setting up the controller. But Helm is better when:

You want to easily manage config

You need to upgrade, rollback, or track changes

You’re working in a team or CI/CD

