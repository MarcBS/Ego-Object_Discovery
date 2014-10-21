#include "StdAfx.h"
#include "DataSet.h"


DataSet::DataSet(void)
{
}


DataSet::~DataSet(void)
{
}


DataSet::DataSet(CStr &_wkDir)
{
	wkDir = _wkDir;
	resDir = wkDir + "Results/";
	localDir = wkDir + "Local/";
	CmFile::MkDir(resDir);
	CmFile::MkDir(localDir);
}


void DataSet::initTrain(CStr &trainPath){
	
	imgPathTrain = trainPath + "JPEGImages/%s.jpg";
	annoPathTrain = trainPath + "Annotations/%s.yml";
	trainSet = CmFile::loadStrList(trainPath + "names.txt");
	classNames = CmFile::loadStrList(trainPath + "class.txt");
	trainNum = trainSet.size();
}

void DataSet::initTest(CStr &testPath){
	
	imgPathTest = testPath + "JPEGImages/%s.jpg";
	annoPathTest = testPath + "Annotations/%s.yml";
	testSet = CmFile::loadStrList(testPath + "names.txt");
	testNum = testSet.size();
}


void DataSet::loadAnnotationsTrain()
{
	gtTrainBoxes.resize(trainNum);
	gtTrainClsIdx.resize(trainNum);
	for (int i = 0; i < trainNum; i++){
		if (!DataSetVOC::loadBBoxesPath(trainSet[i], gtTrainBoxes[i], gtTrainClsIdx[i], annoPathTrain))
			return;
	}
}

void DataSet::loadAnnotationsTest()
{
	gtTestBoxes.resize(testNum);
	gtTestClsIdx.resize(testNum);
	for (int i = 0; i < testNum; i++){
		if(!DataSetVOC::loadBBoxesPath(testSet[i], gtTestBoxes[i], gtTestClsIdx[i], annoPathTest))
			return;
	}
}