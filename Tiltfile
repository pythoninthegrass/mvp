# -*- mode: Python -*-

docker_build('mvp', '.')
k8s_yaml('kubernetes.yml')
k8s_resource('mvp', port_forwards=8000)
