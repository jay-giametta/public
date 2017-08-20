package network;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;

import tools.Tools;

public class BackProp {

	ArrayList<double [][]> w;
	Random rand;
	
	int L;
	int[] NPE;
	ArrayList<double[]> NET;
	
	public BackProp(int L, int[] NPE){
		
		//initialize network info
		this.L=L;
		this.NPE=NPE;
		
		//initialize weights
		w = new ArrayList<double[][]>();
		
		//initialize rng
		rand = new Random();
		
		//filler for input layer
		w.add(new double[1][1]);
		
		//create weight matrices for each layer
		for(int l=1;l<L;l++){
			w.add(new double[NPE[l]][NPE[l-1]]);
		}
		
		//Step 1: randomly populate weights
		for(int l=0;l<L;l++){
			for(int i=0;i<w.get(l).length;i++){
				for(int j=0;j<w.get(l)[i].length;j++){
					w.get(l)[i][j]=rand.nextDouble();
				}
			}
		}		
	}
	
	//adjust network weights based on input matrix x and label matrix D
	public ArrayList<double[]> feedForward(double[] x){
		
		NET = new ArrayList<double[]>();
		
		//initialize y matrices
		ArrayList<double[]> y = new ArrayList<double[]>();
		
		for(int l=0;l<L;l++){
			NET.add(new double[NPE[l]]);
			y.add(new double[NPE[l]]);
		}
				
		//for each layer of PEs
		for(int l=0;l<L;l++){
			
			//for each PE
			for(int i=0;i<NPE[l];i++){
				
				//special case for input layer
				if(l==0){
					y.get(l)[i]=x[i];
				}
				
				//all other layers
				else{
					//summation value
					double sum=0;
					
					for(int j=0;j<w.get(l)[i].length;j++){
						sum+=w.get(l)[i][j]*y.get(l-1)[j];
					}
					NET.get(l)[i]=sum;
					y.get(l)[i]=Tools.tanh(NET.get(l)[i]);
					//y.get(l)[i]=Tools.sigm(NET.get(l)[i]);
				}		
			}			
		}
		return y;
	}
	
	public ArrayList<double[]>backprop(double[][] x, double[][] D, double alpha, int T){
		
		ArrayList<Integer> shuffled = new ArrayList<Integer>();
		for(int k=0;k<x.length;k++){
		    shuffled.add(k);
		}
		
		ArrayList<double[]> RMSE = new ArrayList<double[]>();
		for(int t=0;t<T;t++){
			RMSE.add(new double[D[0].length]);
		}
		
		//Step 2: initialize time counter	
		for(int t=0;t<T;t++){
			//randomize input
			Collections.shuffle(shuffled);
			
			for(int k : shuffled){
				//Step 3: propagate the input forward
				ArrayList<double[]> y=feedForward(x[k]);
				
				//update error
				for(int i=0;i<y.get(L-1).length;i++){
					double sqError=Math.pow(D[k][i]-y.get(L-1)[i],2);
					RMSE.get(t)[i]+=sqError/D.length;
				}
				
				ArrayList<double[]> delta=new ArrayList<double[]>();
				
				//initialize delta list
				for(int l=0;l<L;l++){
					delta.add(new double[y.get(l).length]);
				}
				
				//compute deltas
				for(int l=L-1;l>0;l--){
					for(int i=0;i<y.get(l).length;i++){
						//Step 4: compute delta for output
						if(l==L-1){
							delta.get(l)[i]=(D[k][i]-y.get(l)[i])*Tools.tanh_prime(NET.get(l)[i]);
							//delta.get(l)[i]=(D[k][i]-y.get(l)[i])*Tools.sigm_prime(NET.get(l)[i]);
						}
						
						//Step 5: calculate delta for hidden layers
						else{
							double sum=0;
							for(int z=0;z<y.get(l+1).length;z++){
								//Sum weighted deltas of connecting PEs from l+1
								sum+=w.get(l+1)[z][i]*delta.get(l+1)[z];
							}
							delta.get(l)[i]=Tools.tanh_prime(NET.get(l)[i])*sum;
							//delta.get(l)[i]=Tools.sigm_prime(NET.get(l)[i])*sum;
						}
					}
				}
				
				//Step 6: repeat for K observations (skipped for K=1)
				//Step 7: update weights
				for(int l=L-1;l>0;l--){
					for(int i=0;i<w.get(l).length;i++){
						for(int j=0;j<w.get(l)[i].length;j++){
							w.get(l)[i][j]+=alpha*delta.get(l)[i]*y.get(l-1)[j];
						}
					}
				}
			}
			for(int i=0;i<RMSE.get(t).length;i++){
				RMSE.get(t)[i]=Math.sqrt(RMSE.get(t)[i]);
			}
			if(t%(T/20)==0){
				alpha=alpha*0.8;
			}
		}
		return RMSE;
	}
}
