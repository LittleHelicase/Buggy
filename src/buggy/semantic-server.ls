/*
 This file is part of Buggy.

 Buggy is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Buggy is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Buggy.  If not, see <http://www.gnu.org/licenses/>.
*/

console.log "starting semantics server"
url = require "url"
global <<< require \prelude-ls
requirejs = require "../require.js"


Semantics = requirejs "ls!src/semantics"

Semantics.load-semantic-file "base.json", (semantics) ->

  setTimeout (->
    console.log "Semantics"
    console.log semantics), 1000

  http = require("http");

  (http.createServer (request, response) ->
    uri = url.parse(request.url).pathname
    console.log "uri #uri"
    if uri == "/sources/"
      response.writeHead 200, "Content-Type": "text/plain"
      response.write JSON.stringify semantics.sources
      response.end!
    else
      response.writeHead 200, "Content-Type": "text/plain"
      response.write "Server is running!"
      response.end!
    ).listen 8001
