###########################################################
# Makefile
# History:
#     2013-05-29  Dennis  Create
###########################################################

CC     = gcc
FLAGS += -Wall -DLINUX
LIBS   = -lpthread -lrt

TARGET = test
OBJ_SRC= test.c thread_pool.c
OBJ_INC=
#OBJS   = common.o thread_pool.o
OBJS  := $(OBJ_SRC:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(FLAGS) -o $@ $^ $(LIBS)

# Using condition compile: make SPECIAL=1
ifeq ($(SPECIAL), 1) 

test.o: test.c
	$(CC) $(FLAGS) -c $^

thread_pool.o: thread_pool.c
	$(CC) $(FLAGS) -c $^

common.o: %.o: %.c
	$(CC) $(FLAGS) -c $^
	
else

#$(OBJS): $(OBJ_SRC)
$(OBJS): %.o: %.c
	$(CC) $(FLAGS) -c $^

endif	

.PHONY: clean
clean:
	rm -f *.o $(TARGET)

