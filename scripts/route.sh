#!/bin/bash

nfdc face create tcp4://$2
nfdc route add $1 tcp4://$2
