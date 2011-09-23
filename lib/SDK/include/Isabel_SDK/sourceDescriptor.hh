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
// $Id: sourceDescriptor.hh 20757 2010-07-05 10:01:13Z gabriel $
//
/////////////////////////////////////////////////////////////////////////

#ifndef __isabel_sdk__source_descriptor_hh__
#define __isabel_sdk__source_descriptor_hh__

#include <icf2/general.h>
#include <icf2/smartReference.hh>

class sourceDescriptor_t: public virtual collectible_t
{
public:
    virtual const char *getID         (void) const = 0;
    virtual const char *getInputPorts (void) const = 0;

    friend class smartReference_t<sourceDescriptor_t>;
};

typedef smartReference_t<sourceDescriptor_t> sourceDescriptor_ref;


#endif
