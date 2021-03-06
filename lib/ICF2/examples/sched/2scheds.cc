/////////////////////////////////////////////////////////////////////////
//
// ISABEL: A group collaboration tool for the Internet
// Copyright (C) 2009 Agora System S.A.
// 
// This file is part of Isabel.
// 
// Isabel is free software: you can redistribute it and/or modify
// it under the terms of the Affero GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// Isabel is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// Affero GNU General Public License for more details.
// 
// You should have received a copy of the Affero GNU General Public License
// along with Isabel.  If not, see <http://www.gnu.org/licenses/>.
//
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//
// $Id: 2scheds.cc 20206 2010-04-08 10:55:00Z gabriel $
//
// (C) Copyright 1993-99. Dpto Ingenieria Sistemas Telematicos UPM Spain
// Dec 31, 1999 Transfered to Agora Systems S.A.
// (C) Copyright 2000-2001. Agora Systems S.A.
//
/////////////////////////////////////////////////////////////////////////


#include <string.h>

#include "threadedApp.hh"

class cookie_t: public simpleTask_t
{
private:
    char *__m;
public:
    cookie_t(int p, char *m):simpleTask_t(p), __m(strdup(m)){
    };

    virtual ~cookie_t(void) { free(__m); }

    virtual void heartBeat(void) { printf("cookie_t::%s\n", __m); }

    virtual char *className(void) const { return "cookie_t"; }
};

class myApp_t: public sched_t {
public:
    myApp_t(int numTask=128):sched_t(numTask) {}
};

int
main(int argc, char **argv)
{
    myApp_t         theApp;
    threadedApp_t  *theThreadedApp= new threadedApp_t;

    theApp<< new cookie_t(1000000, "1hola 1000000");
    theApp<< new cookie_t(1500000, "1.5hola 1500000");

    theThreadedApp->tlPostMsg(new insertTaskMsg_t(new cookie_t(2000000,"__2adios 2000000")));
    theThreadedApp->tlRun();
 
    theThreadedApp->tlPostMsg(new insertTaskMsg_t(new cookie_t(3000000,"__3adios 3000000")));

    theApp.run();

    return 0;
}

