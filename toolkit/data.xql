xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace papy='http://www.papy' at '../modules/papy.xql';

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html5";
declare option output:media-type "text/html";

declare variable $SOURCE_REPOSITORY := '/Users/elemmire/data/idp.data/dclp/development';
declare variable $REPOSITORY := '/data/idp.data/dclp';
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
        <ul>
        {
            for $item in tokenize($list, $SEPARATOR)
                let $filename := concat('/Biblio/', papy:getFolder1000(number($item)),'/', $item, '.xml')
                let $source := concat($SOURCE_REPOSITORY, $filename)
                let $action := if(file:exists($source))then('update')else('delete')
                let $destination := concat($REPOSITORY, $filename)
                return <li>{$source} [{ $action }] → {$destination}</li>
        }
        </ul>
    </li>
};

declare function local:updateHgv($list as xs:string?) as node(){
    <li>
        HGV
    </li>
};

declare function local:updateDdb($list as xs:string?) as node(){
    <li>
        DDB
    </li>
};

declare function local:updateDclp($list as xs:string?) as node(){
    <li>
        DCLP
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

        <a href="?update=biblio&amp;list=1,2,3">Update Biblio</a>
        { ' ' }
        <a href="?update=ddb&amp;list=1,2,3">Update DDB</a>
        { ' ' }
        <a href="?update=hgv&amp;list=1,2,3">Update HGV</a>
        { ' ' }
        <a href="?update=dclp&amp;list=1,2,3">Update DCLP</a>
        { ' ' }
        <a href="?update=repo&amp;list=1,2,3">Update all</a>

        { if(request:get-parameter('update', ()))then(local:update(request:get-parameter('update', ()), request:get-parameter('list', ())))else() }
    </body>
</html>