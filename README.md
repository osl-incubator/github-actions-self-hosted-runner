# Containerize a GitHub Actions self-hosted runner

This is a project heavily based on https://github.com/beikeni/github-runner-dockerfile
The main difference is that it allows a more flexible approach to define the docker-compose.yaml file.

It is necessary to create a .env file with the desired environment variables:

```bash
$ envsubst < .env.tpl > .env
```

Change the values in .env to the values you need for your docker-compose file.

```bash
$ ./create-compose-file.sh
```

Run `docker compose` with the .env you just created:

```
$ docker compose --env-file .env build
```

You can also use `make` to call the following targets: `build`, `start`, and `stop`.
It will automatically run docker compose with the dotenv file and call its subcommand properly.

In order to allow the Docker stack inside the GitHub Runner (that will be running as a Docker Contaienr), 
we need to use it with sysbox.

If you need to run it in a brand-new server, maybe you will need to follow the steps below:

* [Install Docker](https://docs.docker.com/engine/install)
* [Configure Docker as rootless](https://docs.docker.com/engine/install/linux-postinstall/)
* [Install sysbox](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md)
* [Add sysbox as the default runtime](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md#configuring-dockers-default-runtime-to-sysbox)


## References

* https://baccini-al.medium.com/how-to-containerize-a-github-actions-self-hosted-runner-5994cc08b9fb
* https://github.com/beikeni/github-runner-dockerfile
* https://github.com/nestybox/sysbox#installing-sysbox
* https://github.com/PasseiDireto/gh-runner
* https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md
* https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md#configuring-dockers-default-runtime-to-sysbox
