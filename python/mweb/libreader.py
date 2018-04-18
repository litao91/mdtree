import sqlite3
import time
import logging
logger = logging.getLogger(__name__)

class Category(object):
    def __init__(self, uuid, name):
        self.name = name
        self.uuid = uuid



class MainLib(object):
    def __init__(self, db_file):
        self.db_file = db_file

    def categories(self):
        with sqlite3.connect(self.db_file) as conn:
            results = conn.execute("SELECT uuid, name FROM cat where pid='0'")
            return [Category(i[0], i[1]) for i in results]

    def categories_str(self):
        return [c.name for c in self.categories()]

    def sub_cat(self, cat):
        with sqlite3.connect(self.db_file) as conn:
            results = conn.execute("SELECT uuid, name FROM cat WHERE pid=?",
                                  (cat.uuid,))
            return [Category(i[0], i[1]) for i in results]

    def add_cat(self, cat_name):
        conn = sqlite3.connect(self.db_file)
        uuid = int(time.time() * 10000)
        try:
            c = conn.cursor()
            c.execute(
                """
                INSERT INTO cat (
                  pid,
                  uuid,
                  name,
                  docName,
                  catType,
                  sort,
                  sortType,
                  siteURL,
                  siteSkinName,
                  siteLastBuildDate,
                  siteBuildPath,
                  siteFavicon,
                  siteLogo,
                  siteDateFormat,
                  sitePageSize,
                  siteListTextNum,
                  siteName,
                  siteDes,
                  siteShareCode,
                  siteHeader,
                  siteOther,
                  siteMainMenuData,
                  siteExtDef,
                  siteExtValue,
                  sitePostExtDef,
                  siteEnableLaTeX,
                  siteEnableChart)
                VALUES
                 (0,?,?,'',12,1,0,'','',0,'','','','',0,0,'','','','','','',
                '','','',0,0)
                """, (uuid, cat_name))
            conn.commit()
            return uuid
        except:
            logger.exception("ERROR")
            conn.rollback()
        finally:
            conn.close()


    def articles(self, cat):
        pass
