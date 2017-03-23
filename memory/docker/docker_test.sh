#!/bin/bash
## Clean the filesystem cache
sync && free > tmp.out

for i in {1..10}
do
		docker run --rm ashael/stream > tmp.out && sed -n '27,31 p' tmp.out >> docker_stream.out
			sync && free > tmp.out
		done
