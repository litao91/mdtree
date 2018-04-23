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
    def __init__(self, uuid, docs_dir, title=None):
        self.uuid = uuid
        self.path = os.path.join(docs_dir, str(uuid) + '.md')
        try:
            if os.path.exists(self.path):
                with open(self.path, encoding='utf-8') as f:
                    first_line = f.readline()
                    self.title = first_line.strip(
                        ' ').strip('#').strip(' ').strip('\n')
            else:
                with open(self.path, 'a', encoding='utf-8') as f:
                    f.write('# ' + title + '\n')
                self.title = title
        except:
            self.title = 'None'


class MainLib(object):
    def __init__(self, db_file):
        self.db_file = db_file
        self.docs_dir = os.path.join(os.path.dirname(db_file), 'docs')

    def categories(self):
        with sqlite3.connect(self.db_file) as conn:
            results = conn.execute("SELECT uuid, name FROM cat where pid='0'")
            return [Category(i[0], i[1]) for i in results]

    def categories_str(self):
        return [c.name for c in self.categories()]

    def sub_cat(self, cat_uuid):
        with sqlite3.connect(self.db_file) as conn:
            results = conn.execute("SELECT uuid, name FROM cat WHERE pid=?",
                                  (cat_uuid,))
            return [Category(i[0], i[1]) for i in results if i[0] is not None]

    def articles(self, cat_uuid):
        with sqlite3.connect(self.db_file) as conn:
            results = conn.execute(
                """
                SELECT article.uuid FROM cat
                LEFT JOIN cat_article ON cat.uuid = cat_article.rid
                LEFT JOIN article on cat_article.aid = article.uuid
                WHERE cat.uuid = ?;
                """, (cat_uuid,))
            return [Article(i[0], self.docs_dir) for i in results
                    if i[0] is not None]

    def add_cat(self, pid, cat_name):
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
                 (?,?,?,'',12,1,0,'','',0,'','','','',0,0,'','','','','','',
                '','','',0,0)
                """, (pid, uuid, cat_name))
            conn.commit()
            return uuid
        except:
            logger.exception("ERROR")
            conn.rollback()
        finally:
            conn.close()

    def add_article(self, pid, title):
        conn = sqlite3.connect(self.db_file)
        uuid = int(time.time() * 10000)
        now = int(time.time())
        try:
            c = conn.cursor()
            c.execute(
                """
        INSERT INTO article(
                uuid,
                "type",
                state,
                sort,
                dateAdd,
                dateModif,
                dateArt,
                docName,
                otherMedia,
                buildResource,
                postExtValue)
            VALUES
                (?, 0, 1, ?, ?, ?, ?, '', '', '', '');
                """, (uuid, uuid, now, now, now))
            c.execute(
                "INSERT INTO cat_article(rid, aid)VALUES(?, ?);", (pid, uuid))
            conn.commit()
            return Article(uuid, self.docs_dir, title)
        except:
            logger.excption("Error")
            conn.rollback()
        finally:
            conn.close()
