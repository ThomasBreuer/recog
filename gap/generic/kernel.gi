#############################################################################
##
##  This file is part of recog, a package for the GAP computer algebra system
##  which provides a collection of methods for the constructive recognition
##  of groups.
##
##  This files's authors include Sergio Siccha.
##
##  Copyright of recog belongs to its developers whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-3.0-or-later
##
##
##  Implementation of recog methods
##
#############################################################################

InstallGlobalFunction( FindKernelRandom,
  function(ri,n)
    local i,l,rifac,s,x,y;
    Info(InfoRecog,2,"Creating ",n," random generators for kernel.");
    l := gensN(ri);
    rifac := RIFac(ri);
    for i in [1..n] do
        x := RandomElm(ri,"KERNELANDVERIFY",true).el;
        Assert(2, ValidateHomomInput(ri, x));
        s := SLPforElement(rifac,ImageElm( Homom(ri), x!.el ));
        if s = fail then
            return false;
        fi;
        y := ResultOfStraightLineProgram(s, ri!.pregensfacwithmem);
        Add(l,x^-1*y);
        if InfoLevel(InfoRecog) >= 2 then
            Print(".\c");
        fi;
    od;
    if InfoLevel(InfoRecog) >= 2 then
        Print("\n");
    fi;
    return true;
  end );

InstallGlobalFunction( FindKernelDoNothing,
  function(ri,n1,n2)
    return true;
  end );

# Returns the product of a subsequence of a list (of generators).
# An entry in the original list is chosen for the subsequence with
# probability 1/2.
InstallGlobalFunction( RandomSubproduct, function(a)
    local prod, list, g;

    if IsGroup(a) then
        prod := One(a);
        list := GeneratorsOfGroup(a);
    elif IsList(a) then
        if Length(a) = 0 or
            not IsMultiplicativeElementWithInverse(a[1]) then
            ErrorNoReturn("<a> must be a nonempty list of group elements");
        fi;
        prod := One(a[1]);
        list := a;
    else
        ErrorNoReturn("<a> must be a group or a nonempty list of group elements");
    fi;

    for g in list do
        if Random( [ true, false ] )  then
            prod := prod * g;
        fi;
    od;
    return prod;
end );

# Computes randomly (it might underestimate) the normal closure of <list>
# under conjugation by the group generated by <grpgens>.
InstallGlobalFunction( FastNormalClosure , function( grpgens, list, n )
  local i,list2,randgens,randlist;
  list2:=ShallowCopy(list);
  if Length(grpgens) > 3 then
    for i in [1..6*n] do
      if Length(list2)=1 then
        randlist:=list2[1];
      else
        randlist:=RandomSubproduct(list2);
      fi;
      if not IsOne(randlist) then
        randgens:=RandomSubproduct(grpgens);
        if not IsOne(randgens) then
          Add(list2,randlist^randgens);
        fi;
      fi;
    od;
  else # for short generator lists, conjugate with all generators
    for i in [1..3*n] do
      if Length(list2)=1 then
        randlist:=list2[1];
      else
        randlist:=RandomSubproduct(list2);
      fi;
      if not IsOne(randlist) then
         for randgens in grpgens do
             Add(list2, randlist^randgens);
         od;
      fi;
    od;
  fi;
  return list2;
end );

# FIXME: rename FindKernelFastNormalClosure to indicate that it *also* computes random generators
InstallGlobalFunction( FindKernelFastNormalClosure,
  # Used in the generic recursive routine.
  function(ri,n1,n2)
    if not FindKernelRandom(ri, n1) then
        return false;
    fi;

    SetgensN(ri,FastNormalClosure(ri!.gensHmem,gensN(ri),n2));

    return true;
  end);
