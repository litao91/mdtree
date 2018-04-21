import sqlite3
import time
import logging
import os
logger = logging.getLogger(__name__)

class Category(object):
    def __init__(self, uuid, name):
        self.name = name
        self.uuid = uuid


class Article(object):
    def __init__(self, uuid, title):
        self.title = title
        self.uuid = uuid


class MainLib(object):
    def __init__(self, db_file):
        self.db_file = db_file
        self.docs_dir = os.path.join(os.path.dirname(db_file), 'docs')

    def categories(self):
        with sqlite3.connect(self.db_file) as conn:
            results = conn.execute("SELECT uuid, name FROM cat where pid='0'")
            return [Category(i[0], i[1]) for i in results]

    def get_article_title(self, uuid):
        doc_file = os.path.join(self.docs_dir, str(uuid) + '.md')
        try:
            with open(doc_file, encoding='utf-8') as f:
                first_line = f.readline()
                return first_line.strip(' ').strip('#').strip(' ').strip('\n')
        except:
            return 'None'

    def categories_str(self):
        return [c.name for c in self.categories()]

    def sub_cat(self, cat_uuid):
        with sqlite3.connect(self.db_file) as conn:
            results = conn.execute("SELECT uuid, name FROM cat WHERE pid=?",
                                  (cat_uuid,))
            return [Category(i[0], i[1]) for i in results]

    def articles(self, cat_uuid):
        with sqlite3.connect(self.db_file) as conn:
            results = conn.execute(
                """
                SELECT article.uuid FROM cat
                LEFT JOIN cat_article ON cat.uuid = cat_article.rid
                LEFT JOIN article on cat_article.aid = article.uuid
                WHERE cat.uuid = ?;
                """, (cat_uuid,))
            return [Article(i[0],
                            self.get_article_title(i[0])) for i in results]

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
