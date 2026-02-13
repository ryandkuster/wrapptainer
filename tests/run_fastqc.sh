#!/usr/bin/env bash

mkdir -p fastqc_out

bash ../appy.sh -q fastqc -o fastqc_out -q fake.fq

