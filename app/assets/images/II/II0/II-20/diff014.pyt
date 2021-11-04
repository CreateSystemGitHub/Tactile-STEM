import sympy as sp
sp.var('t,g')
x=sp.Function('x')(t)
eq1=sp.Eq(sp.diff(x,t,2),-g)
sp.dsolve(eq1)
