/*
** Copyright (C) 2000 Albert L. Faber
**  
** This program is free software; you can redistribute it and/or modify
** it under the terms of the Affero GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
** 
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** Affero GNU General Public License for more details.
** 
** You should have received a copy of the Affero GNU General Public License
** along with this program; if not, write to the Free Software 
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

#ifndef MPGLIB_TABINIT_H_INCLUDED
#define MPGLIB_TABINIT_H_INCLUDED

#include "mpg123.h"

extern real decwin[512+32];
extern real *pnts[5];

void make_decode_tables(long scale);

#endif


