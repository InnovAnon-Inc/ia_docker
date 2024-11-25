#! /usr/bin/env python
# cython: language_level=3
# distutils: language=c++

""" docker """

import asyncio
import os
from typing                                  import List, Optional, Iterable

import dotenv
from python_on_whales                        import docker
from structlog                               import get_logger

logger           = get_logger()

##
#
##

def main()->None:
	dotenv.load_dotenv()

	logger.info('building')
	docker.build()

	mode:Optional[str] = os.getenv('IA_DOCKER', None)
	logger.info('mode: %s', mode,)
	if (mode == 'RUN'):
		logger.info('running')
		docker.run()
	elif (mode == 'UP'):
		logger.info('up')
		docker.compose.up()
	else assert (mode is None), mode

if __name__ == '__main__':
	main()

__author__:str = 'you.com' # NOQA
