import logging

# import chromalog
# chromalog.basicConfig(format="%(message)s")
# TODO: colored logs have advantages, but this lib has trouble with
#       parsing / formatting of constructs like "%010x"

logger: logging.Logger = logging.getLogger("Receiver")
logger.setLevel(logging.INFO)
logger.addHandler(logging.NullHandler())
