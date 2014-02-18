
global <<< require \prelude-ls
require! chai
chai.should!

Group = requirejs \ls!src/group

describe "Buggy Group", ->
  describe "Creating a new group", (...) ->
    it "should create a valid empty group", ->
      grp = Group.create-group!
      grp.should.be.ok

      grp.should.have.property "name"
      grp.should.have.property "generics"
      grp.should.have.property "meta"
      grp.meta.type.should.equal "group"

    it "shouldn't overwrite existing entries", (...) ->
      grp = Group.create-group name: "new Group"
      grp.name.should.equal "new Group"
      # but necessary items should be in the group!
      grp.should.have.property "generics"
      grp.generics.should.eql []
      grp.should.have.property "meta"
      grp.meta.type.should.equal "group"

  describe "Group generics", (...) ->
    it "should be able to add new generics", ->
      grp1 = Group.create-group!
      grp2 = Group.create-group name: "GRP2"

      Group.add-generic grp1, grp2
      generics = Group.get-generics-by-name grp1, "GRP2"
      generics.length.should.equal 1

