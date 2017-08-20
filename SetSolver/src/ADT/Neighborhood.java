package ADT;

public class Neighborhood extends LocationGroup implements Comparable<Neighborhood>{
	
	private double totalEnergy;	
	private String name;
	
	//constructor
	public Neighborhood(String name){
		this.name=name;
		totalEnergy = 1;
	}
	
	//get the amount of energy associated with placing a windmill in this neighborhood
	public double getEnergy(){
		return totalEnergy;
	}
	
	//set the amount of energy associated with placing a windmill in this neighborhood
	public void setEnergy(double energy){
		totalEnergy = energy;
	}
	
	@Override
	public String toString(){
		return name;
	}

	@Override
	public int compareTo(Neighborhood n) {
		if(this.getEnergy() > n.getEnergy()) return -1;
		else if(this.getEnergy() < n.getEnergy()) return 1;
		else return this.toString().compareTo(n.toString());
	}
}