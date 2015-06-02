React = require 'react'
{GameState, AI} = require './tictactoe'
Board = require './board'
EventEmitter = require('events').EventEmitter

emitter = new EventEmitter()

player2 = new AI emitter
state = GameState.initState()

render = (state) ->
	React.render <Board gameState={state} emitter={emitter} />, document.body

emitter.on 'player-move', (num) ->
	state.doMove num
	render state
	player2.nextMove(state) unless state.end

emitter.on 'ai-move', (num) ->
	state.doMove num
	render state

emitter.on "restart", ->
	state = GameState.initState()
	render state	
render state