package Search;

import java.util.LinkedList;
import java.util.Queue;
import java.util.Set;
import java.util.TreeSet;

import Utilities.SetOps;
import ADT.Environment;
import ADT.Neighborhood;

//A breadth first search for the AEO problem
public class BFS {
	
	private Node v;						//the current node	
	private Environment E;				//E from AEO
	private Set<Neighborhood> N;		//N from AEO
	private Set<Neighborhood> O_star;	//the best solution so far
	private double z_hat;				//the benefit of the best solution
	private Queue<Node> next;			//the search queue
	private Set<Node> visitedList;
	
	//constructor
	public BFS(Environment E, Set<Neighborhood> N){
		
		this.E = E;
		this.N = N;
		
		z_hat=0;	
		next = new LinkedList<Node>();
		visitedList = new TreeSet<Node>();
		
	}
	
	public Set<Neighborhood> solve(){
		int visited = 0;
		long time = System.currentTimeMillis();
		
		//add all of the neighborhoods to the queue
		for(Neighborhood n:N){
			next.add(new Node(n,null));
		}
		
		//while there are still nodes on the search queue
		while(next.peek()!=null){
			v = next.poll();
			if(!visitedList.contains(v)){
				visited++;
				
				System.out.printf("%4d %5s %10s %6s",visited,"Path:",v.getPath(), "Queue:");
				for(Node q:next){
					System.out.printf("%10s",q.getSolution());
				}
				
				if(!v.isRoot())visitedList.add(v);
				
				//add its children to the queue
				for(Neighborhood n:N){
					if(SetOps.intersect(SetOps.unionAll(v.getSolution()),n.getLocations()).isEmpty()){
						next.add(new Node(n,v));
					}
				}
				
				//check if the current node gives a solution
				if(SetOps.equals(SetOps.unionAll(v.getSolution()),E.getLocations())){
					
					//check if the solution is better than what we had before
					if(v.getSolutionBenefit() > z_hat){
					
						z_hat = v.getSolutionBenefit();
						O_star = v.getSolution();
						
						System.out.print("*");
					}
				}
				System.out.println();
			}
		}
		System.out.println("Nodes visited: " + visited);
		System.out.println("Search time: " + (System.currentTimeMillis() - time) + "ms");
		
		//return the best solution found
		return O_star;
	}

}
