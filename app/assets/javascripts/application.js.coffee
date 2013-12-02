#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require turbolinks

class SineViewer
  
  constructor: (canvas) ->
    @canvas = $(canvas)
    @context = @canvas[0].getContext('2d')
    @samples = []
    
    @clear()
    @draw_sine()
  
  clear: ->
    @context.clearRect(0, 0, @canvas[0].width, @canvas[0].height)
    @draw_background()
    @draw_border()
  
  draw_background: ->
    @context.beginPath()
    
    # Horizontal line
    @context.moveTo(0, @canvas[0].height / 2)
    @context.lineTo(@canvas[0].width, @canvas[0].height / 2)
    
    # Vertical line
    @context.moveTo(@canvas[0].width / 2, 0)
    @context.lineTo(@canvas[0].width / 2, @canvas[0].height)
    
    @context.strokeStyle = '#aaaaaa'
    @context.stroke()
  
  draw_border: ->
    @context.beginPath()
    
    @context.moveTo(0, 0)
    
    @context.lineTo(@canvas[0].width, 0)
    @context.lineTo(@canvas[0].width, @canvas[0].height)
    @context.lineTo(0, @canvas[0].height)
    @context.lineTo(0, 0)
    
    @context.strokeStyle = '#aaaaaa'
    @context.stroke()
    
  draw_sine: (offset, code) ->
    @context.beginPath()
    
    @context.moveTo(0, @canvas[0].height / 2)
    
    offset or= 0
    offset = offset % 360
    
    code or= 'Math.sin(radians)'
    
    @samples.length = 0
    
    for degrees in [0...360]
      percent = degrees / 360.0 * 100.0
      radians = degrees * (Math.PI / 180)
      offset_radians = offset * (Math.PI / 180)
      
      radians = radians + offset_radians
      
      eval_result = eval(code)
      @samples.push(eval_result)
      
      current_position =
        x: @canvas[0].width * (percent / 100)
        y: eval_result 
      
      current_position.y *= @canvas[0].height / 2
      current_position.y += @canvas[0].height / 2
      
      @context.moveTo(current_position.x, current_position.y)
      @context.lineTo(last_position.x, last_position.y) if last_position?
      
      last_position = current_position
    
    @context.strokeStyle = '#ff0000'
    @context.stroke()

jQuery ->
  $('a[rel~=popover], .has-popover').popover()
  $('a[rel~=tooltip], .has-tooltip').tooltip()
  
  sineViewer = new SineViewer('#waveChart')
  
  sineViewerDraw = ->
    offset = $('#waveOffset').val()
    code = $('#waveCode').val()
    
    sineViewer.clear()
    sineViewer.draw_sine(offset, code)
  
  $('#waveOffset').change(sineViewerDraw)
  $('#waveEvaluate').click(sineViewerDraw)
  $('#waveCode').on 'keypress', -> sineViewerDraw() if (event.which == 13)
  $('#waveDownload').click ->
    samples = window.btoa(sineViewer.samples.toString())
    window.location.href = '/waves/generate?samples=' + samples
  $('#waveListen').click ->
    $.post('/waves/generate', { samples: sineViewer.samples, base64: true }).done (data) ->
      snd = new Audio("data:audio/wav;base64," + data)
      snd.play()
      