xquery version "1.0";

import module namespace test="http://marklogic.com/roxy/test-helper" at "../modules/test-helper.xqy";

declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs          = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace madsrdf       = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   skos                = "http://www.w3.org/2004/02/skos/core#";

declare variable $BASE_URL external := "https://id.loc.gov";

let $uri := fn:concat($BASE_URL, "/authorities/subjects/sh85139805")

let $headers := 
    <options xmlns="xdmp:http">
        <headers>
          <Accept>application/ld+json</Accept>
        </headers>
   </options>
let $rdf := test:http-get( $uri, $headers )
  
return 
    (
        test:assert-true(
            303 eq xs:integer($rdf[1]/@status), 
            fn:concat("HTTP Response code no 302 for: ", $uri)
        ),
        test:assert-true(
            fn:contains(fn:string($rdf[1]/*:header[@name="location"]/@value),'authorities/subjects/sh85139805.jsonld'), 
            fn:concat("Did not locate Location header pointing to .jsonld for: ", $uri)
        ),
        test:assert-true(
            fn:string($rdf[1]/*:header[@name="x-preflabel"]/@value) eq "United States--Armed Forces--African Americans", 
            fn:concat("Did not find X-PrefLabel header for: ", $uri)
        )
    )

