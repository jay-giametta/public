package ADT;

import java.util.TreeSet;
import java.util.Set;

//superclass for environment and neighborhood
public class LocationGroup {
	
	//locations are represented by integers
	private Set<Integer> locations;

	//constructor
	public LocationGroup(){
		locations = new TreeSet<Integer>();
	}
	
	//optional set constructor
	public LocationGroup(Set<Integer> locations){	
		this.locations = locations;	
	}
	
	//get the locations in the group
	public Set<Integer> getLocations(){
		return locations;
	}
	
	//add a location to the group
	public void addLocation(int loc){
		locations.add(loc);
	}
	
	
}