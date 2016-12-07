xquery version "3.0";

(:
  http://localhost:8080/exist/rest/db/apps/papyrillio/sandbox/helloWorld.xq
:)

declare option exist:serialize "method=text media-type=text/plain";

let $message := 'Hello World!'
return
    <results><message>{$message}</message></results>