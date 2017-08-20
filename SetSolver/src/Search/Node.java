package Search;

import java.util.TreeSet;
import java.util.Set;

import ADT.Neighborhood;

public class Node implements Comparable<Node>{
	
	private double benefit;			//opposite of a cost value in most searches
	private Node parent;			//the node that generated this child state
	private Neighborhood N;			//the neighborhood represented by this node
	private Set<Neighborhood> O;	//the solution that this node is a part of
	private double z;				//the cost of the solution above
	private String path;			//a string representation of the solution
	
	//constructor
	public Node(Neighborhood N, Node parent){
		this.N = N;
		this.parent = parent;
		benefit = N.getEnergy();
		O = new TreeSet<Neighborhood>();
		path = "";
		if(parent!=null){
			O.addAll(parent.getSolution());
			z = parent.getSolutionBenefit();
			path += parent.getPath() + " ";
		}
		O.add(N);
		path += N.toString() + " ";
		z += benefit;
	}
	
	//returns the string representation of the solution
	public String getPath(){
		return path;
	}
	
	//returns the benefit for the neighborhood represented by this node
	public double getBenefit(){
		return benefit;
	}
	
	//returns the node that generated this
	public Node getParent(){
		return parent;
	}
	
	//returns the neighborhood represented by this node
	public Neighborhood getNeighborhood(){
		return N;
	}
	
	//determines if this node is the root
	public boolean isRoot(){
		if(parent==null)return true;
		else return false;
	}
	
	//returns the solution that this node is a part of
	public Set<Neighborhood> getSolution(){
		return O;
	}
	
	//returns the cost of the above solution
	public double getSolutionBenefit(){
		return z;
	}

	@Override
	public int compareTo(Node n) {
		if(z > n.getSolutionBenefit()) return -1;
		else if(z < n.getSolutionBenefit()) return 1;
		else if(O.size() > n.getSolution().size()) return 1;
		else if(O.size() < n.getSolution().size()) return -1;
		else if(O.containsAll(n.getSolution()) && n.getSolution().containsAll(O))return 0;
		else return 1;
	}

}
