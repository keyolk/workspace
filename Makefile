include makefiles/*.mk

IMAGE=keyolk

build: ## build
	docker build -t $(IMAGE) --build-arg user=irteam --build-arg gid=500 --build-arg uid=500 .
build/nocache: ## build
	docker build -t $(IMAGE) --build-arg user=irteam --build-arg gid=500 --build-arg uid=500 --no-cache .

work/clean: ## clean work env
	docker rm -f keyolk-work

work/create:
	docker run -tid \
		--cap-add NET_ADMIN \
		--cap-add NET_RAW \
		--cap-add SYS_ADMIN \
		-e REMOTE_USER=keyolk \
		-v /etc/ssh/ssh_config:/etc/ssh/ssh_config \
		-v /etc/krb5.conf:/etc/krb5.conf \
		-v /etc/nsswitch.conf:/etc/nsswitch.conf \
		-v /usr/local/sbin/cilookup:/usr/local/sbin/cilookup \
		-v /usr/local/sbin/iplookup:/usr/local/sbin/iplookup \
		-v /naver:/naver \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/run/nscd:/var/run/nscd \
		--name keyolk-work \
		$(IMAGE)

work/run: work/create ## run work env
	@docker exec -ti keyolk-work bash -c "/naver/work/keyolk/local/init.sh"

work/attach: ## attach to work env
	docker attach keyolk-work

test/docker/run: ## run test env
	-docker rm --force keyolk-test-docker
	docker run -ti \
		--name keyolk-test-docker \
		-v /naver:/naver \
		-v /naver/work/keyolk/cocofarm/docker-ce/components/engine/bundles/binary-daemon:/usr/local/bin \
		--userns host \
		--privileged \
		-u root \
		-w /root \
		$(IMAGE) dockerd

test/docker/attach: ## attach to test env
	docker attach keyolk-test-docker

test/docker/sh: ## attach to test env
	docker exec -ti keyolk-test-docker bash
