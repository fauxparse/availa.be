class App.Group extends Spine.Model
  @configure "Group", "name", "slug", "admin", "preferences"
  @extend Spine.Model.Ajax

  @hasMany "skills", "App.Skill"

  toString: -> @name

  url: -> App.Group.url() + "/" + @toParam()

  toParam: -> @slug

  load: (attrs) ->
    @_loading = true
    super
    @_loading = false

  preferences: (preferences) ->
    if preferences?
      @_preferences = $.extend @_preferences or {}, preferences
      unless @_loading
        Spine.Ajax.disable => @save()
        @savePreferences()
    @_preferences

  color: ->
    if @preferences().color
      Color[@preferences().color]
    else
      Color.of @name

  savePreferences: ->
    clearTimeout @_save
    @_save = setTimeout =>
      $.ajax
        url: @url() + "/preferences"
        type: "put"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(preferences: @preferences())
    , 250

  members: (members) ->
    if members?
      @_members = new Members(members, this)
    @_members ||= new Members([], this)

  @find: (id) ->
    super || @findByAttribute("slug", id)

  @comparator: (a, b) ->
    a.name.toLocaleLowerCase().localeCompare b.name.toLowerCase()

class Member extends Spine.Model
  @configure "Member", "name", "admin", "skill_ids"

  name: (value) ->
    @_name = value if arguments.length
    @_name

  admin: (value) ->
    @_admin = value if value?
    @_admin

  isSelf: ->
    @id == App.User.current().id

  skills: ->
    (skill for skill in group.skills().all() when skill.id in @skill_ids)

  match: (regexp) ->
    regexp.test @_name

  @factory: (attrs, group) ->
    member = @fromJSON attrs
    member._group = group
    member

  @comparator: (a, b) ->
    a.name().toLocaleLowerCase().localeCompare b.name().toLocaleLowerCase()

class Members
  constructor: (members, group) ->
    @_group = group
    @_members = (Member.factory(member, group) for member in members)

    @_members.sort Member.comparator

  group: -> @_group

  all: -> @_members

  find: (id) ->
    for member in @_members
      return member if member.id == id

  matching: (str) ->
    str = RegExp.quote str.normalize()
    regexp = "^" + ("(?=.*#{t})" for t in str.split(/\s+/)).join("")
    filter = new RegExp(regexp, "i")
    (member for member in @_members when member.match(filter))
