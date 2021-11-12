f34:
	podman build --build-arg fedora_version=34 -t app .

f35:
	podman build --build-arg fedora_version=35 -t app .

run:
	podman run --rm -p 8080:8080 app
