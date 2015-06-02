Promise = require('bluebird')

###
board state is an array with size 9
	[0][1][2]
	[3][4][5]
	[6][7][8]
###

BOARD_SIZE = 9

score = (board, depth) ->
	if win board, 3
		return 10 - depth
	if win board, -3
		return depth - 10
	return 0

end = (board, step, depth) ->
	win(board, 3) or win(board, -3) or step+depth == BOARD_SIZE

cmp = (s1, s2, depth) ->
	if (depth%2) == 1 then s1.score > s2.score
	else s1.score < s2.score

minimax = (currState, step, depth) ->
	if end(currState, step, depth)
		return score: score(currState, depth) 

	nextStates = generate_state currState, depth
	for state in nextStates
		state.score = minimax(state, step, depth+1).score

	next = nextStates.reduce (prev, current) ->
		chosen = if cmp(prev, current, depth) then prev else current
		return chosen

generate_state = (board, depth) ->
	states = []
	fill = if depth % 2 == 0 then 1 else -1
	toFill = 0
	while toFill < BOARD_SIZE
		while((not legal_move board, toFill) and toFill < BOARD_SIZE)
			toFill++
		break if toFill >= BOARD_SIZE
		child = board.slice()
		child[toFill] = fill
		child.filled = toFill
		states.push child
		toFill++
	return states

win = (b, winval) ->
	#horizontal
	for i in [0, 3, 6]
		return [i, i+1, i+2] if b[i] + b[i+1] + b[i+2] is winval
	#vertical
	for i in [0, 1, 2]
		return [i, i+3, i+6] if b[i] + b[i+3] + b[i+6] is winval
	#diagonal
	return [2,4,6] if b[2] + b[4] + b[6] is winval
	return [0,4,8] if b[0] + b[4] + b[8] is winval
	return false

fill_String = (b, n) ->
	switch b[n]
		when 1 then "X"
		when 0 then n
		when -1 then "O"

print_board = (b) ->
	return unless b
	console.log("""
		-------------
		""")
	for i in [0, 3, 6]
		console.log ("""
			|   |   |   |
			| #{fill_String(b,i)} | #{fill_String(b,i+1)} | #{fill_String(b,i+2)} |
			|   |   |   |
			-------------
			""")

legal_move = (board, move) ->
	return 0 <= move <= 8 and board[move] is 0

play = Promise.method (state, step)->
		print_board state
		return score(state, 0) if end state, step, 0
		prompt.getAsync
			properties:
				fill:
					description: 'enter next box to fill'
					conform: legal_move.bind null, state
					required: true
					message: 'must choose an empty box'
		.then (result) ->
			state[result.fill] = -1
			step++
			console.log "You filled #{result.fill}"
			print_board state
			return score(state, 0) if end state, step, 0
			state = (minimax state, step, 0)
			step++
			console.log "AI filled #{state.filled}"
			play state, step

class GameState
	@parse: (str) ->
		parsed = JSON.parse str
		return new GameState parsed.board, parsed.turn

	@initState: (player) ->
		return new GameState([0,0,0,0,0,0,0,0,0], 0, player)

	constructor: (@board, @turn, @player) ->
		@lastMove = null
		@winTiles = null
		@end = false

	canMove: ->
		return (@turn % 2) + 1 is @player

	isLegalMove: (move) ->
		return legal_move(@board, move)

	doMove: (move) ->
		@board[move] = if @turn%2 is 0 then -1 else 1
		@turn++
		@lastMove = move
		@winTiles = win(@board, 3) or win(@board, -3) or null
		@end = @turn is 9 or @winTiles

class AI
	constructor: (@emitter) ->

	nextMove: Promise.method (state) ->
		next = minimax state.board, state.turn, 0
		Promise.delay (Math.floor Math.random() * 500) + 1000
		.then =>
			@emitter.emit 'ai-move', next.filled

module.exports = {GameState, AI}