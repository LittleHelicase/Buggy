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

define ["handlebars", "src/util/deep-find"] (Handlebars, DeepFind) ->

  install-helper = (...) ->
    Handlebars.registerHelper 'if_eq', (a, b, opts) ->
      if a == b
        opts.fn this
      else
        opts.inverse this

    Handlebars.registerHelper 'if_neq', (a, b, opts) ->
      if a != b
        opts.fn this
      else
        opts.inverse this

    Handlebars.registerHelper 'ifCond' (v1, v2, options) ->
      if v1 or v2
        return options.fn this
      return options.inverse this

    #these handlers must be defined in the language file!!
    Handlebars.registerHelper 'input', (a) ->
      "input[\"#a\"].Value"

    Handlebars.registerHelper 'input-data', (a) ->
      "input[\"#a\"] = yield csp.take(InQueues[name + \":#a\"]);"

    Handlebars.registerHelper 'output', (a) ->
      "output[\"#a\"].Value"

    Handlebars.registerHelper 'output-data', (a) ->
      "yield csp.put(OutQueues[name + \":#a\"], JSON.parse(JSON.stringify(output[\"#a\"])));"

    Handlebars.registerHelper 'set-meta', (node, what, val) ->
      "output[\"#node\"].meta."+ what + " = " + val

    Handlebars.registerHelper 'has-meta', (node, what) ->
      "'" + what + "' in input['" + node + "'].meta"

    Handlebars.registerHelper 'meta-query', (node, what) ->
      "input['" + node + "'].meta."+what

    Handlebars.registerHelper 'node-meta', (what) ->
      "meta."+what

    Handlebars.registerHelper 'metadata', (a) ->
      "var meta "

    Handlebars.registerHelper 'merge-meta', (what, input) ->
      "output['"+what+"'].meta = merge(output['"+what+"'].meta, input['"+input+"'].meta);\n";

    Handlebars.registerHelper 'create-database', (db_var) ->
      "databases[#db_var.guid] = Mapdatabase.create(#db_var.guid)"

    Handlebars.registerHelper 'database-add', (what, dbs) ->
      "var uuid = input['#what'].meta.database.uuid;\n  var where = '0';\n  if('path' in input['#what'].meta){ where = input['#what'].meta.path; }\n  Mapdatabase.add(#dbs[uuid], where, #what)"

    Handlebars.registerHelper 'database-query', (what, db) ->
      "MapUtil.find(#db, #what)"

    Handlebars.registerHelper 'database-by-guid', (db_var) ->
      "databases[#db_var.guid]"


  install-helper!


  {
    process: (text, impl, options) ->
      context = impl

      if context.implementation?
        implTempl = Handlebars.compile context.implementation, noEscape: true
        context.implementation = implTempl context

      template = Handlebars.compile text, noEscape: true
      template context

    process-a: (text, generic, node, connections, connectors, inner-nodes, debug) ->
      context = {
        generic: generic
        node: node
        connections: connections
        connectors: connectors
        meta: "{}"
        debug: debug
      }
      if generic.meta?
        context.meta = JSON.stringify generic.meta

      # apply implementation templates
      if context.node.implementation?
        implTempl = Handlebars.compile context.node.implementation, noEscape: true
        context.node.implementation = implTempl context
      template = Handlebars.compile text, noEscape: true
      template context
  }
