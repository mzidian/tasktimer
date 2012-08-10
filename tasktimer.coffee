$(document).ready ->
  class ViewModel
    w: (f) =>
      (params) ->
        -> f params
    newTaskName: ko.observable 'untitled'
    tasks: ko.observableArray []
    timeList: ko.observableArray []
    currentTask:
      timeSpent: ko.observable '0'
      started: ko.observable '0'
    addTask: =>
      if @newTaskName() != ''
        @tasks.push {
          name: @newTaskName()
          times: 0
          totalTime: 0
          averageTime: ko.observable('')}
        @newTaskName ''
    removeTask: (name) =>
      @tasks.remove ((e) -> e.name == name)
    dateString: (d) ->
      s = ''
      started = false
      next = (fname, another) ->
        if d[fname]() > 0 || started
          s += d[fname]()
          if another
            s += ':'
          started = true
      next 'getFullYear', true
      next 'getMonth', true
      next 'getDate', true
      next 'getHours', true
      next 'getMinutes', true
      next 'getSeconds', false
      s
    timeString: (ms) ->
      ms = Math.floor ms/1000
      s = ''
      noms = [60, 60, 24, 365, 1000000]
      for n, i in noms
        s = (ms % n) + s
        if Math.floor(ms / n) == 0
          break
        ms = Math.floor ms/n
        s = ':' + s
      s

    updateTime: =>
      ms = (new Date()).getTime() - @currentTask.startedMs
      @currentTask.timeSpent @timeString ms 
      @currentTask.task.totalTime -= @currentTask.task.timeSoFar
      @currentTask.task.totalTime += ms
      @currentTask.task.timeSoFar = ms

      @currentTask.task.averageTime @timeString @currentTask.task.totalTime / @currentTask.task.times
    startTimer: =>
      @updateTime()
      msleft = 1000 - ((new Date()).getTime() - @currentTask.startedMs) % 1000
      setTimeout @startTimer, msleft
    startTask: (name) =>
      if !(@currentTask.name is undefined)
        @timeList.shift()
        @timeList.unshift {
          name: @currentTask.name
          timeSpent: @currentTask.timeSpent()
          started: @currentTask.started()}
      for task in @tasks()
        if task.name == name
          task.times++
          task.timeSoFar = 0
          @currentTask.task = task
          break
      @currentTask.name = name
      d = new Date()
      @currentTask.timeSpent '0'
      @currentTask.started @dateString d
      @currentTask.startedMs = d.getTime()
      @startTimer()
      @timeList.unshift @currentTask

  ko.applyBindings new ViewModel
