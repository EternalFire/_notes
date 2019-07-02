#pragma once
#include <iostream>
#include <thread>
#include <ctime>
#include <sstream>
#include <mutex>

using namespace std;

std::mutex m;
static string Answer[11];
int AnswerNum = 0;

class Student {
public:
	Student() {}
	~Student() {}
	Student(int _id) {
		id = _id;
	}

	int id = 0;
};

void beginnerTraining(Student student)
{	

	int sum = 0;
	for (int i = 1; i <= 100; i++)
	{
		sum += i;
	}
	cout << "student id = " << student.id << " finish training, sum = " << sum << endl;
}

void answerTime(Student student)
{
	std::lock_guard<std::mutex> lockGuard(m);

	time_t now = time(0);
	tm *gmtm = gmtime(&now);
	char* dt = asctime(gmtm);

	stringstream ss;
	ss << "student id = " << student.id <<  " say time is " << dt;

	Answer[student.id] = ss.str();
	cout << "student id = " << student.id << " done" << endl;
	AnswerNum++;
}

void studentsAnswerTime()
{
	cout << "start studentsAnswerTime" << endl;
	for (int i = 1; i <= 10; i++)
	{
		Student student(i);
		std::thread t0(answerTime, student);
		t0.detach();
		//t0.join();
	}

	while (AnswerNum < 10) {
		;
	}

	for (int i = 1; i <= 10; i++)
	{
		cout << "i: " << i << " answer: " << Answer[i] << endl;
	}
	cout << "end studentsAnswerTime" << endl;
}

void studentsTraining()
{
	cout << "start studentsTraining" << endl;
	//std::thread tArray[10];
	for (int i = 1; i <= 10; i++)
	{
		cout << "for " << (i) << endl;
		Student student(i);
		std::thread t0(beginnerTraining, student);

		//t0.detach();
		t0.join();		

		//t0.swap(tArray[i - 1]);
	}

	//for (int i = 1; i <= 10; i++)
	//{
	//	tArray[i - 1].join();
	//}

	cout << "end studentsTraining" << endl;
}

void Play_thread()
{
	cout << "Start Play_thread" << endl;
	unsigned int num = std::thread::hardware_concurrency();
	cout << "hardware_concurrency = " << std::thread::hardware_concurrency() << endl;
	
	studentsTraining();

	//studentsAnswerTime();
	
	cout << "End Play_thread" << endl;
}