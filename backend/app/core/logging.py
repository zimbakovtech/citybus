"""Structured, leveled logging setup shared by the app and scripts."""

import logging
import sys

FORMAT = "%(asctime)s %(levelname)-8s %(name)s: %(message)s"


def configure_logging(level: int = logging.INFO) -> None:
    logging.basicConfig(level=level, format=FORMAT, stream=sys.stdout)
    # uvicorn installs its own handlers; keep third-party noise down
    logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)
