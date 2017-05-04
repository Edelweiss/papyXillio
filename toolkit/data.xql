xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace papy='http://www.papy' at '../modules/papy.xql';

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option output:method "html5";
declare option output:media-type "text/html";

declare variable $SOURCE_REPOSITORY := '/Users/elemmire/data/idp.data/dclp/development';
declare variable $REPOSITORY := '/db/data/idp.data/dclp';
declare variable $SEPARATOR := ',';
declare variable $DDB_SERIES := file:list(concat($SOURCE_REPOSITORY, '/DDB_EpiDoc_XML'));

(: 
   $folder => Biblio, DCLP, DDB_EpiDoc_XML, HGV_meta_EpiDoc, APIS, HGV_trans_EpiDoc
   $list => separated list of items that need to be updated, preceded by a minus sign if the respective item is to be deleted

   Test Cases for DDB
   c.ep.lat.2, chr.wilck.11, c.pap.gr.2.1.25, c.pap.gr.2.1.5brpdupl, cpr.17A.AnhangA, sosol.2013.0133

   Test Cases for DCLP
   555

   Test Cases for Biblio
   1, 2, 3, 95999

   Test Cases for HGV
   993a

   Test Cases for APIS
   yale.apis.0000010000

   Test Cases for Translations
   p.batav;;34
   9363a
:)
declare function local:processSync($folder, $list as xs:string?) as node(){
    <ul>
    {
        for $item in tokenize($list, $SEPARATOR)
            let $item := normalize-space($item)
            let $action := local:getAction($item)
            let $id := local:getId($item)
            let $filename := concat($id, '.xml')
            let $filepath := local:getFilepath($folder, $id)
            let $source := concat($SOURCE_REPOSITORY, '/', $filepath)
            let $destination := concat($REPOSITORY, '/', $filepath)
            let $result := if($action = 'delete')then(local:delete($destination, $filename))else(local:update($destination, $source, $filename))
            return <li>{ $action } { ' ' } { concat($source, '/', $filename) } → {$destination} [{$result}]</li>
    }
    </ul>
};

declare function local:getFilepath($folder as xs:string, $id as xs:string) as xs:string?{
    if($folder = 'DDB_EpiDoc_XML')then(
        let $series := local:getlongestPath($DDB_SERIES, $id)
        let $volume := local:getlongestPath(file:list(concat($SOURCE_REPOSITORY, '/', $folder, '/', $series)), $id)
        return concat($folder, '/', $series, if(string($volume))then(concat('/', $volume))else(''))
    )else(if($folder = 'APIS')then(
        concat($folder, '/', substring-before($id, '.'), '/xml')
    )else(if($folder = 'HGV_trans_EpiDoc')then(
        $folder
    )else(
        concat($folder, '/', if($folder = 'HGV_meta_EpiDoc')then('HGV')else(''), papy:getFolder1000(number(replace($id, '[^\d]', '')))))))
};

declare function local:getlongestPath($fileList, $id as xs:string?) as xs:string?{
    let $list := $fileList/file:directory[starts-with($id, @name)]/@name (: get matches :)
    let $item := $list[not(string-length(.) < $list/string-length(.))][1] (: get longest, i.e. best match :)
    return $item
};

declare function local:getAction($item as xs:string) as xs:string {
    if(starts-with($item, '-'))then('delete')else('update')
};

declare function local:getId($item as xs:string) as xs:string {
    if(starts-with($item, '-'))then(substring-after($item, '-'))else($item)
};

declare function local:update($destination as xs:string, $source as xs:string, $file as xs:string) as xs:string*{
    if(xmldb:collection-available($destination))then(xmldb:store-files-from-pattern($destination, $source, $file, 'text/xml', true()))else('collection doesn’t exist')
};

(: cl: contrary to what is said in the documentation, xmldb:remove doesn’t return a singular item(); on success it returns nothing :)
declare function local:delete($folder as xs:string, $file as xs:string) as xs:string* {
    if(xmldb:collection-available($folder) and fn:doc-available(concat($folder, '/', $file)))then(xmldb:remove($folder, $file), 'file deleted')else(concat('could not delete file ', $file, ' in folder ', $folder))
};

<html>
    <head>
        <title>IDP.DATA</title>
        <link rel="stylesheet" type="text/css" href="../resources/css/jquery/dark-hive/jquery-ui-1.8.17.custom.css" />
        <script type="text/javascript" src="../resources/js/jquery/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="../resources/js/jquery/jquery-ui-1.8.17.custom.min.js"></script>
    </head>
    <body>
        <h3><a href="data.xql">idp.data sync</a></h3>
        <form method="get" onkeypress="return event.keyCode != 13;">
            <input type="text" name="list" value="{request:get-parameter('list', '')}"/>
            <button type="submit" name="folder" value="Biblio">Biblio</button>
            <button type="submit" name="folder" value="DCLP">DCLP</button>
            <button type="submit" name="folder" value="DDB_EpiDoc_XML">DDB</button>
            <button type="submit" name="folder" value="HGV_meta_EpiDoc">HGV</button>
            <button type="submit" name="folder" value="APIS">APIS</button>
            <button type="submit" name="folder" value="HGV_trans_EpiDoc">Translations</button>
        </form>
        {
            if(request:get-parameter('folder', ()))then(
                <div>
                    <h3>{request:get-parameter('folder', ())}</h3>
                    {local:processSync(request:get-parameter('folder', ()), request:get-parameter('list', ()))}
                </div>
            )else()
        }
    </body>
</html>