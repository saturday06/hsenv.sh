#!/bin/sh

PATH=`pwd`/../bin:$PATH

testDefaultOutput() {
    assertEquals "dummy!" `hsenv`
}

. shunit2/src/shunit2
