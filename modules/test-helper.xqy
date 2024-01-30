(:
Copyright 2012-2015 MarkLogic Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
:)
xquery version "3.0";

module namespace helper="http://marklogic.com/roxy/test-helper";

declare namespace t="http://marklogic.com/roxy/test";
declare namespace test="http://marklogic.com/roxy/test-helper";
declare namespace ss="http://marklogic.com/xdmp/status/server";
declare namespace xdmp-http="xdmp:http";
declare namespace error = "http://marklogic.com/xdmp/error";

declare namespace web = "http://basex.org/modules/web";

declare namespace err  = "http://www.w3.org/2005/xqt-errors";

declare variable $helper:PREVIOUS_LINE_FILE as xs:string :=
  try {
   fn:error(xs:QName("boom"), "")
  }
  catch * {
    err:*
  };

declare variable $helper:__LINE__ as xs:int :=
  try {
   fn:error(xs:QName("boom"), "")
  }
  catch * {
    err:*
  };

(: declare variable $helper:__CALLER_FILE__  := helper:get-caller() ; :)

(:
declare function helper:get-caller()
  as xs:string
{
  try { fn:error((), "ROXY-BOOM") }
  catch ($ex) {
    if ($ex/error:code ne 'ROXY-BOOM') then xdmp:rethrow()
    else (
      let $uri-list := $ex/error:stack/error:frame/error:uri/fn:string()
      let $this := $uri-list[1]
      return (($uri-list[. ne $this])[1], 'no file')[1])
  }
};
:)

(:~
 : constructs a success xml element
 :)
declare function helper:success() {
  <t:result type="success"/>
};

(:~
 : constructs a failure xml element
 :)
declare function helper:fail($expected as item(), $actual as item()) {
  helper:fail(<oh-nos>Expected {$expected} but got {$actual} at {$helper:PREVIOUS_LINE_FILE}</oh-nos>)
};

(:~
 : constructs a failure xml element
 :)
declare function helper:fail($message as item()*) {
  element t:result {
    attribute type { "fail" },
    typeswitch($message)
      case element(error:error) return $message
      default return
        fn:error(xs:QName("USER-FAIL"), $message)
  }
};

declare function helper:assert-all-exist($count as xs:unsignedInt, $item as item()*) {
  if ($count eq fn:count($item)) then
    helper:success()
  else
    fn:error(xs:QName("ASSERT-ALL-EXIST-FAILED"), "Assert All Exist failed", $item)
};

declare function helper:assert-exists($item as item()*) {
  if (fn:exists($item)) then
    helper:success()
  else
    fn:error(xs:QName("ASSERT-EXISTS-FAILED"), "Assert Exists failed", $item)
};

declare function helper:assert-not-exists($item as item()*) {
  if (fn:not(fn:exists($item))) then
    helper:success()
  else
    fn:error(xs:QName("ASSERT-NOT-EXISTS-FAILED"), "Assert Not Exists failed", $item)
};

declare function helper:assert-at-least-one-equal($expected as item()*, $actual as item()*) {
  if ($expected = $actual) then
    helper:success()
  else
    fn:error(xs:QName("ASSERT-AT-LEAST-ONE-EQUAL-FAILED"), "Assert At Least one Equal failed", ())
};

declare function helper:are-these-equal($expected as item()*, $actual as item()*) {
  if (fn:count($expected) eq fn:count($actual)) then
    fn:count((for $item at $i in $expected
    return
      fn:deep-equal($item, $actual[$i]))[. = fn:true()]) eq fn:count($expected)
  else
    fn:false()
};

(: Return true if and only if the two sequences have the same values, regardless
 : of order. fn:deep-equal() returns false if items are not in the same order. :)
declare function helper:assert-same-values($expected as item()*, $actual as item()*)
{
  let $expected-ordered :=
    for $e in $expected
    order by $e
    return $e
  let $actual-ordered :=
    for $a in $actual
    order by $a
    return $a
  return helper:assert-equal($expected-ordered, $actual-ordered)
};

declare function helper:assert-equal($expected as item()*, $actual as item()*) {
  if (helper:are-these-equal($expected, $actual)) then
    helper:success()
  else
    fn:error(xs:QName("ASSERT-EQUAL-FAILED"), "Assert Equal failed", ($expected, $actual))
};

declare function helper:assert-not-equal($expected as item()*, $actual as item()*) {
  if (fn:not(helper:are-these-equal($expected, $actual))) then
    helper:success()
  else
    fn:error(
      xs:QName("ASSERT-NOT-EQUAL-FAILED"),
      fn:concat("test name", ": Assert Not Equal failed"),
      ($expected, $actual))
};

declare function helper:assert-true($supposed-truths as xs:boolean*) {
  helper:assert-true($supposed-truths, $supposed-truths)
};

declare function helper:assert-true($supposed-truths as xs:boolean*, $msg as item()*) {
  if (fn:false() = $supposed-truths) then
    ( fn:serialize($msg), fn:error(xs:QName("ASSERT-TRUE-FAILED"), "Assert True failed", fn:serialize($msg)) )
  else
    helper:success()
};

declare function helper:assert-false($supposed-falsehoods as xs:boolean*) {
  if (fn:true() = $supposed-falsehoods) then
    fn:error(xs:QName("ASSERT-FALSE-FAILED"), "Assert False failed", $supposed-falsehoods)
  else
    helper:success()
};


declare function helper:assert-meets-minimum-threshold($expected as xs:decimal, $actual as xs:decimal+) {
  if (every $i in 1 to fn:count($actual) satisfies $actual[$i] ge $expected) then
    helper:success()
  else
    fn:error(
      xs:QName("ASSERT-MEETS-MINIMUM-THRESHOLD-FAILED"),
      fn:concat("test name", ": Assert Meets Minimum Threshold failed"),
      ($expected, $actual))
};

declare function helper:assert-meets-maximum-threshold($expected as xs:decimal, $actual as xs:decimal+) {
  if (every $i in 1 to fn:count($actual) satisfies $actual[$i] le $expected) then
    helper:success()
  else
    fn:error(
      xs:QName("ASSERT-MEETS-MAXIMUM-THRESHOLD-FAILED"),
      fn:concat("test name", ": Assert Meets Maximum Threshold failed"),
      ($expected, $actual))
};


(:
declare function helper:easy-url($url) as xs:string
{
  if (fn:starts-with($url, "http")) then $url
  else
    fn:concat("http://localhost:", xdmp:get-request-port(), if (fn:starts-with($url, "/")) then () else "/", $url)
};
:)

declare function helper:http-get($url as xs:string)
{
    let $url-encoded := 
        if ( fn:contains($url, '%') ) then
            (: let's assume it is encoded, for now. :)
            $url
        else if ( fn:contains($url, '?') ) then
            fn:concat( fn:substring-before($url, '?'), '?', web:encode-url(fn:substring-after($url, '?')) )
        else
            $url
    return http:send-request(<http:request method='get' />, $url-encoded )
};

(:
declare function helper:assert-http-get-status($url as xs:string, $options as element(xdmp-http:options), $status-code)
{
  let $response := helper:http-get($url, $options)
  return
    test:assert-equal($status-code, fn:data($response[1]/*:code))
};

:)
