class App.Event extends Spine.Model
  @configure "Event",
    "name", "recurrences", "roles", "instances"
  @belongsTo "group", "App.Group"
  @extend Spine.Model.Ajax

  @url: ->
    "/events"

  scope: ->
    @group().url()

  name: (value) ->
    @_name = value if value?
    @_name || "New event"

  recurrences: (value) ->
    @_recurrences = Recurrence.fromJSON(value) if value?
    @_recurrences ||= [new Recurrence()]

  roles: (roles) ->
    if roles?
      @_roles = new Roles(roles, this)
    @_roles ||= new Roles([Role.blank(@group)], this)

  addRole: (skill) ->
    @roles().push new Role(skill_id: skill.id)

  deleteRoleAt: (index) ->
    @roles().delete index

  start_date: (value) ->
    @recurrences()[0].start_date(value)

  end_date: (value) ->
    @recurrences()[0].end_date(value)

  start_time: (value) ->
    @recurrences()[0].start_time(value)

  end_time: (value) ->
    @recurrences()[0].end_time(value)

  weekdays: (value) ->
    @recurrences()[0].weekdays(value)

  dateRange: ->
    @recurrences()[0].dateRange()

  instances: (instances) ->
    if instances?
      @_instances = new Instances(instances, this)
    @_instances ||= new Instances([], this)

  toJSON: ->
    json = super
    json.instances = @instances().toJSON()
    json

  @comparator: (a, b) ->
    a.start_time() - b.start_time()

  @fetchGroup: (group) ->
    $.getJSON(group.url() + @url()).done (data) =>
      @refresh data

class Recurrence extends Spine.Model
  @configure "Recurrence",
    "start_date",
    "end_date",
    "weekdays",
    "start_time",
    "end_time",
    "time_zone"

  start_date: (value) ->
    @_start_date = @handleDate(value) if value?
    @_start_date || moment().startOf("day")

  end_date: (value) ->
    @_end_date = @handleDate(value) if value?
    @_end_date || moment().endOf("day")

  start_time: (value) ->
    @_start_time = parseInt(value, 10) if value?
    @_start_time || 19 * 3600 + 30 * 60

  end_time: (value) ->
    @_end_time = parseInt(value, 10) if value?
    @_end_time || 21 * 3600

  handleDate: (value) ->
    if moment.isMoment(value)
      value.clone()
    else
      moment(value)

  weekdays: (value) ->
    @_weekdays = value.slice(0) if value?
    @_weekdays || [@start_date().day()]

  time_zone: ->
    moment.defaultZone.name

  toJSON: ->
    $.extend {}, super,
      start_date: @start_date().format(),
      end_date: @end_date().format()

  dateRange: ->
    moment().range(@start_date(), @end_date())

class Role extends Spine.Model
  @configure "Role", "name", "plural", "minimum", "maximum", "position"
  @belongsTo "skill", "App.Skill"

  name: (value) ->
    @_name = value if arguments.length
    @_name || @skill().name()

  plural: (value) ->
    @_plural = value if arguments.length
    @_plural || @skill().plural()

  minimum: (value) ->
    @_minimum = parseInt(value, 10) if value?
    @_minimum || 0

  maximum: (value) ->
    if arguments.length
      @_maximum = if value?
        parseInt(value, 10)
      else
        undefined
    @_maximum

  position: (value) ->
    @_position = parseInt(value, 10) if value?
    @_position || 0

  range: ->
    if !@maximum()?
      I18n.t("role.range.n_or_more", minimum: @minimum())
    else if @minimum() == @maximum()
      @minimum()
    else
      "#{@minimum()}–#{@maximum()}"

  toJSON: ->
    data = super
    delete data.maximum unless @_maximum?
    delete data.name unless @_name?
    delete data.plural unless @_plural?
    data

  toString: -> @name()

  @comparator: (a, b) ->
    a.position() - b.position()

  @blank: (group) ->
    new Role(skill_id: group.skills().first()?.id)

class Roles
  constructor: (roles, event) ->
    @_event = event
    @_roles = roles.all?() || Role.fromJSON(roles)
    for role, i in @_roles
      role.position i

    @_rolesById = {}
    for role in @_roles
      @_rolesById[role.id] = role

    @_roles.sort Role.comparator

  all: -> @_roles

  find: (id) ->
    @_rolesById[id]

  toJSON: ->
    (role.toJSON() for role in @all())

  at: (index) ->
    @_roles[index]

  push: (role) ->
    role.position @_roles.length
    @_roles.push role
    this

  delete: (index) ->
    @_roles.splice(index, 1)
    for role, i in @_roles
      role.position i
    this

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
    @availability()[member.id] = state
    @trigger "change"

  assignments: (assignments) ->
    if assignments?
      @_assignments = assignments
    @_assignments ||= {}

  assignmentsForRole: (role) ->
    @assignments()[role.id ? role] ||= []

  assign: (member, role) ->
    unless @assigned(member, role)
      @assignmentsForRole(role).push(member.id || member)
      @trigger "change"

  unassign: (member, role) ->
    if @assigned(member, role)
      members = @assignmentsForRole(role)
      while (index = members.index(member.id ? member)) > -1
        members.splice(index, 1)
      @trigger "change"

  assigned: (member, role) ->
    @assignmentsForRole(role).indexOf(member.id || member) > -1

  toJSON: ->
    {
      time: @time().toISOString()
      assignments: @assignments()
      availability: @availability()
    }

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
