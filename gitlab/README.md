## Intro
In this document I'll explain how did I separate the omnibus gitlab build
to multiple services.

I followed the guides to make the service to be compatible with 2K users.
More details can be found here https://docs.gitlab.com/ee/administration/reference_architectures/2k_users.html


## Add more workers
To add more workers we have a few components that need to be edited:
* Increase the `scale` field in `gitlab` service.
* For each scaled container, `docker-compose` adds `_(int)` extension to container name.
  once you will increase the scale field, you will get another `gitlab_gitlab_3` for example.
* In `ingress` service you should edit `external_links` field and add the new mapped service.
* In `nginx.conf` - you should add the new service to the following upstreams:
    * `load_balancer_http`
    * `load_balancer_https`
    * `load_balancer_ssh`
* Once all configured, run `start.sh` again and the components will get updated
