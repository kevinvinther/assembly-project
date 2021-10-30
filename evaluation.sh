# Without comparisons
# 10 000 numbers
for i in {1..10000}; do echo -e "$RANDOM\t$RANDOM"; done > numbers.txt
time ./sorter numbers.txt > output_10000_1.txt
python3 check.py numbers.txt output_10000_1.txt
echo "Done 10 000, 1"
time ./sorter numbers.txt > output_10000_2.txt
python3 check.py numbers.txt output_10000_2.txt
echo "Done 10 000, 2"
time ./sorter numbers.txt > output_10000_3.txt
python3 check.py numbers.txt output_10000_3.txt
echo "Done 10 000, 3"
# 50 000 numbers
for i in {1..50000}; do echo -e "$RANDOM\t$RANDOM"; done > numbers.txt
time ./sorter numbers.txt > output_50000_1.txt
python3 check.py numbers.txt output_50000_1.txt
echo "Done 50 000, 1"
time ./sorter numbers.txt > output_50000_2.txt
python3 check.py numbers.txt output_50000_2.txt
echo "Done 50 000, 2"
time ./sorter numbers.txt > output_50000_3.txt
python3 check.py numbers.txt output_50000_3.txt
echo "Done 50 000, 3"
# 100 000 numbers
for i in {1..100000}; do echo -e "$RANDOM\t$RANDOM"; done > numbers.txt
time ./sorter numbers.txt > output_100000_1.txt
python3 check.py numbers.txt output_100000_1.txt
echo "Done 100 000, 1"
time ./sorter numbers.txt > output_100000_2.txt
python3 check.py numbers.txt output_100000_2.txt
echo "Done 100 000, 2"
time ./sorter numbers.txt > output_100000_3.txt
python3 check.py numbers.txt output_100000_3.txt
echo "Done 100 000, 3"
# 500 000 numbers
for i in {1..500000}; do echo -e "$RANDOM\t$RANDOM"; done > numbers.txt
time ./sorter numbers.txt > output_500000_1.txt
python3 check.py numbers.txt output_500000_1.txt
echo "Done 500 000, 1"
time ./sorter numbers.txt > output_500000_2.txt
python3 check.py numbers.txt output_500000_2.txt
echo "Done 500 000, 2"
time ./sorter numbers.txt > output_500000_3.txt
python3 check.py numbers.txt output_500000_3.txt
echo "Done 500 000, 3"
# 1 000 000 numbers
for i in {1..1000000}; do echo -e "$RANDOM\t$RANDOM"; done > numbers.txt
time ./sorter numbers.txt > output_1000000_1.txt
python3 check.py numbers.txt output_1000000_1.txt
echo "Done 1 000 000, 1"
time ./sorter numbers.txt > output_1000000_2.txt
python3 check.py numbers.txt output_1000000_2.txt
echo "Done 1 000 000, 2"
time ./sorter numbers.txt > output_1000000_3.txt
python3 check.py numbers.txt output_1000000_3.txt
echo "Done 1 000 000, 3"
# 5 000 000 numbers
for i in {1..5000000}; do echo -e "$RANDOM\t$RANDOM"; done > numbers.txt
time ./sorter numbers.txt > output_5000000_1.txt
python3 check.py numbers.txt output_5000000_1.txt
echo "Done 5 000 000, 1"
time ./sorter numbers.txt > output_5000000_2.txt
python3 check.py numbers.txt output_5000000_2.txt
echo "Done 5 000 000, 2"
time ./sorter numbers.txt > output_5000000_3.txt
python3 check.py numbers.txt output_5000000_3.txt
echo "Done 5 000 000, 3"