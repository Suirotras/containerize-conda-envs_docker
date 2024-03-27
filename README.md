
# Containerize all existing conda environments in a docker container

This code is a more simple and, for my purposes, more useful version of the code in the
[containerize-conda-env_docker](https://github.com/Suirotras/containerize-conda-env_docker)
repository.

Instead of picking a single environment, I copy the whole **envs** folder of conda to the
docker image. I made sure the absolute paths are identical in the docker image to prevent problems.

## Usage

First, navigate to this repository, for example:

```sh
cd /home/jari/Documents/Github/containerize-conda-envs_docker
```

Then, change in **build_dockerfile.sh** the neccessary lines, important parts are:

- the **conda_env** array, where the absolute paths of the conda environments should be given. for example:
  
  ```bash
  conda_envs=(/home/jari/miniconda3/envs/Acomys_comp_genomics \
            /home/jari/miniconda3/envs/kaleido_env \
            /home/jari/miniconda3/envs/r_seurat) \
            # Other conda environments
  ```

  These environments will be copied this repository so they can be copied to the docker image while running `docker build`.

- The name can be change of the resulting docker image:
  
  ```bash
  docker build -f Dockerfile -t "{dockerUsername}/{ImageName}" .
  ```

  In my case:

  ```bash
  docker build -f Dockerfile -t "jarivdiermen/acomys_conda_environments" .
  ```

- The name should also be changed for pushing the resulting container to docker hub.
  
  ```bash
  docker push {dockerUsername}/{ImageName}:latest
  ```

  In my case:

  ```bash
  docker push jarivdiermen/acomys_conda_environments:latest
  ```

Some elements could also be changed in the Dockerfile:

- Additional dependencies could be installed if needed.

- The installation directory for **miniconda3** and the **conda environments** could be changed.

  - To change the directory where **miniconda** and the **conda environments** are stored, change the lines that say `home` or `home/jari`.

    For example, to change the location from `home/jari` to `home/john`, change the code:

    ```bash
    ## install miniconda3
    RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh > /install_conda.sh && \
        chmod +x /install_conda.sh && \ 
        mkdir -p /home && \
        mkdir -p /home/jari && \
        /install_conda.sh -b -p home/jari/miniconda3 && \
        rm /install_conda.sh
    ## Copy the environments to the container
    COPY envs /home/jari/miniconda3/envs
    ```

    To 

    ```bash
    ## install miniconda3
    RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh > /install_conda.sh && \
        chmod +x /install_conda.sh && \ 
        mkdir -p /home && \
        mkdir -p /home/john && \
        /install_conda.sh -b -p home/john/miniconda3 && \
        rm /install_conda.sh
    ## Copy the environments to the container
    COPY envs /home/john/miniconda3/envs
    ```

    Or to change the location to `opt/miniconda3`:

    ```bash
    ## install miniconda3
    RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh > /install_conda.sh && \
        chmod +x /install_conda.sh && \ 
        mkdir -p /opt && \
        /install_conda.sh -b -p opt/miniconda3 && \
        rm /install_conda.sh
    ## Copy the environments to the container
    COPY envs /opt/miniconda3/envs
    ```

  - **The location must be picked in such a way, that the abolute paths of the conda environments are exactly the same before and after containerizing the environments in a docker image.** In my case, the miniconda installation and the environments had to be stored in the `home/jari` folder.

## Create and use singularity container

The docker image can be pulled from docker hub as a singularity container. This was done as follows:

```bash
singularity build --fakeroot --force {name_of_singularity_container}.sif docker://{UserName}/{DockerImageName}:latest
```

In my case, this was:

```bash
singularity build --fakeroot --force acomys_conda_environments.sif docker://jarivdiermen/acomys_conda_environments:latest
```

If miniconda was installed in the `/home` directory, then the singularity container should be executed or run in a specific way. This is because the `/home` directory is mounted by default, causing the miniconda3 installation to be hidden. This is avoided by using the `--no-home` option, which stops singularity from mounting the `/home` directory.

However, this produces another problem, as scripts and data you want to use are probably also in the `/home` folder. As you are not mounting the `/home` directory, you will not have access to these scripts and this data. This problem is solved by manually mounting the directory of interest, that contains all the relevant scripts and data.

In my case, this relevant directory is `/home/jari/Documents/Github/Repo_minor_research_project`. This can be manually mounted using the `-B` option.

So, to get an interactive session, I ran the following command:

```bash
singularity shell -B /home/jari/Documents/Github/Repo_minor_research_project:/home/jari/Documents/Github/Repo_minor_research_project --no-home acomys_conda_environments.sif
```

Moreover, the following command allows you to execute commands in this container

```bash
singularity exec -B /home/jari/Documents/Github/Repo_minor_research_project:/home/jari/Documents/Github/Repo_minor_research_project --no-home acomys_conda_environments.sif [COMMAND]
```

Because you want to execute scripts and commands using a conda environment, the first command should always be the one that activates the relevant conda environment. For example:

```bash
singularity exec -B /home/jari/Documents/Github/Repo_minor_research_project:/home/jari/Documents/Github/Repo_minor_research_project --no-home acomys_conda_environments.sif bash -c "source /home/jari/miniconda3/bin/activate {CONDA_ENV} && echo 'next command'"
```

When you select the conda environment named Acomys_comp_genomics, this looks like this:

```bash
singularity exec -B /home/jari/Documents/Github/Repo_minor_research_project:/home/jari/Documents/Github/Repo_minor_research_project --no-home acomys_conda_environments.sif bash -c "source /home/jari/miniconda3/bin/activate Acomys_comp_genomics && echo 'next command'"
```
