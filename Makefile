include makefiles/*.mk

build: ## build
	docker build -t keyolk-workspace .

build/nocache: ## build
	docker build --no-cache -t keyolk-workspace .

work/run: ## run work env
	-docker rm --force keyolk-workspace
	docker run -ti \
		-v /etc/ssh/ssh_config:/etc/ssh/ssh_config \
		-v /etc/krb5.conf:/etc/krb5.conf \
		-v /etc/nsswitch.conf:/etc/nsswitch.conf \
		-v /usr/local/sbin/cilookup:/usr/local/sbin/cilookup \
		-v /usr/local/sbin/iplookup:/usr/local/sbin/iplookup \
		-v /naver:/naver \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/run/nscd:/var/run/nscd \
		-v $$HOME:/home/irteam \
		--name keyolk-workspace \
		keyolk-workspace 

work/attach: ## attach to work env
	docker attach keyolk-workspace

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
		keyolk-workspace dockerd

test/docker/attach: ## attach to test env
	docker attach keyolk-test-docker
