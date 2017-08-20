package tools;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;


public class CSV {
	String fileName;
	String[] header;
	double[][] matrix;
	int numRows;
	int numCols;
	
	public CSV(String fileName){
		this.fileName = fileName;
		numRows = -1;
		numCols = 0;
		read();
	}
	
	public void read(){
		BufferedReader reader = null;
		String line = "";
		String split = ",";
		
		try{
			reader = new BufferedReader(new FileReader(fileName));
			while((line = reader.readLine()) != null){
				numRows++;
				if(numCols < line.split(split).length){
					numCols = line.split(split).length;
				}
			}
		} 
		catch (FileNotFoundException e){
			e.printStackTrace();
		}
		catch (IOException e){
			e.printStackTrace();
		}
		
		header = new String[numCols];
		matrix = new double[numRows][numCols];
		
		try{
			reader = new BufferedReader(new FileReader(fileName));
			header = reader.readLine().split(split);
			
			for(int i = 0;i < numRows;i++){
				line = reader.readLine();
				String[] rowString = line.split(split);
				
				for(int j = 0;j < numCols;j++){
					matrix[i][j] = Double.parseDouble(rowString[j]);
				}
			}
		} 
		catch (FileNotFoundException e){
			e.printStackTrace();
		}
		catch (IOException e){
			e.printStackTrace();
		}
	}
}
