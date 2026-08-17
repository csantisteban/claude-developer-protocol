# ColdFusion

## Overview

Standards for all ColdFusion files, including page templates (`.cfm`) and
components (`.cfc`).

There is no single authoritative external style guide for ColdFusion. This file
is the complete standard — all rules are defined here.

Linting is enforced via **CFLint**:
https://github.com/cflint/CFLint

All files must pass CFLint with no errors before being committed.

---

## File Structure

### Page files (`.cfm`)

Every `.cfm` file must follow this top-to-bottom structure:

1. Includes and imports (tag libraries, function files)
2. Main content wrapped in a `<cftry>` / `<cfcatch>` block

### Component files (`.cfc`)

Every `.cfc` file must follow this top-to-bottom structure:

1. `<cfcomponent>` declaration with `output="false"`
2. `<cfproperty>` declarations (if any)
3. `<cffunction>` blocks - `init` first if present, then public, then private

---

## Variable Naming and Scope

Use `camelCase` for all variable names. No Hungarian notation, no type prefixes.

### Scope prefix rules

Always qualify variables with their scope when any ambiguity is possible.
The following scopes must always be explicitly prefixed:

| Scope | Prefix | Example |
|---|---|---|
| URL parameters | `url.` | `url.orderId` |
| Form fields | `form.` | `form.email` |
| Session data | `session.` | `session.userId` |
| Application data | `application.` | `application.config` |
| CGI variables | `cgi.` | `cgi.request_method` |
| Cookie values | `cookie.` | `cookie.token` |
| Local (cfscript) | `local.` | `local.result` |

Never rely on ColdFusion's implicit scope resolution for variables that could
belong to more than one scope.

### Function-local variables

All variables declared inside a `<cffunction>` block must use the `var` keyword
to prevent leakage into the shared `variables` scope:

```cfml
<!--- bad - leaks into variables scope --->
<cfset userId = arguments.userId />

<!--- good --->
<cfset var userId = arguments.userId />
<cfset var result = "" />
```

### Page-scope variables

Variables declared at page scope (outside any function) must not use `var`:

```cfml
<!--- bad --->
<cfset var userId = "" />

<!--- good --->
<cfset userId = "" />
```

---

## Queries

Always use `<cfqueryparam>` for every variable passed into a query. Never
interpolate `url`, `form`, `cgi`, `cookie`, or any other user-controlled scope
directly into a query string:

```cfml
<!--- bad - SQL injection risk --->
<cfquery name="qOrder" datasource="#application.dsn#">
    SELECT order_id, status
      FROM orders
     WHERE order_id = #url.orderId#
</cfquery>

<!--- good --->
<cfquery name="qOrder" datasource="#application.dsn#">
    SELECT order_id, status
      FROM orders
     WHERE order_id = <cfqueryparam value="#url.orderId#" cfsqltype="cf_sql_integer">
</cfquery>
```

Always specify the correct `cfsqltype`. Common types:

| Data | `cfsqltype` |
|---|---|
| Integer / ID | `cf_sql_integer` |
| String / varchar | `cf_sql_varchar` |
| Date only | `cf_sql_date` |
| Date and time | `cf_sql_timestamp` |
| Decimal / float | `cf_sql_decimal` |
| Boolean / bit | `cf_sql_bit` |

Name query result variables with a `q` prefix in `camelCase`:

```cfml
<!--- bad --->
<cfquery name="result" ...>
<cfquery name="getOrder" ...>

<!--- good --->
<cfquery name="qOrder" ...>
<cfquery name="qActiveUsers" ...>
```

Add `maxrows` to any query that could return an unbounded result set:

```cfml
<cfquery name="qRecentOrders" datasource="#application.dsn#" maxrows="500">
```

---

## Output and Encoding

Never render `url`, `form`, `cgi`, `cookie`, or any user-controlled value into
a response without first encoding it for the correct context:

| Context | Function |
|---|---|
| HTML body | `EncodeForHTML(value)` |
| HTML attribute | `EncodeForHTMLAttribute(value)` |
| JavaScript string | `EncodeForJavaScript(value)` |
| URL parameter | `EncodeForURL(value)` |

```cfml
<!--- bad - XSS risk --->
<cfoutput>#url.name#</cfoutput>
<cfoutput><input value="#form.email#"></cfoutput>

<!--- good --->
<cfoutput>#EncodeForHTML(url.name)#</cfoutput>
<cfoutput><input value="#EncodeForHTMLAttribute(form.email)#"></cfoutput>
```

Keep `<cfoutput>` blocks narrow - wrap only the dynamic value, not the
surrounding markup:

```cfml
<!--- bad --->
<cfoutput>
    <div class="card">
        <h2>Order #order.id#</h2>
        <p>#EncodeForHTML(order.status)#</p>
    </div>
</cfoutput>

<!--- good --->
<div class="card">
    <h2>Order <cfoutput>#order.id#</cfoutput></h2>
    <p><cfoutput>#EncodeForHTML(order.status)#</cfoutput></p>
</div>
```

---

## Error Handling

All page content must be wrapped in a `<cftry>` block. The `<cfcatch>` handler
must always be the last element inside it:

```cfml
<cftry>

    <!--- page content --->

    <cfcatch type="any">
        <!--- log the error internally --->
        <cflog file="application" type="error"
               text="Error in #cgi.script_name#: #cfcatch.message#" />

        <!--- return a safe response to the caller --->
        <cfheader statuscode="500" statustext="Internal Server Error">
        <cfoutput>An unexpected error occurred.</cfoutput>
    </cfcatch>

</cftry>
```

