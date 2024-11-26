#! /usr/bin/env python
# cython: language_level=3
# distutils: language=c++

""" docker """

import asyncio
import os
from pathlib                                 import Path
from typing                                  import List, Optional, Iterable

import dotenv
from python_on_whales                        import docker
from structlog                               import get_logger

logger           = get_logger()

##
#
##

def main(srcpath:Optional[Path]=None,)->None:
	assert docker.compose.is_installed()
	dotenv.load_dotenv()

	if (srcpath is None):
		srcpath:Path          = Path()
	assert srcpath.is_dir()
	logger.info('src path: %s', srcpath.resolve(),)

	_name          :str           = srcpath.resolve().name
	logger.debug('_name   : %s', _name,)

	logger.info('building: %s', _name,)
	#docker.compose.build(_name,)
	docker.compose.build(services=None, pull=True,)

	#name                          = str(f'innovanon/{_name}')
	name                          = _name
	logger.debug('name    : %s', name,)

	logger.info('pushing : %s', name,)
	#docker.compose.push(services=[name,],)
	docker.compose.push(services=None,)

	mode           :Optional[str] = os.getenv('IA_DOCKER', None)
	logger.info('mode    : %s', mode,)
	if (mode == 'RUN'):
		logger.info('running')
		docker.compose.run()
	elif (mode == 'UP'):
		logger.info('up')
		docker.compose.up()
	else: assert (mode is None), mode

if __name__ == '__main__':
	main()

__author__:str = 'you.com' # NOQA
