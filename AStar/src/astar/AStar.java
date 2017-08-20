package astar;

import java.util.HashMap;
import java.util.PriorityQueue;

/**
 * An A* search implementation for the Rush Hour board game.
 *
 * @author Jay Giametta
 *
 * @version 1
 */
public class AStar implements Search{
	
	//The board to be used for the search
	private final Board board;
	//The node count to be returned upon search completion
	private int nodesVisited;
	
	/**
	   * Constructs a new instance of {@link AStar} required to complete a search.
	   *
	   * @param board
	   *          The initial board configuration
	   * @throws NullPointerException
	   *           if board parameter is null
	   */
	public AStar(Board board)throws NullPointerException{
		if (board == null) throw new NullPointerException();
		else{
			this.board = board;
			nodesVisited = 0;
		}
	}
	/**
	   * Returns an optimal move sequence that solves the given board configuration (if one exists).
	   * Otherwise returns null if no solution exists.
	   *
	   * @return A {@link Move} list.
	   */	
	@Override
	public Move findMoves(){
		//Construct a root node
		final Node start = new Node(board,null,null);
		//Stores previously visited nodes
		final HashMap<String,Node> closedMap = new HashMap<>();
		//Stores nodes that are visible, but not yet visited
		final HashMap<String,Node> openMap = new HashMap<>();
		//Stores visible nodes in order of best fScore
		final PriorityQueue<Node> openSet = new PriorityQueue<>();
		
		//Add the root node to the visible sets
		openSet.add(start);
		openMap.put(start.toString(), start);
		
		//The cost to get to the root node
		start.setGScore(0);
		//The estimated cost from the root node to the goal
		start.setFScore(start.getGScore() + start.getHScore());
		
		//Run until there are no unvisited nodes or we find a goal state
		while(openSet.size() != 0){
			//Get the node on top of the priority queue
			Node current = openSet.peek();
			//Store the current nodes board and key/state
			Board currentBoard = current.getBoard();
			String currentKey = current.toString();
			
			//Increment the number of visited nodes.
			nodesVisited++;	
			
			//Check for goal state
			if(current.isGoal()) return current.getParentEdge();
			
			//Remove the node from the visible/unvisited sets
			openSet.remove(current);
			openMap.remove(currentKey);
			
			//Add the node to the visited set
			closedMap.put(currentKey, current);
			
			//Get valid moves for the current node
			Move edgeToNeighbor = currentBoard.genMoves();	
			//Store new nodes for each move that creates either a new or more
			//promising game state.
			while(edgeToNeighbor != null){
				//Make a valid move then get the resulting board
				currentBoard.makeMove(edgeToNeighbor);
				Node neighbor = new Node(currentBoard, current, edgeToNeighbor);
				String neighborKey = neighbor.toString();
				//Reverse the previously made move to ensure the current
				//board state isn't lost
				currentBoard.reverseMove(edgeToNeighbor);
				//Calculate the new nodes gScore (cost of each move = 1)
				int neighborGScore = neighbor.setGScore(current.getGScore() + 1);
				//Check to see if we've visited this board state
				if(!closedMap.containsKey(neighborKey)){
					//If the board state is already in the visible set get it
					Node dupInOpen = openMap.get(neighborKey);
					//If the board state has never been seen calculate it's fScore and
					//add it to the unvisited list
					if(dupInOpen == null){
						neighbor.setFScore(neighborGScore + neighbor.getHScore());
						openSet.add(neighbor);
						openMap.put(neighborKey,neighbor);
					}
					//If the board state is already in the unvisited list, but this one is more
					//promising only keep this board state
					else if(dupInOpen.getGScore() > neighborGScore){
						openSet.remove(dupInOpen);
						openMap.remove(neighborKey);
						
						neighbor.setFScore(neighborGScore + neighbor.getHScore());
						openSet.add(neighbor);
						openMap.put(neighborKey,neighbor);
					}
				}
				//Move on to the next valid move from the current board
				edgeToNeighbor = edgeToNeighbor.next;
			}	
		}	
		//Return null if no valid move sequence is found
		return null;
	}
	/**
	   * The number of nodes visited in the search.
	   *
	   * @return A {@link long} containing the number of visited nodes.
	   */	
	@Override
	public long nodeCount() {
		return nodesVisited;
	}
}
