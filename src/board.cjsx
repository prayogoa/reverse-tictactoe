React = require 'react'
{Panel, Button} = require 'react-bootstrap'
classSet = require 'classnames'

###
board model is an array with 9 elements
[0, 0, 0,
 0, 0, 0,
 0, 0, 0,]
###

Board = React.createClass
	getInitialState: ->
		move: null
		AIMove: null
	componentDidMount: ->
		@props.emitter.on 'player-move', (num) =>
			@setState
				move: num
				AIMove: null
		@props.emitter.on 'ai-move', (num) =>
			@setState
				move: null
				AIMove: num
	restart: ->
		@setState
			move: null
			AIMove: null
		@props.emitter.emit "restart"
	render: ->
		<div className="main">
			<Panel header="Try to lose!" bsStyle='primary'>
		      {
		      	if @props.gameState.end
		      		(<div>
		      			<p>Game Over</p>
		      			<Button onClick={@restart}>Restart</Button>
		      		</div>)
		      	else if @state.move != null
		      		<p>
		      			You filled {@state.move}.
		      			Waiting for player 2.
		      		</p>
		      	else if @state.AIMove
		      		<p>Player 2 filled {@state.AIMove}</p>
		      	else
		      		<p>Pick a box to fill</p>
		      }
		    </Panel>
			<svg viewBox="0 0 600 600" width="100%" height="100%" className="board">
				{<Tile key={i} num={i} {...@props}/> for i in [0..8] by 1}
			</svg>
		</div>

###
	0  200  400 600
   0-------------
	|   |   |   |
	| 0 | 1 | 2 |
	|   |   |   |
 200-------------
	|   |   |   |
	| 3 | 4 | 5 |
	|   |   |   |
 400-------------
	|   |   |   |
	| 6 | 7 | 8 |
	|   |   |   |
 600-------------
###
Tile = React.createClass
	componentDidMount: ->
		React.findDOMNode @refs.overlay
		.addEventListener "click", =>
			if @props.gameState.isLegalMove(@props.num) and @props.gameState.canMove()
				@props.emitter.emit 'player-move', @props.num
	render: ->
		startX = 200 * Math.floor(@props.num % 3)
		startY = 200 * Math.floor(@props.num / 3)
		tileClass = classSet
			"board-tile": true
			"active": @props.gameState.lastMove is @props.num or (@props.gameState.winTiles?.indexOf(@props.num) >= 0)
		<g transform="translate(#{startX}, #{startY})">
			<rect x=5 y=5 width=190 height=190 rx=10 ry=10 className={tileClass} />
			{
				mark = @props.gameState.board[@props.num]
				if mark is -1
					<circle cx=100 cy=100 r=80 strokeWidth=10 stroke="blue" fill="none" />
				else if mark is 1
					<g>
						<line x1=20 y1=20 x2=180 y2=180 strokeWidth=10 stroke="blue" strokeLinecap="round"/>
						<line x1=20 y1=180 x2=180 y2=20 strokeWidth=10 stroke="blue" strokeLinecap="round"/>
					</g>
			}
			<rect ref="overlay" x=5 y=5 width=190 height=190 rx=10 ry=10 className="overlay" />
		</g>

module.exports = Board