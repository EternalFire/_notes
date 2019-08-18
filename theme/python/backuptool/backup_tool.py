# -*- coding: utf-8 -*-

import schedule
import zipfile
import time, os, sys
from multiprocessing import Process
import logging
from logging.handlers import RotatingFileHandler

output_path__ = "out"

##################################################
# logger
logger = logging.getLogger(__name__)
logger.setLevel(level=logging.DEBUG)

formatter = logging.Formatter("%(asctime)s | %(name)s | %(process)d | %(levelname)s | %(funcName)s | %(lineno)d | %(message)s")

# StreamHandler
stream_handler = logging.StreamHandler(sys.stdout)
stream_handler.setLevel(level=logging.DEBUG)
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)

# RotatingFileHandler
rotating_file_handler = RotatingFileHandler("output.log", maxBytes=1024*512, backupCount=3, encoding="utf-8")
rotating_file_handler.setLevel(level=logging.INFO)
rotating_file_handler.setFormatter(formatter)
logger.addHandler(rotating_file_handler)
##################################################

def getCurTimeString():
    """ %Y%m%d_%H%M%S """
    return time.strftime("%Y%m%d_%H%M%S", time.localtime())


def getFileExt(filePath):
    """ "b/a.png" => ".png" """
    return os.path.splitext(filePath)[1]


def getFileName(filePath):
    ext = getFileExt(filePath)
    return os.path.basename(filePath).split(ext)[0]


def addToZip(zf, path, zippath):
    if os.path.isfile(path):
        zf.write(path, zippath, zipfile.ZIP_DEFLATED)
    elif os.path.isdir(path):
        if zippath:
            zf.write(path, zippath)
        for nm in sorted(os.listdir(path)):
            addToZip(zf, os.path.join(path, nm), os.path.join(zippath, nm))


def backup_file(path, _archive_name=""):
    name = _archive_name
    file_name = ""

    if os.path.isfile(path):
        # print("isfile")
        file_name = getFileName(path)
    elif os.path.isdir(path):
        # print("isdir")
        file_name = os.path.basename(path)

    if file_name == "":
        file_name = "archive"

    if _archive_name == "":
        name = file_name

    s_time = getCurTimeString()
    archive_name = "%s_%s.zip" % (name, s_time)
    archive_path = os.path.abspath(os.path.join(output_path__, archive_name))
    exists_archive_path = os.path.exists(archive_path)
    logger.info(archive_path)

    if exists_archive_path:
        os.remove(archive_path)
        logger.warning("remove exist file [%s]", archive_path)

    t0 = time.time()
    with zipfile.ZipFile(archive_path, 'w') as file:
        # addToZip(file, path, name)
        addToZip(file, path, file_name)

    t1 = time.time()
    size = os.path.getsize(archive_path)
    logger.info("[%s] is created.", archive_name)
    logger.info("time used: %.4f s", (t1 - t0))
    logger.info("size: %s B/ %.3f MB", size, size / 1024 / 1024)

    # print("check archive ...")
    # with zipfile.ZipFile(archive_path, 'r') as file:
    #     print(file.namelist())
    return


def work(t, _path):
    def job():
        pid = os.getpid()
        # print(pid, "working")
        logger.debug("working")
        backup_file(_path)
        return

    schedule.every(t).seconds.do(job)
    schedule.run_all(1)

    while True:
        schedule.run_pending()
        time.sleep(1)


if __name__ == "__main__":
    logger.info("\n\n[%s] program start!!!", os.getpid())

    if len(sys.argv) > 1:
        try:
            sec = int(sys.argv[1])
        except ValueError:
            sec = 60 * 10

        sec = max(sec, 10)
        logger.info("schedule time = %s", sec)
        backup_paths = sys.argv[2:]
        process_list = []

        if not os.path.exists(output_path__):
            os.mkdir(output_path__)

        try:
            path_set = set()

            for path in backup_paths:
                abs_path = os.path.abspath(path)
                exists = os.path.exists(abs_path)
                if exists:
                    path_set.add(path)
                else:
                    logger.warning("Not exist: [%s]", abs_path)

            logger.info("len of path: %s", len(path_set))

            if len(path_set) > 0:
                logger.debug("Parent process [%s]." % os.getpid())

                for path in path_set:
                    logger.info("to backup [%s]", path)

                    p = Process(target=work, args=(sec, path,))
                    process_list.append(p)
                    p.start()

                    logger.info("Process [%s] start", p.pid)

                logger.info("[%s] program work ...", os.getpid())

                while True:
                    time.sleep(1)

        except KeyboardInterrupt:
            logger.exception("error[KeyboardInterrupt]")
        except BaseException:
            logger.exception("error[BaseException]")
        finally:
            for p in process_list:
                logger.info("Process [%s] terminate" % p.pid)
                p.terminate()

    else:
        logger.info("enter schedule time(seconds)")
        logger.info("enter path to backup")
        logger.info("example: python backup_tool.py 30 pathA pathB")

    logger.info("\n[%s] program end!", os.getpid())
