package Console;

import java.util.TreeSet;
import java.util.Set;

import Search.BFS;
import ADT.Environment;
import ADT.Neighborhood;

public class SetSolver {

	public static void main(String[] args) {
		
		//Input the problem to be solved
		//E = {1,2,3,4,5,6,7,8,9,10}
		Environment E = new Environment();
		E.addLocation(1);
		E.addLocation(2);
		E.addLocation(3);
		E.addLocation(4);
		E.addLocation(5);
		E.addLocation(6);
		
		//{1,2,3},10
		Neighborhood N1 = new Neighborhood("1");
		N1.addLocation(1);
		N1.addLocation(2);
		N1.addLocation(3);
		N1.setEnergy(10);
		
		//{4,5},3
		Neighborhood N2 = new Neighborhood("2");
		N2.addLocation(4);
		N2.addLocation(5);
		N2.setEnergy(3);
		
		//{4,5,6},3
		Neighborhood N3 = new Neighborhood("3");
		N3.addLocation(4);
		N3.addLocation(5);
		N3.addLocation(6);
		N3.setEnergy(3);
		
		//{4,5,6},2
		Neighborhood N4 = new Neighborhood("4");
		N4.addLocation(4);
		N4.addLocation(5);
		N4.addLocation(6);
		N4.setEnergy(2);
		
		//{6},2
		Neighborhood N5 = new Neighborhood("5");
		N5.addLocation(6);
		N5.setEnergy(2);

		//Group the neighborhoods into a single set of sets
		Set<Neighborhood> neighborhoods = new TreeSet<Neighborhood>();
		neighborhoods.add(N1);
		neighborhoods.add(N2);
		neighborhoods.add(N3);
		neighborhoods.add(N4);
		neighborhoods.add(N5);
		
		//Run BFS on the problem
		Set<Neighborhood> solution = new BFS(E,neighborhoods).solve();
		
		//Output no solution if nothing is returned
		if(solution==null)System.out.println("No solution");
		
		//Output the solution information if one is returned
		else{
			double totalEnergy = 0;
			for(Neighborhood n:solution){
				totalEnergy += n.getEnergy();
			}
			
			System.out.println("Neighborhoods: " + solution);
			System.out.println("Total energy: " + totalEnergy);
		}	
		
	}

}
