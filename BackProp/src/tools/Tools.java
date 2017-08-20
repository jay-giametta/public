package tools;

import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class Tools {

	public static double tanh(double x){
		return (Math.exp(2*x)-1)/(Math.exp(2*x)+1);
	}
	
	public static double sigm(double x){
		return 1/(Math.exp(-x)+1);
	}
	
	public static double sigm_prime(double x){
		return Math.exp(x)/Math.pow(1+Math.exp(x),2);
	}
	
	public static double tanh_prime(double x){
		return (1-(tanh(x)*tanh(x)));
	}
	
	public static double scaleTanh(double x, double max, double min){
		return ((x-min)/(max-min))-0.5;
	}
	
	public static double unscaleTanh(double x, double max, double min){
		return ((x+0.5)*(max-min))+min;
	}
	
	public static double scaleSigm(double x, double max, double min){
		return (x-min)/(2*(max-min))+0.25;
	}
	
	public static double unscaleSigm(double x, double max, double min){
		return (x-0.25)*(2*(max-min))+min;
	}
	
	public static void writeCSV(ArrayList<double[]> data, String fileName){
		FileWriter writer;
		try {
			writer = new FileWriter(fileName);
		for(int t=0;t<data.size();t++){
			for(int i=0;i<data.get(t).length;i++){
				writer.append(Double.toString(data.get(t)[i]));
				if(i<data.get(t).length-1) writer.append(",");
				else writer.append("\n");
			}
		}
		writer.flush();
	    writer.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static double classifyIris(double[] y){
		double label=-1;
		double max=Double.MIN_VALUE;
		for(int i=0;i<y.length;i++){
			if(y[i]>max){
				label=i;
				max=y[i];
			}
		}
		return label;
	}
	
	public static double[][] arrayMerge(double[][] first, double[][] second, double[][] third, double[][] fourth) {
	    List<double[]> all = new ArrayList<double[]>(first.length + second.length + third.length + fourth.length);
	    for(int i=0;i<first.length;i++){
	    	all.add(first[i]);
	    }
	    for(int i=0;i<first.length;i++){
	    	all.add(second[i]);
	    }
	    for(int i=0;i<first.length;i++){
	    	all.add(third[i]);
	    }
	    for(int i=0;i<first.length;i++){
	    	all.add(fourth[i]);
	    }
	    return all.toArray(new double[all.size()][first[0].length]);
	}
}
