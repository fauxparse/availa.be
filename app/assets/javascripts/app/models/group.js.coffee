class App.Group extends Spine.Model
  @configure "Group", "name", "slug", "admin", "preferences"
  @extend Spine.Model.Ajax

  @hasMany "skills", "App.Skill"

  toString: -> @name()

  url: -> App.Group.url() + "/" + @toParam()

  name: (value) ->
    @_name = value if arguments.length
    @_name

  toParam: -> @slug

  load: (attrs) ->
    @_loading = true
    super
    @_loading = false

  preferences: (preferences) ->
    if preferences?
      @_preferences = $.extend {}, @_preferences or {}, preferences
      unless @_loading
        @savePreferences()
    @_preferences

  color: ->
    if @preferences().color
      Color[@preferences().color]
    else
      Color.of @name()

  savePreferences: ->
    Spine.Ajax.disable => @save()
    clearTimeout @_save
    @_save = setTimeout =>
      $.ajax
        url: @url() + "/preferences"
        type: "put"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(preferences: @preferences())
    , 1500

  members: (members) ->
    if members?
      @_members = new Members(members, this)
    @_members ||= new Members([], this)

  @find: (id) ->
    super || @findByAttribute("slug", id)

  @comparator: (a, b) ->
    a.name().toLocaleLowerCase().localeCompare b.name().toLowerCase()

  @wait: (id, fetch = true) ->
    promise = $.Deferred()
    if @exists(id) && @find(id).members().count()
      promise.resolve @find(id)
    else
      found = =>
        if @exists(id)
          @unbind "refresh", found
          promise.resolve @find(id)
      @bind "refresh", found
      @fetch(id: id) if fetch
    promise

class Member extends Spine.Model
  @configure "Member", "name", "admin", "skill_ids"

  url: ->
    @group().url() + "/members/#{@id}"

  name: (value) ->
    @_name = value if arguments.length
    @_name

  admin: (value) ->
    @_admin = value if value?
    @_admin

  isSelf: ->
    @id == App.User.current().id

  group: -> @_group

  skills: ->
    (skill for skill in group.skills().all() when skill.id in @skill_ids)

  skill: (skill, able = true) ->
    if able && !@hasSkill(skill)
      @skill_ids.push(skill.id || skill)
    else if !able && @hasSkill(skill)
      @skill_ids.splice @skill_ids.indexOf(skill.id || skill), 1

  hasSkill: (skill) ->
    @skill_ids.indexOf(skill.id || skill) > -1

  suitable: (role) ->
    # TODO: match with user's skills for this group
    true

  match: (regexp) ->
    regexp.test @_name

  toString: -> @name()

  save: ->
    params = $.extend {}, Spine.Ajax.defaults,
      url: @url()
      type: "put"
      contentType: "application/json"
      data: JSON.stringify(@toJSON())
    $.ajax params

  @factory: (attrs, group) ->
    member = @fromJSON attrs
    member._group = group
    member

  @comparator: (a, b) ->
    a.name().toLocaleLowerCase().localeCompare b.name().toLocaleLowerCase()

class Members
  constructor: (members, group) ->
    @_group = group
    members = members.all?() || members
    @_members = (Member.factory(member, group) for member in members)

    @_membersById = {}
    for member in @_members
      @_membersById[member.id] = member

    @sort()

  sort: ->
    @_members.sort Member.comparator

  group: -> @_group

  all: -> @_members

  count: -> @all().length

  find: (id) ->
    @_membersById[id]

  matching: (str) ->
    str = RegExp.quote str.normalize()
    regexp = "^" + ("(?=.*#{t})" for t in str.split(/\s+/)).join("")
    filter = new RegExp(regexp, "i")
    (member for member in @_members when member.match(filter))
