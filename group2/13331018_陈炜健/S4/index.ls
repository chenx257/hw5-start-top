class Button
	@buttons = []
	@sum = ->
		number = 0
		[number += button.num for button in @buttons]
		number
	@reset = !->
		[button.reset! for button in @buttons]
	(@dom, @number-fetched-callback)->
		@unread = $ @dom .find '.unread'
		@state = 'clickable'
		@dom.click !~> if @state is 'clickable'
			@disable-other-buttons!
			@wait!
			@fetch-random-number!
		@@@buttons.push @
	disable-other-buttons: !->
		[button.disable! for button in @@@buttons when button isnt @ and button.state isnt 'unclickable' and button.state isnt 'done']
	enable-other-buttons: !->
		[button.enable! for button in @@@buttons when button isnt @ and button.state isnt 'clickable' and button.state isnt 'done']
	wait: !->
		@unread.text '...'
	fetch-random-number: !->
		$.get '/api/random', (number, result)!~>
			@num = parse-int number
			@show-number number
			@disable!
			@enable-other-buttons!
			@done!
			@@@all-number-fetched-callback! if @all-buttons-is-done!
			@number-fetched-callback!
	done: !->
		@state = 'done'
	disable: !->
		@state = 'unclickable' ; @dom.remove-class 'buttons' .add-class 'disabled-buttons'
	enable: !->
		@state = 'clickable' ; @dom.remove-class 'disabled-buttons' .add-class 'buttons'
	show-number: (number)!->
		@unread.text number
	all-buttons-is-done: ->
		[return false for button in @@@buttons when button.state isnt 'done']
		true
	reset: !->
		@unread.text ''
		@enable!

$ ->
	robot.init!
	add-click-to-fetch-random-number-to-all-buttons !->
		robot.click-all-buttons!
	add-click-to-calculate-sum-to-the-info!
	reset-when-leave-apb!
	S4-robot!

add-click-to-fetch-random-number-to-all-buttons = (next)->
	for let dom, i in $ '#control-ring .buttons'
		button = new Button ($ dom), !->
			next!

add-click-to-calculate-sum-to-the-info = !->
	info = $ '#info'
	Button.all-number-fetched-callback = !->
		info.remove-class 'disabled-info' .add-class 'enabled-info'
	info.click !-> if info.has-class 'enabled-info'
		info.find '#sum' .text Button.sum!

reset-when-leave-apb = !->
	apb = $ '#bottom-positioner'
	apb.mouseleave !->
		Button.reset!
		info = $ '#info'
		info.remove-class 'enabled-info' .add-class 'disabled-info'
		info.find '#sum' .text ''
		info.find '.sequence' .text ''
		robot.init!

robot =
	init: !->
		@buttons = $ '#control-ring .buttons'
		@info = $ '#info'
		@sequence = [0 to 4]
		@pos = 0
	click-all-buttons: !->
		if @pos is @sequence.length then @info.click! else @get-next-button!click!
	get-next-button: -> 
		index = @sequence[@pos++]
		@buttons[index]
	shuffle: !->
		@sequence.sort -> 0.5 - Math.random!
	show-sequence: !->
		@info.find '.sequence' .text @sequence.join ', '

S4-robot = !->
	icon = $ '.apb'
	icon.click !->
		robot.shuffle!
		robot.show-sequence!
		robot.click-all-buttons!
