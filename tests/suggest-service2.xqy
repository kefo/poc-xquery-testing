xquery version "1.0";

(:
    Tests the suggest 2.0 service
:)
 
import module namespace test="http://marklogic.com/roxy/test-helper" at "../modules/test-helper.xqy";


declare namespace xdmp = "http://marklogic.com/xdmp";
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs          = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace madsrdf       = "http://www.loc.gov/mads/rdf/v1#";
declare namespace skos          = "http://www.w3.org/2004/02/skos/core#";
declare namespace lcc           = "http://id.loc.gov/ontologies/lcc#";
declare namespace js            = "http://marklogic.com/xdmp/json/basic" ;
                               
declare default element namespace    "http://marklogic.com/xdmp/json/basic";
(:let $local-base:= fn:concat($BASE_URL):)

declare variable $BASE_URL external := "https://id.loc.gov";

let $uri-vocab := fn:concat($BASE_URL, "/vocabulary/relators/suggest2/?count=50&amp;q=author&amp;mime=xml")
let $results-vocab := test:http-get($uri-vocab)
let $results-vocab-xml:=$results-vocab[2]/child::*[fn:name()] 
let $results-vocab-uri:=$results-vocab-xml//hits/hit[1]/uri
let $results-vocab-label:=$results-vocab-xml//hits/hit[1]/aLabel

let $uri-subjects := fn:concat($BASE_URL, "/authorities/subjects/suggest2/?q=bird%20watching&amp;mime=xml")
let $results-subjects := test:http-get($uri-subjects)
let $results-subjects-xml :=   $results-subjects[2]/node() 

let $uri-names := fn:concat($BASE_URL, "/authorities/names/suggest2/?q=twain,%20mark&amp;mime=xml")
let $results-names := test:http-get($uri-names)
let $results-names-xml :=  $results-names[2]

let $uri-works := fn:concat($BASE_URL, "/resources/works/suggest2/?q=twain,%20mark&amp;mime=xml")
let $results-works := test:http-get($uri-works)
let $results-works-xml := $results-works[2]


(:let $uri-instances := fn:concat($BASE_URL, "/resources/instances/suggest2/?q=twain,%20mark,%201835-1910,%20The%20pu&amp;mime=xml"):)
let $uri-instances := fn:concat($BASE_URL, "/resources/instances/suggest2/?q=Kittens%20in%203-d&amp;mime=xml")
let $results-instances := test:http-get($uri-instances)
let $results-instances-xml :=$results-instances[2]

let $uri-hubs := fn:concat($BASE_URL, "/resources/hubs/suggest2/?q=twain,%20mark&amp;mime=xml")
let $results-hubs := test:http-get($uri-hubs)
let $results-hubs-xml := $results-hubs[2]

(: suggest 2 new: untested tests :)
let $uri-variants := fn:concat($BASE_URL, "/authorities/subjects/suggest2/?q=Gun%20dog&amp;mime=xml")
let $results-variants := test:http-get($uri-variants)
let $results-variants-xml := $results-variants[2]

(:    * token search works, finds n2009017420 first :)
let $tokens-uri := fn:concat($BASE_URL, "/authorities/names/suggest2?q=n200901742&amp;mime=xml")
let $tokens-results := test:http-get($tokens-uri)
let $tokens-results-xml := $tokens-results[2]

