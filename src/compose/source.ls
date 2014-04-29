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

define ["ls!src/compose/dependency-graph", "ls!src/compose/templating", "ls!src/graph", "ls!src/util/clone"] (DependencyGraph, Templating, Graph, Clone) ->

  get-best-match = (id, resolve) ->
    r = resolve[id]
    # TODO: currently the best match is the first match ;)
    if typeof! r == "Array"
      r.0
    else
      r

  is-implemented = (node) ->
    node.atomic? and node.atomic or node.implemented? and node.implemented

  pack-with = (attribute, node, src) -->
    [node[attribute], id: node.id, source: src]

  pack-with-name = pack-with "name"
  pack-with-id = pack-with "id"

  # connectors are unique in a node!
  get-group-connectors = (nodes, resolve) ->
    cns = nodes |> map (n) ->
      r = get-best-match n.name, resolve
      r.connectors |> map (c) ->
        cn = Clone(c)
        cn.generic = n.id
        return cn
    flatten cns

  get-source = (resolve, ld, node, graph, query, pack-function, filter-function) -->
    name = node.name
    resolved-node = get-best-match name, resolve
    console.log resolved-node
    if !filter-function? or filter-function resolved-node
      grp-nodes = Graph.get-group-nodes graph, resolved-node
      grp-connectors = get-group-connectors grp-nodes, resolve
      grp-connections = Graph.get-group-connections graph, resolved-node
      source = Templating.process (ld.query query), node, resolved-node, grp-connections, grp-connectors, grp-nodes
      pack-function node, source

  get-sources = (resolve, ld, graph, query, pack-function, filter-function) -->
    graph.nodes |> map (n) ->
      get-source resolve, ld, n, graph, query, pack-function, filter-function

  generate-source-map-for = (d-graph, resolve, ld) ->
    get-srcs = get-sources resolve, ld, d-graph
    console.log "########### atomics"
    name-source = get-srcs "--> atomic", pack-with-name, is-implemented
    console.log "########### nodes"
    node-source = get-srcs "--> node", pack-with-id, null
    console.log "########### groups"
    group-source = get-srcs "--> group", pack-with-id, -> !is-implemented it
    console.log "###########"

    c-source = d-graph.connections |> map (c) ->
      [c.id, ""]

    {
      implementations: pairs-to-obj (name-source |> filter -> it?)
      nodes: pairs-to-obj (node-source |> filter -> it?)
      groups: pairs-to-obj (group-source |> filter -> it?)
      connections: pairs-to-obj c-source
    }

  gather-sources = (map-entry, source-map) ->
    sub = source-map[map-entry]
    srcs = (keys sub) |> map (id) -> sub[id].source
    fold (+), "", srcs

  {

    # generates source code for the program and resolved objects
    generate-for: (entry, resolve, ld) ->
      dependency-graph = DependencyGraph.generate-for entry, resolve, get-best-match
      
      # TODO: calculate "distance" from entry-point to generate source in the right order (for languages that require that)
      console.log dependency-graph.nodes
      console.log dependency-graph.connections
      sources = generate-source-map-for dependency-graph, resolve, ld

      console.log sources

      source = (gather-sources "implementations", sources) + 
               (gather-sources "nodes", sources) + 
               (gather-sources "groups", sources)
  #    keys sources |> map (id) !->
  #      source += "// begin source for #id \n"
  #      source += sources[id]
  #      source += "\n// end source for #id \n"

      return source
  }
