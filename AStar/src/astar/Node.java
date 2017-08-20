package astar;

public class Node implements Comparable<Node>{
	private final Board board;
	private Node parent = null;
	private Move parentEdge = null;
	private int gScore = 0;
	private int fScore = 0;
	private String key = "";
	
	public Node (Board board, Node parent, Move parentEdge) {
		this.board = new Board(board);
		
		this.parent = parent;
		
		if(parentEdge != null){
			this.parentEdge = new Move(parentEdge);
			this.parentEdge.next = parent.getParentEdge();
		}
		
		int[][] theBoard = board.theBoard;
		for(int x = 0; x < Board.BOARD_SIZE; x++){
			for(int y = 0; y < Board.BOARD_SIZE; y++){
				key = key + theBoard[x][y];
			}
		}
	}	
	public Node getParent(){
		return parent;
	}
	public Move getParentEdge(){
		return parentEdge;
	}
	public Board getBoard(){
		return board;
	}
	public int setGScore(int score) {
		gScore = score;	
		return gScore;
	}
	public int getGScore(){
		return gScore;
	}
	public void setFScore(int score) {
		fScore = score;
	}
	public int getFScore(){
		return fScore;
	}
	//Returns the heuristic value for a node, based on the number of vehicles that must
	//be moved to reach a goal state.
	public int getHScore(){
		//No vehicles need to be moved.
		if(isGoal()) return 0;
		//We have to move at least 1 vehicle.
		int minNumMoves = 1;
		//Add a move for each vehicle between X0 and the goal
		Piece goalPiece = board.piece_list[board.findPiece("X0")];
		for(int x = goalPiece.x + 2;x < Board.BOARD_SIZE;x++){
			if((board.theBoard[x][Board.BOARD_EXIT_Y] != -1)) minNumMoves++;
		}	
		return minNumMoves;
	}
	// Checks whether or not a node produces a goal state.
	public boolean isGoal(){
		//Check whether or not the X0 car is at the exit location
		if(board.theBoard[Board.BOARD_EXIT_X][Board.BOARD_EXIT_Y] 
				== board.findPiece("X0")){
			return true;
		}
		else return false;
	}
	@Override
	public String toString(){
		return key;
	}
	@Override
	public int compareTo(Node n) {
		if(this.toString().equals(n.toString())) return 0;
		else if(this.getFScore() - n.getFScore() > 0) return 1;
		else return -1;
	}
	@Override
	public boolean equals(Object obj) {
		if(this.toString().equals(((Node)obj).toString())) return true;
		else return false;
	}
}
