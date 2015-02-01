#= require ./event

class Instance extends Spine.Model
  @configure "Instance", "time", "assignments"

  time: (time) ->
    if time?
      unless moment.isMoment(time)
        time = moment(time)
      @_time = time
    @_time

  event: -> @_event

  available: ->
    ids = (id for own id, value of @availability() when value)
    (@event().group().members().find(id) for id in ids)

  isAvailable: (member) ->
    @availability()[member.id ? member]

  availability: (availability) ->
    if availability?
      @_availability = $.extend {}, availability
    @_availability ||= {}

  availabilityByRole: ->
    results = {}
    ids = (id for own id, available of @availability() when available)
    members = (@event().group().members().find(id) for id in ids)
    for role in @event().roles().all()
      results[role.id] = (m for m in members when m.suitable(role))
    results

  setAvailability: (member, state) ->
    id = member.id ? member
    @availability()[id] = state
    @changes().availability[id] = state
    @changed()

  assignments: (assignments) ->
    if assignments?
      @_assignments = assignments
    @_assignments ||= {}

  assignmentsForRole: (role) ->
    @assignments()[role.id ? role] ||= []

  assign: (member, role) ->
    unless @assigned(member, role)
      @setAvailability(member, true) unless @isAvailable(member)
      @assignmentsForRole(role).push(member.id ? member)
      @changes().assignments[role.id ? role] = @assignmentsForRole(role)
      @changed()

  unassign: (member, role) ->
    if @assigned(member, role)
      members = @assignmentsForRole(role)
      while (index = members.indexOf(member.id ? member)) > -1
        members.splice(index, 1)
      @changes().assignments[role.id ? role] = @assignmentsForRole(role)
      @changed()

  assigned: (member, role) ->
    if role
      @assignmentsForRole(role).indexOf(member.id || member) > -1
    else
      for own role, _ of @assignments()
        return true if @assigned(member, role)
      false

  toJSON: ->
    {
      time: @time().toISOString()
      assignments: @assignments()
      availability: @availability()
    }

  changed: ->
    clearTimeout @_changeTimer
    @trigger "change"
    @event().trigger "instance", this
    @_changeTimer = setTimeout @saveChanges, 2000

  changes: ->
    @_changes ||= { assignments: {}, availability: {} }

  saveChanges: =>
    @trigger "saving"
    changes = $.extend {}, @changes()
    params = $.extend {}, Spine.Ajax.defaults,
      url: @url()
      type: "put"
      data: JSON.stringify(changes)
      contentType: "application/json"
    $.ajax(params)
      .done =>
        delete @_changes
        @trigger "saved"
      .fail =>
        @_changes = $.extend changes, @changes()
        @trigger "failed"

  url: ->
    @event().url() + "/times/#{@toParam()}"

  toParam: ->
    @time().toISOString().replace(/\.\d+/, "")

  description: ->
    (member.name() for member in @members()).toSentence() ||
      I18n.t("events.instance.assignments.nobody")

  members: ->
    ids = {}
    results = []
    for own role, memberIds of @assignments()
      for id in memberIds when !ids[id]
        results.push @event().group().members().find(id)
        ids[id] = true
    results

  @factory: (attrs, event) ->
    instance = @fromJSON(attrs)
    instance._event = event
    instance

  @comparator: (a, b) ->
    a.time() - b.time()

class Instances
  constructor: (instances, event) ->
    @_event = event
    all = instances.all?() || instances
    @_instances = (Instance.factory(instance, event) for instance in all)
    @_instances.sort Instance.comparator

  all: -> @_instances

  find: (time) ->
    time = moment(time) unless moment.isMoment(time)
    for instance in @_instances
      return instance if time.isSame instance.time(), "minute"

  toJSON: ->
    (instance.toJSON() for instance in @all())

App.Event.Instance = Instance
App.Event.Instances = Instances
