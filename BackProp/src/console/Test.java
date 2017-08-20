package console;

import java.util.ArrayList;

import network.BackProp;
import tools.Tools;

public class Test {

	public static void main(String[] args) {
				
		
		double x[][]=new double[100][1];
		double D[][]=new double[100][1];
		
		//f(1/x) for x=0 to 10 by 1/10
		for(int i=0;i<100;i++){
			x[i][0]=(i+1)/10.0;
			D[i][0]=1/x[i][0];
		}
		
		/*
		CSV iris = new CSV("iris.csv");
		CSV irisLab = new CSV("iris.lab.csv");
		
		double x[][]=iris.matrix;
		double D[][]=irisLab.matrix;
		*/
		
		int T = 60000;
		int NPE[]={x[0].length,12,6,D[0].length};
		int L = NPE.length;
		double alpha=1e-1;		
		
		double Dmax=Double.MIN_VALUE;
		double Dmin=Double.MAX_VALUE;
		
		for(int i=0;i<D.length;i++){
			for(int j=0;j<D[i].length;j++){
				if(D[i][0]>Dmax)Dmax=D[i][j];
				if(D[i][0]<Dmin)Dmin=D[i][j];
			}
		}
		
		for(int i=0;i<D.length;i++){
			//D[i][0]=Tools.scaleSigm(D[i][0],Dmax,Dmin);
			D[i][0]=Tools.scaleTanh(D[i][0],Dmax,Dmin);
		}
		
		/*
		//-----------------------------------crossval-------------------------------------//
		ArrayList<Integer> shuffled = new ArrayList<Integer>();
		for(int k=0;k<x.length;k++){
		    shuffled.add(k);
		}
		Collections.shuffle(shuffled);
		
		//setup folds
		double[][][] foldsTest=new double[5][x.length/5][x[0].length];
		double[][][] foldsTestLab=new double[5][x.length/5][D[0].length];
		
		for(int i=0;i<shuffled.size();i++){
			if(i<x.length/5){
				foldsTest[0][i]=x[shuffled.get(i)];
				foldsTestLab[0][i]=D[shuffled.get(i)];
			}
			else if(i<2*x.length/5){
				foldsTest[1][i-x.length/5]=x[shuffled.get(i)];
				foldsTestLab[1][i-x.length/5]=D[shuffled.get(i)];
			}
			else if(i<3*x.length/5){
				foldsTest[2][i-2*x.length/5]=x[shuffled.get(i)];
				foldsTestLab[2][i-2*x.length/5]=D[shuffled.get(i)];
			}
			else if(i<4*x.length/5){
				foldsTest[3][i-3*x.length/5]=x[shuffled.get(i)];
				foldsTestLab[3][i-3*x.length/5]=D[shuffled.get(i)];
			}
			else{
				foldsTest[4][i-4*x.length/5]=x[shuffled.get(i)];
				foldsTestLab[4][i-4*x.length/5]=D[shuffled.get(i)];
			}
		}
		
		//---------------------------------create crossval training sets----------------------------//
		double[][][] foldsTrain=new double[5][4*x.length/5][x[0].length];
		double[][][] foldsTrainLab=new double[5][4*x.length/5][D[0].length];
		foldsTrain[0]=Tools.arrayMerge(foldsTest[1], foldsTest[2], foldsTest[3], foldsTest[4]);
		foldsTrain[1]=Tools.arrayMerge(foldsTest[0], foldsTest[2], foldsTest[3], foldsTest[4]);
		foldsTrain[2]=Tools.arrayMerge(foldsTest[0], foldsTest[1], foldsTest[3], foldsTest[4]);
		foldsTrain[3]=Tools.arrayMerge(foldsTest[0], foldsTest[1], foldsTest[2], foldsTest[4]);
		foldsTrain[4]=Tools.arrayMerge(foldsTest[0], foldsTest[1], foldsTest[2], foldsTest[3]);
		foldsTrainLab[0]=Tools.arrayMerge(foldsTestLab[1], foldsTestLab[2], foldsTestLab[3], foldsTestLab[4]);
		foldsTrainLab[1]=Tools.arrayMerge(foldsTestLab[0], foldsTestLab[2], foldsTestLab[3], foldsTestLab[4]);
		foldsTrainLab[2]=Tools.arrayMerge(foldsTestLab[0], foldsTestLab[1], foldsTestLab[3], foldsTestLab[4]);
		foldsTrainLab[3]=Tools.arrayMerge(foldsTestLab[0], foldsTestLab[1], foldsTestLab[2], foldsTestLab[4]);
		foldsTrainLab[4]=Tools.arrayMerge(foldsTestLab[0], foldsTestLab[1], foldsTestLab[2], foldsTestLab[3]);
		*/
		
		//create a neuralNet with random weights
		BackProp net = new BackProp(L,NPE);
		
		//write convergence info
		ArrayList<double[]> convergence = net.backprop(x,D,alpha,T);
		Tools.writeCSV(convergence,"convergence.csv");
		
		/*
		//---------------------------------train crossval models----------------------------//
		NeuralNet net1 = new NeuralNet(L,NPE);
		NeuralNet net2 = new NeuralNet(L,NPE);
		NeuralNet net3 = new NeuralNet(L,NPE);
		NeuralNet net4 = new NeuralNet(L,NPE);
		NeuralNet net5 = new NeuralNet(L,NPE);
		
		ArrayList<double[]> convergence1 = net1.backprop(foldsTrain[0],foldsTrainLab[0],alpha,T);
		Tools.writeCSV(convergence1,"convergence1.csv");
		ArrayList<double[]> convergence2 = net2.backprop(foldsTrain[1],foldsTrainLab[1],alpha,T);
		Tools.writeCSV(convergence2,"convergence2.csv");
		ArrayList<double[]> convergence3 = net3.backprop(foldsTrain[2],foldsTrainLab[2],alpha,T);
		Tools.writeCSV(convergence3,"convergence3.csv");
		ArrayList<double[]> convergence4 = net4.backprop(foldsTrain[3],foldsTrainLab[3],alpha,T);
		Tools.writeCSV(convergence4,"convergence4.csv");
		ArrayList<double[]> convergence5 = net5.backprop(foldsTrain[4],foldsTrainLab[4],alpha,T);
		Tools.writeCSV(convergence5,"convergence5.csv");
		*/
		
		//write model results
		ArrayList<double[]> results = new ArrayList<double[]>();
		for(int k=0;k<x.length;k++){
			
			double[] y=net.feedForward(x[k]).get(L-1);
			results.add(new double[1]);
			results.add(new double[y.length]);
			for(int i=0;i<y.length;i++){
				results.get(k)[i]=Tools.unscaleTanh(y[i],Dmax,Dmin);
				//results.get(k)[i]=Tools.unscaleSigm(y[i],Dmax,Dmin);
			}
		}
		Tools.writeCSV(results, "results.csv");
		
		System.out.println("10.5 " + Tools.unscaleTanh(net.feedForward(new double[]{10.5}).get(L-1)[0],Dmax,Dmin));
		System.out.println("10.75 " + Tools.unscaleTanh(net.feedForward(new double[]{10.75}).get(L-1)[0],Dmax,Dmin));
		System.out.println("20.0 " + Tools.unscaleTanh(net.feedForward(new double[]{11.0}).get(L-1)[0],Dmax,Dmin));
		
		/*
		//-----------------------------------write crossval results-----------------------------//
		ArrayList<double[]> results1 = new ArrayList<double[]>();
		for(int k=0;k<foldsTest[0].length;k++){
			double[] truth=new double[2];
			truth[0]=Tools.classifyIris(foldsTestLab[0][k]);
			truth[1]=Tools.classifyIris(net1.feedForward(foldsTest[0][k]).get(L-1));
			results1.add(truth);
		}
		Tools.writeCSV(results1, "results1.csv");
		
		ArrayList<double[]> results2 = new ArrayList<double[]>();
		for(int k=0;k<foldsTest[0].length;k++){
			double[] truth=new double[2];
			truth[0]=Tools.classifyIris(foldsTestLab[1][k]);
			truth[1]=Tools.classifyIris(net2.feedForward(foldsTest[1][k]).get(L-1));
			results2.add(truth);
		}
		Tools.writeCSV(results2, "results2.csv");
		
		ArrayList<double[]> results3 = new ArrayList<double[]>();
		for(int k=0;k<foldsTest[0].length;k++){
			double[] truth=new double[2];
			truth[0]=Tools.classifyIris(foldsTestLab[2][k]);
			truth[1]=Tools.classifyIris(net3.feedForward(foldsTest[2][k]).get(L-1));
			results3.add(truth);
		}
		Tools.writeCSV(results3, "results3.csv");
		
		ArrayList<double[]> results4 = new ArrayList<double[]>();
		for(int k=0;k<foldsTest[3].length;k++){
			double[] truth=new double[2];
			truth[0]=Tools.classifyIris(foldsTestLab[3][k]);
			truth[1]=Tools.classifyIris(net4.feedForward(foldsTest[3][k]).get(L-1));
			results4.add(truth);
		}
		Tools.writeCSV(results4, "results4.csv");
		
		ArrayList<double[]> results5 = new ArrayList<double[]>();
		for(int k=0;k<foldsTest[4].length;k++){
			double[] truth=new double[2];
			truth[0]=Tools.classifyIris(foldsTestLab[4][k]);
			truth[1]=Tools.classifyIris(net5.feedForward(foldsTest[4][k]).get(L-1));
			results5.add(truth);
		}
		Tools.writeCSV(results5, "results5.csv");
		*/
	}

}
