
global <<< require \prelude-ls
require! chai
chai.should!
chai.use require \chai-things

Connection = requirejs "ls!src/connection"
Group = requirejs "ls!src/group"

describe "Buggy Connections", !->
  describe "Processing a group", (...) !->
    it "should list all connections", !->
      grp = Group.create {
        generics: [
          {
            name:"A"
          },
          {
            name:"B"
          },
          {
            name:"C",
            # the > indicates that the input is another generic
            inputs: { "INPUT1": ">A", "INPUT2": ">B" }
          }
        ]
      }

      cn = Connection.gather-connections grp
      cn.length.should.equal 2
      console.log cn
      cn.should.include.something.that.deep.equals {input-connector: "C", output-connector: "A"}
      cn.should.include.something.that.deep.equals {input-connector: "C", output-connector: "B"}