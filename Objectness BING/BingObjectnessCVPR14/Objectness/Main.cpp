/************************************************************************/
/* This source code is free for both academic and industry use.         */
/* Some important information for better using the source code could be */
/* found in the project page: http://mmcheng.net/bing					*/
/************************************************************************/

#include "stdafx.h"
#include "Objectness.h"
#include "ValStructVec.h"
#include "CmShow.h"
#include "MatSerialize.h"
#include "VecSerialize.h"
#include <time.h>

// Uncomment line line 14 in Objectness.cpp to remove counting times of image reading.


void mainTrain(CStr &workingpath, CStr &trainpath, CStr &model_name);
void mainTest(CStr &workingpath, CStr &testpath, CStr &model_name);

void noValidationTest(CStr &workingpath, CStr &testpath, CStr &model_name, int resize_img);

void saveModel(Objectness obj, string path);
void loadModel(Objectness &obj, string path, string modelName);

Objectness prepareDataTrain(CStr &wkDir, CStr &trainPath, double base, int W, int NSS, int numPerSz);
void prepareDataTest(CStr &testPath, Objectness &obj);

void currentDateTime(string path, string txt);

/**
 *	Training/Test+Validation
 *
 *	argv[1] = "testval"   or   "train"
 *	argv[2] = workingpath = "new/path/to/results/" (will store results and model file)
 *	argv[3] = trainpath = "path/to/train_data/"   or   testpath = "path/to/test_data/"
 *	argv[4] = model_name = "modelFileName.txt"
 *
 *	Test without Validation
 *
 *	argv[1] = "test"
 *	argv[2] = workingpath = "new/path/to/results/" (will store results and model file)
 *	argv[3] = test_path = "path/to/test_data/"
 *	argv[4] = model_name = "modelFileName.txt"
 *	argv[5] = resize_img ---> new_size = old_size/resize_img
 */
int main(int argc, char* argv[])
{

	if(argc == 5){
		CmFile::MkDir((string)argv[2]);
		// Training
		if(!strcmp(argv[1], "train")){
			cout<<"Start training "+ (string)argv[4] +"..."<<endl;
			currentDateTime((string)argv[2], "Training start ---> ");
			mainTrain(argv[2], argv[3], argv[4]);
			currentDateTime((string)argv[2], "Training end ---> ");
			cout<<"Training finished."<<endl;
		
		// Test + Validation
		}else if(!strcmp(argv[1], "testval")){
			cout<<"Start testing on "+ (string)argv[4] +"..."<<endl;
			currentDateTime((string)argv[2], "Test start ---> ");
			mainTest(argv[2], argv[3], argv[4]);
			currentDateTime((string)argv[2], "Test end ---> ");
			cout<<"Testing finished."<<endl;

		}else{
			cout<<"Incorrect first argument. Only 'train' or 'testval' valid."<<endl;
		}

	// Test without Validation
	}else if(argc == 6){
		CmFile::MkDir((string)argv[3]);
		noValidationTest(argv[2], argv[3], argv[4], atoi(argv[5]));

	} else {
		cout<<"Incorrect number of arguments!:"<<endl;
	}

	return 0;
}


void mainTrain(CStr &workingpath, CStr &trainpath, CStr &model_name){

	////DataSetVOC::importImageNetBenchMark();
	////DataSetVOC::cvt2OpenCVYml("D:/WkDir/DetectionProposals/VOC2007/Annotations/");

	// Prepare training data
	Objectness objNess = prepareDataTrain(workingpath, trainpath, 2, 8, 2, 130);

	// Train Model
	objNess.readyTraining();
	objNess.trainObjectness();
	
	// Save model
	saveModel(objNess, workingpath+model_name);

}


void mainTest(CStr &workingpath, CStr &testpath, CStr &model_name){

	// Load model
	Objectness newObjectness;
	loadModel(newObjectness, workingpath, model_name);


	// Prepare test data
	newObjectness.initTest(testpath);
	
	// Test Model
	vector<vector<Vec4i>> boxesTests;
	newObjectness.readyTesting();
	newObjectness._props = 1;
	newObjectness.getObjBndBoxesForTestsFast(boxesTests);


	//newObjectness.getObjBndBoxesForTests(boxesTests, 250);
	//newObjectness.getRandomBoxes(boxesTests);
	//newObjectness.evaluatePerClassRecall(boxesTests, resName, 1000);
	//newObjectness.illuTestReults(boxesTests);
}


void noValidationTest(CStr &workingpath, CStr &imagepath, CStr &model_name, int resize_img){

	// Load model
	Objectness newObjectness;
	loadModel(newObjectness, workingpath, model_name);


	// Test Model
	vector<vector<Vec4i>> boxesTests;
	newObjectness._props = resize_img;
	newObjectness.getObjBndBoxesForNoValidationTestFast(imagepath, boxesTests);
}


/*
 * Preparing generic Training Data only.
 */
Objectness prepareDataTrain(CStr &wkDir, CStr &trainPath, double base, int W, int NSS, int numPerSz){

	DataSet * dataSet = new DataSet(wkDir);
	dataSet->initTrain(trainPath);
	dataSet->loadAnnotationsTrain();
	
	Objectness objNess(dataSet, base, W, NSS, numPerSz);

	return objNess;
}


/*
 * Preparing generic Training Data only.
 */
void prepareDataTest(CStr &testPath, Objectness &objNess){

	/*
	dataSet.initTest(testPath);
	dataSet.loadAnnotationsTest();
	*/

	objNess.initTest(testPath);

}


void saveModel(Objectness obj, string path){

	// create and open a character archive for output
    std::ofstream ofs(path);
	boost::archive::text_oarchive oa(ofs);
    // write class instance to archive
    oa << obj;
	// archive and stream closed when destructors are called

}

void loadModel(Objectness &newObjectness, string path, string modelName){

    // create and open an archive for input
	std::ifstream ifs(path+modelName);
    boost::archive::text_iarchive ia(ifs);
    // read class state from archive
    ia >> newObjectness;
    // archive and stream closed when destructors are called

	newObjectness._modelName = path+"Results/" + format("ObjNessB%gW%d%s", newObjectness._base, newObjectness._W, newObjectness._clrName[newObjectness._Clr]);
	newObjectness._bbResDir = path+"Results/" + format("BBoxesB%gW%d%s/", newObjectness._base, newObjectness._W, newObjectness._clrName[newObjectness._Clr]);
}


// Get current date/time, format is YYYY-MM-DD.HH:mm:ss
void currentDateTime(string path, string txt) {
    time_t     now = time(0);
    struct tm  tstruct;
    char       buf[100];
    tstruct = *localtime(&now);
    // Visit http://en.cppreference.com/w/cpp/chrono/c/strftime
    // for more information about date/time format
    strftime(buf, sizeof(buf), "%X %Y-%m-%d", &tstruct);

	path = path+"logFile.txt";

	FILE* pFile = fopen(path.c_str(), "a");
	fprintf(pFile, "%s\n", txt.c_str());
	fprintf(pFile, "%s\n\n", buf);
	fclose(pFile);

}