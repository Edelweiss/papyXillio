# papyXillio

papyrillio application for eXist-db
implements functionality used by the DCLP SoSOL editor, such as autocompletion and preview features

## Setup

* install eXist-db and run

http://exist-db.org/exist/apps/homepage/index.html

* create application papyrillio and therein a module called idp.data
* add the sources of this repository to /db/apps/papyrillio
* create folder /db/apps/papyrillio/data/idp.data/dclp, dclp being a clone of the dclp branch of idp.data so there should be dclp/DCLP and dclp/Biblio (perhaps some kind of soft or hard link might work here)

Start local server on port 8080 to get a list of available queries (see top menu, /Home/etc.)

http://localhost:8080/exist/apps/papyrillio/index.html

queries are performed on idp.data, the data.folder itself is ignored and can be retrieved from one the idp.data repositories, the path should be

/data/idp.data/dclp/DCLP
/data/idp.data/dclp/Biblio

## Hints

mount server directory via WebDav (e.g. http://localhost:8080/exist/webdav/db/) to edit your project files in a convenient editor, such as TextWrangler or Oxygen