Never expose `cfcatch.detail`, `cfcatch.tagcontext`, or `cfcatch.stacktrace`
in any response - these leak internal file paths, line numbers, and query text.

Log errors internally with enough detail to diagnose them. Log only the fields
needed - never dump entire `form`, `url`, or `session` scopes into a log entry.

---

## HTTP Method Enforcement

Pages that create, update, or delete data must check the request method and
reject anything other than `POST` before processing:

```cfml
<cfif cgi.request_method NEQ "POST">
    <cfheader statuscode="405" statustext="Method Not Allowed">
    <cfabort>
</cfif>
```

---

## JSON Responses

Set the content type before any output and use `SerializeJSON` - never
hand-build JSON strings:

```cfml
<cfcontent type="application/json; charset=utf-8">

<cfset response = {
    "status": "ok",
    "data":   result
} />

<cfoutput>#SerializeJSON(response)#</cfoutput>
```

Use a consistent error envelope for all failure responses:

```cfml
<cfset errorResponse = {
    "status":  "error",
    "code":    "invalid_token",
    "message": "The provided token is invalid or has expired."
} />
<cfheader statuscode="403" statustext="Forbidden">
<cfoutput>#SerializeJSON(errorResponse)#</cfoutput>
<cfabort>
```

Never include stack traces, query text, or internal identifiers in error
responses returned to the caller.

---

## Redirects

Never build a redirect target from `url`, `form`, or `cgi` values without
validating against an allowlist:

```cfml
<!--- bad - open redirect risk --->
<cflocation url="#url.returnTo#" addtoken="false">

<!--- good --->
<cfset allowedPaths = ["/dashboard/", "/orders/", "/invoices/"] />
<cfif ArrayFind(allowedPaths, url.returnTo)>
    <cflocation url="#url.returnTo#" addtoken="false">
<cfelse>
    <cflocation url="/dashboard/" addtoken="false">
</cfif>
```

Always pass `addtoken="false"` - CFID and CFTOKEN must never appear in a URL.

---

## Components (CFCs)

Declare `output="false"` on `<cfcomponent>` and on every `<cffunction>` that
does not explicitly render HTML:

```cfml
<cfcomponent output="false">

    <cffunction name="getOrder" access="public" returntype="query" output="false">
        <cfargument name="orderId" type="numeric" required="true">

        <cfset var result = "" />

        <cfquery name="result" datasource="#application.dsn#">
            SELECT order_id, status
              FROM orders
             WHERE order_id = <cfqueryparam value="#arguments.orderId#"
                                            cfsqltype="cf_sql_integer">
        </cfquery>

        <cfreturn result>
    </cffunction>

</cfcomponent>
```

Declare `<cfargument>` for every parameter. Always specify `type` and
`required`. Use `default` only when the argument is genuinely optional:

```cfml
<!--- bad --->
<cffunction name="getOrder">

<!--- good --->
<cffunction name="getOrder" access="public" returntype="query" output="false">
    <cfargument name="orderId"      type="numeric" required="true">
    <cfargument name="includeLines" type="boolean" required="false" default="false">
```

---

## Conditionals

Use `IS`, `IS NOT`, `EQ`, `NEQ`, `GT`, `LT`, `GTE`, `LTE` for comparisons
in tag-based CFML - not symbolic operators:

```cfml
<!--- bad --->
<cfif status == "active">
<cfif count > 0>

<!--- good --->
<cfif status IS "active">
<cfif count GT 0>
```

Use `StructKeyExists()` to test for the presence of a key - not `IsDefined()`,
which silently searches multiple scopes:

```cfml
<!--- bad --->
<cfif IsDefined("url.orderId")>

<!--- good --->
<cfif StructKeyExists(url, "orderId")>
```

---

## String Handling

Use `Len(Trim(value))` to check for a non-empty string - a bare comparison to
`""` does not catch whitespace-only values:

```cfml
<!--- bad --->
<cfif value NEQ "">

<!--- good --->
<cfif Len(Trim(value)) GT 0>
```

Always specify the delimiter explicitly when using list functions:

```cfml
<!--- bad --->
<cfset items = ListToArray(rawList) />

<!--- good --->
<cfset items = ListToArray(rawList, ",") />
```

---

## Comments

Use `<!--- --->` for all ColdFusion comments. Never use HTML comments
(`<!-- -->`) for logic or intent - they are sent to the browser:

```cfml
<!--- bad - reaches the browser --->
<!-- check the token before querying -->

<!--- good - stripped at the server --->
<!--- validate the token before querying --->
```

Comments must explain why, not what. Do not leave commented-out code in
committed files - remove it or track it in version control.

---

## What Claude Must Not Do

- Do not interpolate `url`, `form`, `cgi`, or `cookie` values directly into
  `<cfquery>` - always use `<cfqueryparam>` with the correct `cfsqltype`
- Do not output user-supplied values without the appropriate `EncodeFor*()` call
- Do not use `<!-- -->` HTML comments for ColdFusion logic - use `<!--- --->`
- Do not expose `cfcatch.detail`, `cfcatch.tagcontext`, or `cfcatch.stacktrace`
  in any response
- Do not build redirect targets from user input without an allowlist
- Do not omit `output="false"` from `<cfcomponent>` or `<cffunction>` declarations
- Do not omit `type` or `required` from `<cfargument>` declarations
- Do not use `IsDefined()` to test scope keys - use `StructKeyExists()`
- Do not omit `<cfqueryparam>` on any query variable for any reason
- Do not hand-build JSON strings - always use `SerializeJSON()`
- Do not omit `var` for variables declared inside a `<cffunction>` block
- Do not pass `addtoken="true"` or omit `addtoken` on any `<cflocation>` call
- Do not commit a file that produces CFLint errors