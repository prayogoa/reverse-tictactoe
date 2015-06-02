React = require 'react'
{GameState, AI} = require './tictactoe'
{Board, PickTurn} = require './board'
EventEmitter = require('events').EventEmitter

emitter = new EventEmitter()

state = null
otherPlayer = null
player2 = new AI emitter

renderBoard = (state) ->
	React.render <Board gameState={state} emitter={emitter} otherPlayer={otherPlayer} />, document.getElementById 'main_content_wrap'

renderPickTurn = ->
	React.render <PickTurn emitter={emitter} />, document.getElementById 'main_content_wrap'

emitter.on 'player-move', (num) ->
	state.doMove num
	renderBoard state
	player2.nextMove(state) unless state.end

emitter.on 'ai-move', (num) ->
	state.doMove num
	renderBoard state

emitter.on "restart", ->
	renderPickTurn()

emitter.on "start-first", ->
	state = GameState.initState(1)
	otherPlayer = 2
	renderBoard state

emitter.on "start-second", ->
	console.log 'second'
	state = GameState.initState(2)
	otherPlayer = 1
	player2.nextMove(state)

renderPickTurn()