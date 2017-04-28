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

(: 
 $update => biblio, ddb, hgv, dclp or repo for all
 $list => separated list of items that need to be updated or empty for all files
 :)
declare function local:update($update as xs:string?, $list as xs:string?) as node() {
    <p>
        <span>[Update {$update} | List {$list}]</span>
        <ul>
        {
            if($update = 'biblio')then(
                local:updateBiblio($list)
            )else(
                if($update = 'hgv')then(
                    local:updateHgv($list)
                )else(
                    if($update = 'ddb')then(
                        local:updateDdb($list)
                    )else(
                        if($update = 'dclp')then(
                            local:updateDclp($list)
                        )else(
                            local:updateBiblio($list), local:updateHgv($list), local:updateDdb($list), local:updateDclp($list)
                        )
                    )
                )
            )
        }
        </ul>
    </p>
};

declare function local:updateBiblio($list as xs:string?) as node(){
    <li>Biblio
        {local:handleTmLikes('Biblio', $list, '')}
    </li>
};

declare function local:updateHgv($list as xs:string?) as node(){
    <li>HGV
        {local:handleTmLikes('HGV_meta_EpiDoc', $list, 'HGV')}
    </li>
};

declare function local:updateDclp($list as xs:string?) as node(){
    <li>DCLP
        {local:handleTmLikes('DCLP', $list, '')}
    </li>
};

declare function local:handleTmLikes($folder, $list as xs:string?, $prefix as xs:string?) as node(){
    <ul>
    {
        for $item in tokenize($list, $SEPARATOR)
            let $action := local:getAction($item)
            let $id := local:getId($item)
            let $filepath := concat($folder, '/', $prefix,papy:getFolder1000(number(replace($id, '[^\d]', ''))))
            let $filename := concat($id, '.xml')
            let $source := concat($SOURCE_REPOSITORY, '/', $filepath)
            let $destination := concat($REPOSITORY, '/', $filepath)
            let $result := if($action = 'delete')then(local:delete($destination, $filename))else(local:update($destination, $source, $filename))
            return <li>{ $action } { ' ' } { concat($source, '/', $filename) } → {$destination} [{$result}]</li>
    }
    </ul>
};


(:
  <idno type="filename">cpr.17A.AnhangA</idno>
:)
declare function local:handleComplicatedStuff($folder, $list as xs:string?) as node(){
    <ul>
    {
        for $item in tokenize($list, $SEPARATOR)
            let $action := local:getAction($item)
            let $id := local:getId($item)
            let $filename := concat($id, '.xml')

            let $searchPath := concat($REPOSITORY, '/', $folder, '?select=*.xml;recurse=yes')
            let $epiDocFile := document-uri(collection($searchPath)[string(.//tei:idno['filename'][1]) = $id])
            let $destination := replace($epiDocFile, concat('/', $filename), '')
            let $source := replace($destination, $REPOSITORY, $SOURCE_REPOSITORY)
            let $result := if($action = 'delete')then(local:delete($destination, $filename))else(local:update($destination, $source, $filename))
            return <li>{ $action } { ' ' } { concat($source, '/', $filename) } → {$destination} [{$result}]</li>
    }
    </ul>
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

declare function local:updateDdb($list as xs:string?) as node(){
    <li>
        DDB
        {local:handleComplicatedStuff('DDB_EpiDoc_XML', $list)}

        <!-- 1 Stufe
        chr.wilck/chr.wilck.11.xml

        2 Stufen
        cpr/cpr.17A/cpr.17A.13rpdupl.xml

        Problematisch
        c.pap.gr/c.pap.gr.2.1/c.pap.gr.2.1.25.xml
        c.pap.gr/c.pap.gr.2.1/c.pap.gr.2.1.5brpdupl.xml
        c.pap.gr/cpr.17A/cpr.17A.AnhangA.xml (oder das Hinterste immer) -->
    </li>
};

<html>
    <head>
        <title>IDP.DATA</title>
        <link rel="stylesheet" type="text/css" href="../resources/css/jquery/dark-hive/jquery-ui-1.8.17.custom.css" />
        <script type="text/javascript" src="../resources/js/jquery/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="../resources/js/jquery/jquery-ui-1.8.17.custom.min.js"></script>
    </head>
    <body>
        <h3>idp.data</h3>
        <form method="get">
            <input type="text" name="list" value="{request:get-parameter('list', '1,2,3')}"/>
            <button type="submit" name="update" value="biblio">Biblio</button>
            <button type="submit" name="update" value="dclp">DCLP</button>
            <button type="submit" name="update" value="ddb">DDB</button>
            <button type="submit" name="update" value="hgv">HGV</button>
            <!--button type="submit" name="update" value="repo">all</button-->
        </form>
        (Not implemented yet: APIS, Translations)
        { if(request:get-parameter('update', ()))then(local:update(request:get-parameter('update', ()), request:get-parameter('list', ())))else() }
    </body>
</html>