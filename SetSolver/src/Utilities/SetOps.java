package Utilities;

import java.util.TreeSet;
import java.util.Set;

import ADT.Neighborhood;

public class SetOps {
	//a simple set union method
	public static Set<Integer> union(Set<Integer> s1, Set<Integer> s2){
		
		Set<Integer> setUnion = new TreeSet<Integer>();
		
		setUnion.addAll(s1);
		setUnion.addAll(s2);
		
		return setUnion;	
	}
	
	//a simple set intersection method
	public static Set<Integer> intersect(Set<Integer> s1, Set<Integer> s2){
		
		Set<Integer> setIntersect = new TreeSet<Integer>();
		
		setIntersect.addAll(s1);
		setIntersect.retainAll(s2);
		
		return setIntersect;	
	}
	
	//determines whether s2 is a subset of s1
	public static boolean subset(Set<Integer> s1, Set<Integer> s2){
		
		return s1.containsAll(s2);	
	}
	
	//determines if two sets are equal
	public static boolean equals(Set<Integer> s1, Set<Integer> s2){
		
		return (s1.containsAll(s2) && s2.containsAll(s1));
	}
	
	//computes the union of a set of neighborhoods
	public static Set<Integer> unionAll(Set<Neighborhood> group){
		
		Set<Integer> groupUnion = new TreeSet<Integer>();
		
		for(Neighborhood n:group){
			groupUnion.addAll(n.getLocations());
		}
		
		return groupUnion;
	}

}
