#! /usr/bin/env python
# cython: language_level=3
# distutils: language=c++

import ast
from contextlib  import ExitStack, contextmanager
from dataclasses import dataclass
import dis
import hashlib
import importlib
import inspect
from io          import StringIO
import logging
import multiprocessing
import os
from pathlib     import Path
import platform
import re
import shlex
import shutil
import socket
import subprocess
from subprocess  import Popen
import sys
import sysconfig
import time
import tomllib
from types       import *
from typing      import *

import docker.api.build
import dockerfile_parse
import python_on_whales

def is_docker() -> bool:
    dockerenv: Path = Path('/', '.dockerenv')
    if dockerenv.is_file():
        logging.info(f'is docker: {dockerenv}')
        return True

    cgroup: Path = Path('/', 'proc', 'self', 'cgroup')
    if (not cgroup.is_file()):
        logging.info(f'is not docker: {cgroup}')
        return False

    #return ('docker' in cgroup.read_text())
    with open(cgroup, 'r') as f:
        text:str = f.read()
    return ('docker' in text)

def ensure_venv_if_not_docker(venv_dir:Path|None=None)->None:
    if is_docker():
        logging.info('in docker, no venv necessary')
        return
    logging.info('not in docker, ensuring venv')
    #with bootstrapped(dependencies={ 'venv'            : 'venv', }):            # host requires venv
    ensure_venv(venv_dir=venv_dir)

def _enable_in_memory_dockerfiles(dockerfile:str, path:Path)->Tuple[str,Path]: # NOTE is docker, not python_on_whales: ymmv
    return ('Dockerfile', dockerfile)

def enable_in_memory_dockerfiles() -> None: # NOTE is docker, not pytnon_on_whales: ymmv
    #import docker.api.build
    docker.api.build.process_dockerfile = _enable_in_memory_dockerfiles

def generate_dockerfile(dockerfile:Path)->None: # TODO typehint
    #from dockerfile_parse import DockerfileParser
    # TODO
    raise NotImplementedError()

def generate_dockerfile_if_not_exists(dockerfile:Path)->bool: # TODO typehint
    if dockerfile.exists():
        assert dockerfile.is_file()
        return False
    assert not dockerfile.exists()
    #with bootstrapped(dependencies={'dockerfile_parse': 'dockerfile_parse'}):
    generate_dockerfile(dockerfile)
    assert dockerfile.is_file()
    return True

def generate_docker_compose(docker_compose:Path)->None: # TODO typehint
    # TODO
    #privileged: true
    #pid: host
    #volumes:
    #  - /:/host:ro
    raise NotImplementedError()

def generate_docker_compose_if_not_exists(docker_compose:Path)->bool: # TODO typehint
    if docker_compose.exists():
        assert docker_compose.is_file()
        return False
    assert not docker_compose.exists()
    #with bootstrapped(dependencies={ 'python_on_whales': 'python-on-whales', }): # also dockerfile_parse
    generate_docker_compose(docker_compose)
    assert docker_compose.is_file()
    return True

def reexec_in_docker()->None:
    compose_cmd = [ # TODO typehint
            shutil.which("docker"), "compose",
            "--file", str(compose_file),
            "run", "--rm", "app"
    ] + sys.argv[1:]

    logging.info(f"🚀 Replacing process with Docker Compose: {' '.join(compose_cmd)}")

    # Final cleanup of logging before we lose control
    logging.info("👋 See you on the other side.")
    os.execv(compose_cmd[0], compose_cmd)
    #assert is_docker()

def dockerize()->None:
    assert not is_docker()
    # TODO
    raise NotImplementedError()
    #with bootstrapped(dependencies={'dockerfile_parse': 'dockerfile_parse'}):
    generate_dockerfile_if_not_exists() # generate in tmp dir ?
    #with bootstrapped(dependencies={ 'python_on_whales': 'python-on-whales', }): # also dockerfile_parse
    generate_docker_compose_if_not_exists() # generate in tmp dir ?
    #with bootstrapped(dependencies={ 'python_on_whales': 'python-on-whales', }): # also dockerfile_parse
    docker.compose.build(project_directory=tmp_path)
    reexec_in_docker()
    #assert is_docker()

def dockerize_if_necessary()->None:
    if is_docker():
        return
    assert not is_docker()
    ensure_system_dependencies(requirements={
        'docker': {
            'apt'         : 'docker.io',
            'xbps-install': 'docker',
        },
        'docker-compose': {
            'apt'         : 'docker-compose-v2',
            'xbps-install': 'docker-compose',
        },
    },)
    #with bootstrapped(dependencies={'dockerfile_parse': 'dockerfile_parse'}):
    #with bootstrapped(dependencies={ 'python_on_whales': 'python-on-whales', }): # also dockerfile_parse
    dockerize()
    assert is_docker()

