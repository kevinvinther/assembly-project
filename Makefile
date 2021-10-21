OBJS = sorter.o utils.o
ASFLAGS = -gstabs

sorter: $(OBJS)
	ld -o sorter $^

.PHONY: clean # 'clean' is not a real file
clean:        # so it should be declared phony
	rm -f *.o sorter