(:    * code search works :)
let $code-uri := fn:concat($BASE_URL, "/entities/roles/suggest2?q=sng&amp;mime=xml")
let $code-results := test:http-get($code-uri)
let $code-results-xml := $code-results[2]
(:square bracket doesn't break things 
    /suggest2?q=sng,%20t.%20[T
 finds 	"http://id.loc.gov/entities/providers/674833871d11b7492dd9d6bc7f3c5bf9":)
let $regex-uri := fn:concat($BASE_URL, "/suggest2?q=sng,%20t.%20[T&amp;mime=xml")
let $regex-results := test:http-get($regex-uri)
let $regex-results-xml := $regex-results[2]

(:    * rdftype search works :)
let $rdftype-uri := fn:concat($BASE_URL, "/authorities/names/suggest2?q=Twain&amp;rdftype=CorporateName&amp;mime=xml")
let $rdftype-results := test:http-get($rdftype-uri)
let $rdftype-results-xml := $rdftype-results[2]


    
(: memberof:)
let $memberof-uri := fn:concat($BASE_URL, "/suggest2?mime=xml&amp;memberOf=http://id.loc.gov/vocabulary/graphicMaterials/collection_graphicMaterials&amp;q=air")
let $memberof-results := test:http-get($memberof-uri)
let $memberof-results-xml :=$memberof-results[2] 
(: multiple memberof:)
let $membersof-uri := fn:concat($BASE_URL, "/suggest2?q=history&amp;memberOfURI=http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1156&amp;memberOf=http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1160&amp;mime=xml")
let $membersof-results := test:http-get($membersof-uri)
let $membersof-results-xml := $membersof-results[2]

(: collection:)
let $collection-uri := fn:concat($BASE_URL, "/resources/instances/suggest2?q=Portales%20D%C3%A1vila&amp;collection=/processing/load_resources/2021-08-09/&amp;mime=xml")
let $collection-results := test:http-get($collection-uri)
let $collection-results-xml := $collection-results[2]

(:    * keyword search works :)
(:http://id.loc.gov/authorities/childrensSubjects/sj2021059754:)

let $keyword-uri := fn:concat($BASE_URL, "/authorities/childrensSubjects/suggest2?q=Intifada&amp;searchtype=keyword&amp;mime=xml")
let $keyword-results := test:http-get($keyword-uri)
let $keyword-results-xml := $keyword-results[2]
(: deprecated/use instead has uri, not label https://preprod-8287.id.loc.gov/authorities/subjects/sh2008025556.rdf
    https://preprod-8287.id.loc.gov/suggest2?q=test%20pressing&mime=xml
    http://id.loc.gov/authorities/genreForms/gf2011026687:)
let $instead-uri := fn:concat($BASE_URL, "/suggest2?q=test%20pressing&amp;mime=xml")
let $instead-results := test:http-get($instead-uri)
let $instead-results-xml := $instead-results[2]

(:    * diacritic should be insensitive, find n87897445 this is faked because the collation is codepoint on alabel, vlabel for now  :)
let $diac-uri := fn:concat($BASE_URL, "/authorities/names/suggest2?q=Jose&amp;rdftype=PersonalName&amp;mime=xml")
let $diac-results := test:http-get($diac-uri)
let $diac-results-xml := $diac-results[2]
(:   multiple qs ignore all but first q and find :	"http://id.loc.gov/authorities/names/nr2004022158":)
let $multiq-uri := fn:concat($BASE_URL, "/authorities/names/suggest2?q=anthology&amp;q=time&amp;mime=xml")
let $multiq-results := test:http-get($multiq-uri)
let $multiq-results-xml := $multiq-results[2]
(:
deprecated (should only have a variant label)            https://preprod-8287.id.loc.gov/authorities/subjects/sh89001270.rdf
:)
let $depr-uri := fn:concat($BASE_URL, "/authorities/subjects/suggest2?q=Twain,%20Mark,%201835-1910--Characters--Huckleberry%20Finn&amp;mime=xml")
let $depr-results := test:http-get($depr-uri)
let $depr-results-xml := $depr-results[2]

(:
deduping (should only have ONE uri for laq, tho it is found as code, label  )  https://preprod-8287.id.loc.gov/vocabulary/mmaterial/suggest2?q=lac
:)
let $dedup-uri := fn:concat($BASE_URL, "/vocabulary/mmaterial/suggest2?q=lac&amp;mime=xml")
let $dedup-results := test:http-get($dedup-uri)
let $dedup-results-xml := $dedup-results[2]

(:
lcsh query should not find Untraced records like "Chicano ..."
:)
let $untraced-uri := fn:concat($BASE_URL, "/authorities/subjects/suggest2/?mime=xml&amp;q=Chicano .")
let $untraced-results := test:http-get($untraced-uri)
let $untraced-results-xml := $untraced-results[2]

let $untraced-keyword-uri := fn:concat($BASE_URL, "/authorities/subjects/suggest2/?mime=xml&amp;searchtype=keyword&amp;q=Chicano .")
let $untraced-keyword-results := test:http-get($untraced-keyword-uri)
let $untraced-keyword-results-xml := $untraced-keyword-results[2]

(:2022-12-16 alabel cts:reference collation is now codepoint; if it's en/s1, this is not the first result :)
let $unicode-collation-uri := fn:concat($BASE_URL,
                            "/authorities/names/suggest2/?mime=xml&amp;q=Soviet%20Union.%20Sovetskai%EF%B8%A0a%EF%B8%A1%20Armii%EF%B8%A0a%EF%B8%A1"
                            )
let $unicode-collation-results := test:http-get($unicode-collation-uri)
let $unicode-collation-results-xml := $unicode-collation-results[2]

(: xml results:)

        let $rwo-uri:=fn:concat($BASE_URL,"/rwo/agents/suggest2?q=Twain,%20Mark,%201835-1910%20(Spirit)&amp;mime=xml")
        let $rwo-result:=test:http-get($rwo-uri)
        let $rwo-result-xml:= $rwo-result[2]
        
        let $highcount-uri:=fn:concat($BASE_URL,"/suggest2?q=twain&amp;count=11999&amp;mime=xml")
        let $highcount-result:=test:http-get($rwo-uri)
        let $highcount-result-xml:=$highcount-result[2]
        
        let $badcount-uri:=fn:concat($BASE_URL,"/suggest2?q=twain&amp;count=abc&amp;mime=xml")
        let $badcount-result:=test:http-get($badcount-uri)
        let $badcount-result-xml:= $badcount-result[2]
(: class excluded :)
        let $noclass-uri:=fn:concat($BASE_URL,"/suggest2?q=Fine%20Arts&amp;rdftype=ClassNumber")
        let $noclass-result:=test:http-get($noclass-uri)
        let $noclass-result-xml:= $noclass-result[2]
        let $noclass-result-uris:=for $x in $badcount-result-xml//uri 
                                    return    
                                        if(fn:contains(fn:string($x),"/classification/")) then 
                                            fn:true() 
                                        else ()
        let $class-found :=if  ( $noclass-result-uris) then fn:true() else fn:false()                                      
        
 

return 
    ( 
        
        test:assert-true(
            200 eq fn:data($results-vocab[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $uri-vocab, " got: ", $results-vocab[1]/*:code/text() )
        ),
     (:  test:assert-true(
            $results-vocab[2]//*:json//*:hits/*:hit[1]/*:aLabel/text() eq 'Author', 
            fn:concat("Did not get the xml result of 'Author' got: ",fn:string(  $results-vocab[2]/node()/descendant-or-self::*:json//*:hits/*:hit[1]/*:aLabel))
        ),        
        test:assert-true(
            $results-vocab-xml//hit[1]/uri eq "http://id.loc.gov/vocabulary/relators/aut", 
            fn:concat("Did not get the xml result of http://id.loc.gov/vocabulary/relators/aut got: ",fn:string($results-vocab-uri))
        ),:)
        test:assert-true(
            200 eq fn:data($results-subjects[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $uri-subjects , " got: ", $results-subjects[1]/*:code/text() ) 
        ),
        
        test:assert-true(
            $results-subjects-xml//hit[1]/aLabel/fn:string() eq 'Bird watching', 
            fn:concat("Did not get the xml result of 'Bird watching', got: ",  $results-subjects[2]/descendant::hit[1] )
        ),        
        test:assert-true(
          $results-subjects-xml//hit[1]/uri eq 'http://id.loc.gov/authorities/subjects/sh85014305', 
            fn:concat("Did not get the xml result of 'http://id.loc.gov/authorities/subjects/sh85014305' got: ", $results-subjects-xml//hit[1]/uri)
        ),
        test:assert-true(
            200 eq fn:data($results-names[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $uri-names)
        ),
        test:assert-true(
            $results-names-xml//hit[1]/aLabel eq 'Twain, Mark, 1835-1910', 
            fn:concat("Did not get the xml result of 'Twain, Mark, 1835-1910' got: ", $results-names-xml//hit[1]/aLabel)
        ),        
        test:assert-true(
          $results-names-xml//hit[1]/uri eq 'http://id.loc.gov/authorities/names/n79021164', 
            fn:concat("Did not get the xml resultof 'http://id.loc.gov/authorities/names/n79021164' got: ",  $results-names-xml//hit[1]/uri )
        ),
        test:assert-true(
            200 eq fn:data($results-works[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $uri-works)
        ),
        (:xdmp:log("10 hits?","info"),:)
        
        test:assert-true(
            fn:count($results-works-xml//hit/aLabel) eq 10,
            fn:concat("Did not get 10 hit/aLabel paths in the xml result. Got: ", $results-works-xml )
        ),        
        test:assert-true(
            fn:count($results-works-xml//hit/uri) eq 10,
            fn:concat("Did not get the10 hit/uri paths in the xml result. Got: ", $results-works-xml )
        ),
        
        test:assert-true(
            200 eq fn:data($results-instances[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $uri-instances)
        ),
        test:assert-true(
            $results-instances-xml//hit[1]/aLabel/text() eq 'Kittens in 3-d ', 
            fn:concat("Did not get the xml result of 'Kittens in 3-d ' got: ", 
            $results-instances-xml//hit[1]/aLabel/text() )
        ),        
        test:assert-true(
            $results-instances-xml//hit[1]/uri eq 'http://id.loc.gov/resources/instances/16616036', 
            fn:concat("Did not get the xml result of 'http://id.loc.gov/resources/instances/16616036' got: ", $results-instances-xml//hit[1]//uri)
        ),                   
        test:assert-true(
            200 eq fn:data($results-hubs[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $uri-hubs)
        ),
        test:assert-true(
           $results-hubs-xml//hit[1]/aLabel/text() eq 'Twain, Mark, 1835-1910 $30,000 bequest and other stories', 
            fn:concat("Did not get the xml result of 'Twain, Mark, 1835-1910 $30,000 bequest and other stories' got: ",$results-hubs-xml//hit[1]/aLabel/text())
        ),        
        test:assert-true(
            (:$results-hubs-xml//hit[1]/uri eq 'http://id.loc.gov/resources/hubs/3c95eee0-fe10-699f-8c27-dfbe93204824',:) 
            $results-hubs-xml//hit[1]/uri eq 'http://id.loc.gov/resources/hubs/3b788546-c220-6e43-119b-34f249ff4256',
                                                                    
            fn:concat("Did not get the xml result of 'http://id.loc.gov/resources/hubs/3b788546-c220-6e43-119b-34f249ff4256' got: ", $results-hubs-xml//hit[1]/uri)
        )   
        
(: new test in xml suggest2:)
        ,
        test:assert-true(
            200 eq fn:data($rwo-result[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $rwo-uri)
        ),
        test:assert-true(
            count($rwo-result-xml//hit) ge 1, 
            fn:concat("Failed at least one for : ", $rwo-uri)
        ) 
        ,
        test:assert-true(
            200 eq fn:data($highcount-result[1]/*:code), 
            fn:concat("Failed get a 200 for: ",$highcount-uri)
        ),
        test:assert-true(
            count($highcount-result-xml//hit) ne 1000, 
            fn:concat("Failed count reset to 1000  for : ", $highcount-uri)
        )
          ,
        test:assert-true(
            200 eq fn:data($badcount-result[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $badcount-uri)
        ),
        test:assert-true(
            count($badcount-result-xml//hit) ne 1000, 
            fn:concat("Failed count reset to 1000  for : ",  $badcount-uri)
        )
         ,
        test:assert-true(
            $class-found eq fn:false() , 
            fn:concat("Incorrectly found classification results for :  ", $noclass-uri)
        ),
        test:assert-true(
            200 eq fn:data($results-variants[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $uri-variants)
        ),
        test:assert-true(
            $results-variants-xml//hit[1]/suggestLabel/text() eq 'Gun dogs (USE Hunting dogs)', 
            fn:concat("Did not get the  variant xml result of 'Gun dogs (USE Hunting dogs)' got: ", $results-variants-xml//hit[1]/suggestLabel/text())
        ),        
        test:assert-true(
            $results-variants-xml//hit[1]/uri eq 'http://id.loc.gov/authorities/subjects/sh85063136', 
            fn:concat("Did not get the variant xml result of 'http://id.loc.gov/authorities/subjects/sh85063136' got: ",  $results-variants-xml//hit[1]/uri)
        ) 
        ,  test:assert-true(
            200 eq fn:data($rdftype-results[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $rdftype-uri)
        ), (: rdftype :)
        test:assert-true(
            $rdftype-results-xml//hit[1]/aLabel/text() eq 'Mark Twain Media', 
            fn:concat("Did not get the rdftype xml result of 'Mark Twain Media' got: ", $rdftype-results-xml//hit[1]/aLabel/text())
        )
        ,  
           test:assert-true(
            $rdftype-results-xml//rdftype/text() eq 'CorporateName', 
            fn:concat("Did not get the rdftype 'CorporateName' got: ", $rdftype-results-xml//rdftype/text() )
        )
        ,(: idx:memberof:)
           test:assert-true(            
            fn:string($memberof-results-xml//hit[1]/uri) eq 'http://id.loc.gov/vocabulary/graphicMaterials/tgm000157', 
            fn:concat("Did not get the memberOf uri  'http://id.loc.gov/vocabulary/graphicMaterials/tgm000157' got: ", fn:string( $memberof-results-xml//hit[1]/uri)  )
            )
     
        ,(: multiple membersof:)
           test:assert-true(
            $membersof-results-xml//hit[1]/uri eq 'http://id.loc.gov/authorities/subjects/sh99001187', 
            fn:concat("Did not get the membersof  uri  'http://id.loc.gov/authorities/subjects/sh99001187' got: ", $membersof-results-xml//hit[1]/uri/text() )
        )

         , (: ml collection :)
           test:assert-true(
            $collection-results-xml//hit[1]/uri eq 'http://id.loc.gov/resources/instances/17916400', 
            fn:concat("Did not get the collection uri 'http://id.loc.gov/resources/instances/17916400' got: ", $collection-results-xml//rdftype/text() )
        )
         , (: count variable is returned :)
           test:assert-true(
            $collection-results-xml//count eq '1', 
            fn:concat("Did not get the collection count  '1' got: ", $collection-results-xml//count/text() )
        )  (: keyword search  :)

    ,       test:assert-true(
            $keyword-results-xml//hit[1]/uri eq 'http://id.loc.gov/authorities/childrensSubjects/sj2021059754', 
            fn:concat("Did not get the childrens uri   'http://id.loc.gov/authorities/childrensSubjects/sj2021059754' got: ", $keyword-results-xml//hit[1]/uri/text() )
        )         

        ,(: $instead search  :)
        test:assert-true(
            200 eq fn:data($instead-results[1]/*:code), 
            fn:concat("Failed get a 200 for: ", $instead-uri)
        )
          , 
           test:assert-true(
            $instead-results-xml//hit[1]/uri eq 'http://id.loc.gov/resources/works/12665267', 
            fn:concat("Did not get the collection uri 'http://id.loc.gov/resources/works/12665267' got: ",  $instead-results-xml//hit[1]/uri) 
        )
         , 
           test:assert-true(
            (:$diac-results-xml//hit[1]/uri eq 'http://id.loc.gov/authorities/names/n87897445',:)
           'http://id.loc.gov/authorities/names/n87897445' = $diac-results-xml//hit/uri/string(),
            fn:concat("Did not get the diacritic uri   'http://id.loc.gov/authorities/names/n87897445' got: ",  $diac-results-xml//hit[1]/uri) 
        ), 
           test:assert-true(
            $tokens-results-xml//hit[1]/uri eq 'http://id.loc.gov/authorities/names/n2009017420', 
            fn:concat("Did not get the token uri 'http://id.loc.gov/authorities/names/n2009017420' got: ",  $tokens-results-xml//hit[1]/uri) 
        )
        , 
           test:assert-true(
            $multiq-results-xml//hit[1]/uri eq 'http://id.loc.gov/authorities/names/nr2004022158', 
            fn:concat("Did not get the multiquery uri 'http://id.loc.gov/authorities/names/nr2004022158' got: ",  $multiq-results-xml//hit[1]/uri) 
        )
        , 
           test:assert-true(
            $depr-results-xml//hit[1]/uri eq 'http://id.loc.gov/authorities/subjects/sh89001270', 
            fn:concat("Did not get the deprecated uri 'http://id.loc.gov/authorities/subjects/sh89001270' got: ",  $depr-results-xml//hit[1]/uri) 
        )
        ,
           test:assert-true(
            contains($depr-results-xml//hit[1]/suggestLabel, 'DEPRECATED'), 
            fn:concat("Did not get the deprecated suggest label 'DEPRECATED' got: ",  $depr-results-xml//hit[1]/suggestLabel) 
        )     
        ,
           test:assert-true(
              $dedup-results-xml//count eq '1', 
            fn:concat("Did not get the hit count  '1' got: ",  $dedup-results-xml//count/text() )
        )   
(:        let $code-uri := fn:concat($BASE_URL, "/entities/roles/suggest2?q=sng&amp;mime=xml")
let $code-results := test:http-get($code-uri)
let $code-results-xml := $code-results[2]:)
, 
           test:assert-true(
            $code-results-xml//hit[1]/uri eq 'http://id.loc.gov/entities/roles/sng', 
            fn:concat("Did not get the code uri 'http://id.loc.gov/entities/roles/sng' got: ",  $code-results-xml//hit[1]/uri) 
        ),        
           test:assert-true(
            $regex-results-xml//hit[1]/uri eq 'http://id.loc.gov/entities/providers/674833871d11b7492dd9d6bc7f3c5bf9', 
            fn:concat("Did not get the regex uri 'http://id.loc.gov/entities/providers/674833871d11b7492dd9d6bc7f3c5bf9' got: ",  $regex-results-xml//hit[1]/uri) 
        )
  
        ,
          
           test:assert-true(
            ($untraced-results-xml/count eq '0' or  $untraced-results-xml//hit[1]/uri ne 'http://id.loc.gov/authorities/subjects/sh00003128'), 
            fn:concat("Incorrectly got the untraced uri 'http://id.loc.gov/authorities/subjects/sh00003128' : ",  fn:string( $untraced-results-xml/count)) 
        ),
          test:assert-true(
            ($untraced-keyword-results-xml/count eq '0' or  $untraced-keyword-results-xml//hit[1]/uri ne 'http://id.loc.gov/authorities/subjects/sh00003128'), 
            fn:concat("Incorrectly got the untraced uri 'http://id.loc.gov/authorities/subjects/sh00003128'  in keyword search: ",  fn:string( $untraced-keyword-results-xml/count)) 
        )
(:        , 
           test:assert-true(
            $unicode-collation-results-xml//hit[1]/uri eq 'http://id.loc.gov/authorities/names/n83167516', 
            fn:concat("Did not get the code uri 'http://id.loc.gov/authorities/names/n83167516' got: ",   $unicode-collation-results-xml//hit[1]/uri) 
        )        
:)

    )
