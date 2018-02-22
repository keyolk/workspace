include makefiles/*.mk

IMAGE=keyolk

build: ## build
	docker build -t $(IMAGE) .

build/nocache: ## build
	docker build --no-cache -t $(IMAGE) .

work/run: ## run work env
	-docker rm --force keyolk-work
	docker run -ti \
		--cap-add NET_ADMIN \
		--cap-add NET_RAW \
		--cap-add SYS_ADMIN \
		-v /etc/ssh/ssh_config:/etc/ssh/ssh_config \
		-v /etc/krb5.conf:/etc/krb5.conf \
		-v /etc/nsswitch.conf:/etc/nsswitch.conf \
		-v /usr/local/sbin/cilookup:/usr/local/sbin/cilookup \
		-v /usr/local/sbin/iplookup:/usr/local/sbin/iplookup \
		-v /naver:/naver \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/run/nscd:/var/run/nscd \
		-v $$HOME/.ssh:/home/irteam/.ssh \
		-v $$(readlink $$HOME/work):/home/irteam/work \
		-v $$(readlink $$HOME/work)/dockerfiles/workspace:/home/irteam/env \
		-v $$(readlink $$HOME/work)/wiki:/home/irteam/wiki \
		-v $$HOME/.local/share:/home/irteam/.local/share \
		-v $$HOME/.local/bin:/home/irteam/.local/bin \
		--name keyolk-work \
		$(IMAGE)

work/attach: ## attach to work env
	docker attach keyolk-work

test/docker/run: ## run test env
	-docker rm --force keyolk-test-docker
	docker run -ti \
		--name keyolk-test-docker \
		-v /naver:/naver \
		-v $$GOPATH/src/github.com/docker/docker-ce/components/engine/bundles/binary-daemon:/usr/local/bin \
		--userns host \
		--privileged \
		-u root \
		-w /root \
		$(IMAGE) dockerd

test/docker/attach: ## attach to test env
	docker attach keyolk-test-docker
