CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

rm -rf student-submission
rm -rf grading-area

mkdir grading-area

git clone $1 student-submission &> /dev/null

if [ $? -ne 0 ]; then
echo 'Failed to clone'
exit 1
fi

echo 'Finished cloning'

# Draw a picture/take notes on the directory structure that's set up after
# getting to this point

# grader ┐
#        ├─ grade.sh
#        ├─ grading-area ┐
#        │               ├─ TestListExamples.java
#        │               └─ ListExamples.java
#        │
#        ├─ student-submission ┐
#        │                     ├─ .git
#        │                     └─ ListExamples.java  ?
#        │
#        ├─ lib ┐
#        │      ├─ hamcrest.jar
#        │      └─ junit.jar
#        │
#        ├─ Server.java
#        ├─ TestListExample.java
#        └─ GradeServer.java

if ! [ -d student-submission ]; then
echo "Couldn't find submission directory"
exit 1
fi

if ! [ -f student-submission/ListExamples.java ]; then
echo "Couldn't find ListExamples.java"
exit 1
fi

cp student-submission/ListExamples.java ./grading-area
cp TestListExamples.java ./grading-area

cd grading-area

javac -cp .:../lib/hamcrest-core-1.3.jar:../lib/junit-4.13.2.jar *.java &> ./compile-result.txt
if [ $? -ne 0 ]; then
echo "Compilation error: "
cat ./compile-result.txt
exit 1
fi

java -cp .:../lib/hamcrest-core-1.3.jar:../lib/junit-4.13.2.jar org.junit.runner.JUnitCore TestListExamples &> ./test-result.txt

if [ $? -ne 0 ]; then
results=$(grep "Tests run:" ./test-result.txt)
if [ $? -ne 0 ]; then
echo "Failed to parse results"
exit 1
fi
regex='Tests run: ([0-9]+),  Failures: ([0-9]+)'

[[ $results =~ $regex ]]

run="${BASH_REMATCH[1]}"
failures="${BASH_REMATCH[2]}"
else
results=$(grep "OK (" ./test-result.txt)
if [ $? -ne 0 ]; then
echo "Failed to parse results"
exit 1
fi
regex='([0-9]+)'

[[ $results =~ $regex ]]

run="${BASH_REMATCH[1]}"
failures=0
fi

echo "Your grade is $(((100 * ($run - $failures) / $run)))%!"
echo "You passed $(($run - $failures)) test(s)!"
